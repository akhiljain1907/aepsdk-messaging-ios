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
import SwiftUI

/// The Siri / Apple Intelligence snippet that renders Messaging **content cards** using the
/// SDK's own UI. Each card is drawn with `ContentCardUI.view` — the exact same view returned
/// by `Messaging.getContentCardsUI(for:)` and used in-app — so the assistant surface matches
/// the in-app presentation without re-implementing the templates.
@available(iOS 16.0, *)
public struct MessagingContentCardsSnippetView: View {
    /// Maximum cards rendered in the snippet; extras are summarized as "+N more".
    private static let maxCards = 3

    let cards: [ContentCardUI]

    public init(cards: [ContentCardUI]) {
        self.cards = cards
    }

    public var body: some View {
        if cards.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "rectangle.on.rectangle")
                        .foregroundColor(.secondary)
                    Text("No Content Cards")
                        .font(.headline)
                }
                Text("Open the app to load your latest cards first.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(cards.prefix(Self.maxCards).enumerated()), id: \.offset) { _, card in
                    // The SDK-provided content card view — same rendering as getContentCardsUI.
                    card.view
                }

                if cards.count > Self.maxCards {
                    Text("+\(cards.count - Self.maxCards) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}
