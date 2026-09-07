# AEPMessagingAppIntents

An **opt-in** SDK module that exposes AEP Messaging **content cards** and **code-based
experiences** to Siri, Spotlight, the Shortcuts app, and Apple Intelligence via Apple's
[App Intents](https://developer.apple.com/documentation/appintents) framework.

The headline capability: the content-cards intent renders **the SDK's own `ContentCardUI.view`**
inside the Siri snippet — the exact same view returned by `Messaging.getContentCardsUI(for:)`
and used in-app — so the assistant surface matches your in-app cards with no re-implementation.

Requires iOS 16+ at runtime (all App Intents types are `@available(iOS 16.0, *)`).

## What the module provides

| Type | Role |
|------|------|
| `MessagingAppIntents` | Configuration: set the content-card and code-based **surface paths** (persisted for cold launch); optional App Group. |
| `GetMessagingContentCardsIntent` | Fetches content cards via `getContentCardsUI` and renders `ContentCardUI.view` in the snippet. |
| `MessagingContentCardsSnippetView` | The snippet that lays out the SDK content-card views. |
| `GetMessagingCodeBasedOffersIntent` | Fetches code-based (HTML/JSON) items via `getPropositionsForSurfaces` and shows a custom snippet. |
| `CodeBasedOffer` / `MessagingCodeBasedSnippetView` | Presentable model + custom UI for code-based experiences (which have no SDK-shipped UI). |
| `MessagingAppIntentsPackage` | Lets the host app surface intents defined in this framework. |

## Content types & suitability

| Type | Snippet fit | How it's handled |
|------|-------------|------------------|
| **Content cards** | ✅ Best | Structured (title/body/image/buttons) → rendered with the SDK's `ContentCardUI.view` |
| **Code-based (JSON)** | ✅ Good | Summarized to a readable field, custom list snippet |
| **Code-based (HTML)** | ⚠️ Limited | Tag-stripped to text (no webview in a snippet) |
| **In-app messages** | ❌ Not viable | Full HTML in `WKWebView`; can't render in a snippet — open the app instead |

## Host-app integration

### 1. Point the intents at your surfaces (once, at launch)

```swift
import AEPMessagingAppIntents

MessagingAppIntents.contentCardSurfacePath = "myapp/contentcards/home"
MessagingAppIntents.codeBasedSurfacePath  = "myapp/cbe/json"
// Optional, only if a widget/extension needs the same values:
MessagingAppIntents.configure(appGroup: "group.com.example.myapp")
```

For the best cold-launch experience, enable offline/persistent content cards in your Messaging
configuration so cached cards are available before a fresh fetch completes.

### 2. Make the framework's intents discoverable

```swift
import AppIntents
import AEPMessagingAppIntents

struct MyAppIntentsPackage: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] {
        [MessagingAppIntentsPackage.self]
    }
}
```

### 3. Give Siri phrases (must include the app name)

```swift
import AppIntents
import AEPMessagingAppIntents

struct MessagingShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: GetMessagingContentCardsIntent(),
                    phrases: ["Show my content cards in \(.applicationName)"],
                    shortTitle: "Content Cards", systemImageName: "rectangle.on.rectangle.angled")
        AppShortcut(intent: GetMessagingCodeBasedOffersIntent(),
                    phrases: ["Show my experiences in \(.applicationName)"],
                    shortTitle: "Experiences", systemImageName: "curlybraces")
    }
}
```

## How it works

The intents run in the app's process (the system may launch the app in the background to
service the request). They call the Messaging public APIs, which read from the extension's
proposition cache — in-memory, backed by the persistent/offline content-card cache when
enabled. `perform()` is `@MainActor` because it constructs SwiftUI views. The intents log to
the unified log:

```bash
log stream --predicate 'subsystem == "com.adobe.aepsdk.messaging"' --style compact
```

## Notes / future work

- `card.view` renders the SDK templates (SmallImage/LargeImage/ImageOnly). Remote card images
  use `AsyncImage`; loading inside a Siri snippet is best-effort.
- Cold-launch answers depend on cached propositions; if the cache is empty the snippet shows an
  empty state prompting the user to open the app.
