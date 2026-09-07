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

import AppIntents

/// Registers the Siri phrases that trigger the SDK-provided Messaging App Intents. Phrases must
/// include `\(.applicationName)`; keep them distinctive and app-directed so they don't collide
/// with Siri's built-in domains.
///
/// The intent and view types come from the Messaging SDK (the `AEPMessagingAppIntents` module).
/// This demo compiles them directly into the app target; SPM consumers instead link the
/// `AEPMessagingAppIntents` product and declare an `AppIntentsPackage` including
/// `MessagingAppIntentsPackage`.
@available(iOS 16.0, *)
struct MessagingOfferShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetMessagingContentCardsIntent(),
            phrases: [
                "Show my content cards in \(.applicationName)",
                "Show my cards in \(.applicationName)",
                "\(.applicationName) content cards"
            ],
            shortTitle: "Content Cards",
            systemImageName: "rectangle.on.rectangle.angled"
        )

        AppShortcut(
            intent: GetMessagingCodeBasedOffersIntent(),
            phrases: [
                "Show my experiences in \(.applicationName)",
                "List my experiences in \(.applicationName)",
                "\(.applicationName) experiences"
            ],
            shortTitle: "Experiences",
            systemImageName: "curlybraces"
        )
    }
}
