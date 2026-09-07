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

/// SDK-provided App Intent that surfaces Messaging **code-based experiences** (HTML / JSON
/// content items) through Siri / Apple Intelligence. Fetches propositions for the configured
/// surface via `Messaging.getPropositionsForSurfaces(_:)`, maps each `PropositionItem` to a
/// presentable ``CodeBasedOffer``, and renders a custom snippet.
@available(iOS 16.0, *)
public struct GetMessagingCodeBasedOffersIntent: AppIntent {
    public static var title: LocalizedStringResource = "Show My Experiences"

    public static var description = IntentDescription(
        "Shows the code-based experiences you have received.")

    public static var openAppWhenRun = false

    private static let logger = Logger(subsystem: "com.adobe.aepsdk.messaging",
                                       category: "AppIntents")

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let surfacePath = MessagingAppIntents.codeBasedSurfacePath, !surfacePath.isEmpty else {
            Self.logger.error("No code-based surface configured (MessagingAppIntents.codeBasedSurfacePath)")
            return .result(
                dialog: "Experiences aren't set up yet. Open the app first.",
                view: MessagingCodeBasedSnippetView(offers: []))
        }

        let offers = await Self.codeBasedOffers(for: Surface(path: surfacePath))
        Self.logger.notice("GetMessagingCodeBasedOffersIntent — \(offers.count, privacy: .public) offer(s) for surface \(surfacePath, privacy: .public)")

        let dialog: IntentDialog
        switch offers.count {
        case 0:
            dialog = "You don't have any experiences right now."
        case 1:
            dialog = "You have 1 experience: \(offers[0].summary)"
        default:
            dialog = "You have \(offers.count) experiences."
        }

        return .result(dialog: dialog, view: MessagingCodeBasedSnippetView(offers: offers))
    }

    /// Bridges the completion-based `getPropositionsForSurfaces` API to async/await and maps
    /// the returned proposition items to code-based offers.
    private static func codeBasedOffers(for surface: Surface) async -> [CodeBasedOffer] {
        await withCheckedContinuation { continuation in
            Messaging.getPropositionsForSurfaces([surface]) { propositionsDict, error in
                if let error = error {
                    logger.error("getPropositionsForSurfaces failed: \(error.localizedDescription, privacy: .public)")
                    continuation.resume(returning: [])
                    return
                }
                let propositions = propositionsDict?[surface] ?? []
                let offers = propositions
                    .flatMap { $0.items }
                    .compactMap { CodeBasedOffer(propositionItem: $0) }
                continuation.resume(returning: offers)
            }
        }
    }
}
