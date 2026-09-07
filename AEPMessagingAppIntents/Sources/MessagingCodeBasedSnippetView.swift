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

import SwiftUI

/// The Siri / Apple Intelligence snippet for **code-based experiences**. Unlike content cards,
/// these have no SDK-shipped UI, so this is a custom, restrained list rendering.
@available(iOS 16.0, *)
public struct MessagingCodeBasedSnippetView: View {
    private static let maxRows = 6

    let offers: [CodeBasedOffer]

    public init(offers: [CodeBasedOffer]) {
        self.offers = offers
    }

    public var body: some View {
        if offers.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "curlybraces")
                        .foregroundColor(.secondary)
                    Text("No Experiences")
                        .font(.headline)
                }
                Text("Open the app to load your latest experiences first.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        } else {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "curlybraces")
                        .foregroundColor(.accentColor)
                    Text("Your Experiences")
                        .font(.headline)
                    Spacer()
                    Text("\(offers.count)")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                }

                ForEach(offers.prefix(Self.maxRows)) { offer in
                    Divider()
                    HStack(alignment: .top, spacing: 8) {
                        Text(offer.kind.rawValue)
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.15))
                            .clipShape(Capsule())
                        Text(offer.summary)
                            .font(.subheadline)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if offers.count > Self.maxRows {
                    Divider()
                    Text("+\(offers.count - Self.maxRows) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}
