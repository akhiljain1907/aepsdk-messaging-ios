/*
 Copyright 2026 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPMessaging
import Foundation

/// A lightweight, presentable view of a Messaging **code-based experience** item (an HTML or
/// JSON content item). Code-based experiences have no SDK-shipped UI — the app owns rendering
/// — so this derives a speakable/displayable summary for the assistant surface.
public struct CodeBasedOffer: Identifiable, Hashable {
    public enum Kind: String {
        case html = "HTML"
        case json = "JSON"
        case other = "Other"
    }

    public let id: String
    public let kind: Kind
    /// A short, human-readable rendering suitable for Siri to speak or show.
    public let summary: String

    /// Builds a `CodeBasedOffer` from a `PropositionItem`, or returns `nil` if the item is not
    /// an HTML/JSON code-based experience.
    public init?(propositionItem item: PropositionItem) {
        id = item.itemId
        if let html = item.htmlContent, !html.isEmpty {
            kind = .html
            summary = CodeBasedOffer.stripHTML(html)
        } else if let dict = item.jsonContentDictionary {
            kind = .json
            summary = CodeBasedOffer.summarizeJSON(dict)
        } else if let array = item.jsonContentArray {
            kind = .json
            summary = "\(array.count) item(s)"
        } else {
            return nil
        }
    }

    // MARK: - Text helpers

    static func stripHTML(_ html: String) -> String {
        var text = html.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "HTML experience" : trimmed
    }

    static func summarizeJSON(_ dict: [String: Any]) -> String {
        let preferredKeys = ["content", "message", "text", "title", "headline", "description", "body"]
        for key in preferredKeys {
            if let value = dict[key] as? String, !value.isEmpty {
                return value
            }
        }
        for value in dict.values {
            if let string = value as? String, !string.isEmpty {
                return string
            }
        }
        return "JSON experience"
    }
}
