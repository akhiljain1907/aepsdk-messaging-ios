/*
 Copyright 2025 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import Foundation
import UserNotifications

/// Lightweight helper for processing rich media in Notification Service Extensions.
/// This class is designed to be used in app extensions and has no dependencies on AEPCore or AEPServices.
@objc(AEPMessagingNotificationService)
public final class MessagingNotificationService: NSObject {
    
    /// The key used to look up the media URL in the notification's userInfo dictionary.
    @objc public static let mediaKey = "adb_media"
    
    /// Processes the notification request and downloads/attaches rich media if present.
    /// Call this method from your `UNNotificationServiceExtension.didReceive(_:withContentHandler:)` implementation.
    ///
    /// - Parameters:
    ///   - request: The incoming notification request.
    ///   - contentHandler: The content handler to call with the modified content.
    @objc(processNotificationRequest:withContentHandler:)
    public static func processNotificationRequest(_ request: UNNotificationRequest,
                                                   contentHandler: @escaping (UNNotificationContent) -> Void) {
        guard let mutableContent = request.content.mutableCopy() as? UNMutableNotificationContent else {
            contentHandler(request.content)
            return
        }
        
        downloadAndAttachMedia(to: mutableContent) {
            contentHandler(mutableContent)
        }
    }
    
    /// Downloads media from the `adb_media` key in userInfo and attaches it to the notification content.
    ///
    /// - Parameters:
    ///   - content: The mutable notification content to modify.
    ///   - completion: Called when processing is complete (with or without attachment).
    @objc(downloadAndAttachMediaTo:completion:)
    public static func downloadAndAttachMedia(to content: UNMutableNotificationContent,
                                               completion: @escaping () -> Void) {
        guard let mediaURLString = content.userInfo[mediaKey] as? String,
              let mediaURL = URL(string: mediaURLString),
              mediaURL.scheme?.lowercased() == "https" else {
            completion()
            return
        }
        
        URLSession.shared.downloadTask(with: mediaURL) { tempURL, response, error in
            defer { completion() }
            
            guard let tempURL = tempURL, error == nil else { return }
            
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                return
            }
            
            let fileExtension = determineFileExtension(from: mediaURL, response: response)
            let destinationURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("aep-media-\(UUID().uuidString).\(fileExtension)")
            
            do {
                try FileManager.default.copyItem(at: tempURL, to: destinationURL)
                
                if let attachment = try? UNNotificationAttachment(identifier: "aep-media",
                                                                   url: destinationURL,
                                                                   options: nil) {
                    content.attachments = [attachment]
                }
            } catch {
                // Failed to copy file - notification will be delivered without media
            }
        }.resume()
    }
    
    // MARK: - Private Helpers
    
    private static func determineFileExtension(from url: URL, response: URLResponse?) -> String {
        // Try to get extension from URL path
        let pathExtension = (url.path as NSString).pathExtension.lowercased()
        if !pathExtension.isEmpty {
            return pathExtension
        }
        
        // Try to determine from Content-Type header
        if let httpResponse = response as? HTTPURLResponse,
           let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") {
            let mimeType = contentType.lowercased().split(separator: ";").first.map(String.init) ?? ""
            switch mimeType {
            case "image/png": return "png"
            case "image/gif": return "gif"
            case "image/jpeg", "image/jpg": return "jpg"
            case "video/mp4": return "mp4"
            case "audio/mpeg": return "mp3"
            default: break
            }
        }
        
        // Default to jpg
        return "jpg"
    }
}
