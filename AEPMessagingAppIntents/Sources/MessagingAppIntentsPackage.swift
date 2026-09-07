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

/// App Intents defined inside a framework are only discovered by the system when the host app
/// declares that it includes the framework's App Intents package. Conform this framework to
/// `AppIntentsPackage`, then in the host app:
///
/// ```swift
/// import AppIntents
/// import AEPMessagingAppIntents
///
/// struct MyAppPackage: AppIntentsPackage {
///     static var includedPackages: [any AppIntentsPackage.Type] {
///         [MessagingAppIntentsPackage.self]
///     }
/// }
/// ```
///
/// The app also declares an `AppShortcutsProvider` pointing at
/// ``GetMessagingContentCardsIntent`` / ``GetMessagingCodeBasedOffersIntent`` with app-name
/// Siri phrases. See the module README / demo for the full wiring.
@available(iOS 16.0, *)
public struct MessagingAppIntentsPackage: AppIntentsPackage {
    public init() {}
}
