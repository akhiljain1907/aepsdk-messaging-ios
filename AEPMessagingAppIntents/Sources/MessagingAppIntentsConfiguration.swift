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

import Foundation

/// Configuration for the Messaging App Intents layer (Siri / Apple Intelligence).
///
/// App Intents run when the system launches the app — potentially a cold launch — to service
/// a Siri request, so the surface(s) to query must be known without any app UI having run.
/// The host app sets these once at launch; they are persisted so they survive cold launches.
///
/// For content cards, the intent calls `Messaging.getContentCardsUI(for:)` for
/// ``contentCardSurfacePath`` and renders the SDK's own `ContentCardUI.view`. For best
/// cold-launch behaviour, enable offline/persistent content cards in your Messaging
/// configuration so cached cards are available before a fresh fetch completes.
public enum MessagingAppIntents {
    private static let cardSurfaceKey = "com.adobe.aepsdk.messaging.appintents.contentCardSurface"
    private static let codeSurfaceKey = "com.adobe.aepsdk.messaging.appintents.codeBasedSurface"

    private static var defaults: UserDefaults = .standard

    /// Point the configuration at a shared App Group container so a widget / intents extension
    /// reads the same values. Call once, early in app launch.
    public static func configure(appGroup: String) {
        if let shared = UserDefaults(suiteName: appGroup) {
            defaults = shared
        }
    }

    /// The Messaging surface path whose content cards the content-cards intent renders
    /// (e.g. `"myapp/contentcards/home"`).
    public static var contentCardSurfacePath: String? {
        get { defaults.string(forKey: cardSurfaceKey) }
        set { defaults.set(newValue, forKey: cardSurfaceKey) }
    }

    /// The Messaging surface path whose code-based experiences (HTML / JSON) the code-based
    /// intent surfaces.
    public static var codeBasedSurfacePath: String? {
        get { defaults.string(forKey: codeSurfaceKey) }
        set { defaults.set(newValue, forKey: codeSurfaceKey) }
    }
}
