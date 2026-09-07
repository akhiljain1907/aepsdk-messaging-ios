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
import AppIntents
import Foundation
import os
import SwiftUI

/// SDK-provided App Intent that shows the user their Messaging **content cards** through Siri /
/// Apple Intelligence. It fetches cards for the configured surface via
/// `Messaging.getContentCardsUI(for:)` and renders the SDK's own `ContentCardUI.view` in the
/// snippet — the same UI the app shows in-app.
///
/// The card data comes from the Messaging extension's proposition cache (in-memory, backed by
/// the persistent/offline content-card cache when enabled), which is why this can answer even
/// when the app was launched in the background to service the request.
@available(iOS 16.0, *)
public struct GetMessagingContentCardsIntent: AppIntent {
    public static var title: LocalizedStringResource = "Show My Content Cards"

    public static var description = IntentDescription(
        "Shows the content cards you have received.")

    public static var openAppWhenRun = false

    private static let logger = Logger(subsystem: "com.adobe.aepsdk.messaging",
                                       category: "AppIntents")

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let surfacePath = MessagingAppIntents.contentCardSurfacePath, !surfacePath.isEmpty else {
            Self.logger.error("No content card surface configured (MessagingAppIntents.contentCardSurfacePath)")
            return .result(
                dialog: "Content cards aren't set up yet. Open the app first.",
                view: MessagingContentCardsSnippetView(cards: []))
        }

        let cards = await Self.contentCards(for: Surface(path: surfacePath))
        Self.logger.notice("GetMessagingContentCardsIntent — \(cards.count, privacy: .public) card(s) for surface \(surfacePath, privacy: .public)")

        let dialog: IntentDialog
        switch cards.count {
        case 0:
            dialog = "You don't have any content cards right now."
        case 1:
            dialog = "You have 1 content card."
        default:
            dialog = "You have \(cards.count) content cards."
        }

        return .result(dialog: dialog, view: MessagingContentCardsSnippetView(cards: cards))
    }

    /// Bridges the completion-based `getContentCardsUI` API to async/await.
    @MainActor
    private static func contentCards(for surface: Surface) async -> [ContentCardUI] {
        await withCheckedContinuation { continuation in
            Messaging.getContentCardsUI(for: surface) { result in
                switch result {
                case let .success(cards):
                    continuation.resume(returning: cards)
                case let .failure(error):
                    logger.error("getContentCardsUI failed: \(error.localizedDescription, privacy: .public)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
}
