# MermaidCanvas for SwiftUI


[![Swift Version](https://img.shields.io/badge/Swift-5.5%2B-orange.svg)](https://swift.org/)
[![Platform](https://img.shields.io/badge/Platform-iOS%2014%2B%20%7C%20macOS%2011%2B-blue.svg)](https://developer.apple.com/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)
[![License: CC BY 4.0](https://licensebuttons.net/l/by/4.0/88x31.png)](LICENSE-CC-BY)

---
Copyright (c) 2025 Cong Le. All Rights Reserved.

---

**Seamlessly render [Mermaid](https://mermaid.js.org/) diagrams within your SwiftUI applications.**

Ever wanted to display complex flowcharts, sequence diagrams, or Gantt charts defined using the simple, text-based Mermaid syntax directly in your SwiftUI app? MermaidCanvas provides a straightforward technique using `UIViewRepresentable` to wrap a `WKWebView`, allowing you to render dynamic Mermaid diagrams with minimal effort.

## Features

*   **SwiftUI Native Feel:** Integrates directly into your SwiftUI view hierarchy.
*   **Dynamic Rendering:** Updates the diagram automatically when your Mermaid syntax string changes.
*   **WebView Powered:** Leverages the power and flexibility of `WKWebView` and the official Mermaid.js library.
*   **CDN Based:** Uses the official Mermaid.js CDN, ensuring you have access to recent versions.
*   **Customizable:**
    *   Basic CSS styling provided for centering and padding.
    *   Supports dark mode automatically via `@media (prefers-color-scheme: dark)`.
    *   Allows customization of `WKWebView` properties (background, scrolling, zoom).
    *   Includes a `Coordinator` for handling `WKNavigationDelegate` events if needed.
*   **Simple Integration:** Requires adding just one Swift file to your project.

## Demo

![Demo Screenshot](/Media/Demo_Rendering_Mermaid_Syntax.png)

## How it Works

MermaidCanvas utilizes the `UIViewRepresentable` protocol to bridge UIKit's `WKWebView` into the SwiftUI environment.

1.  **`MermaidWebView` Struct:** This struct conforms to `UIViewRepresentable`.
2.  **`makeUIView`:** Creates and configures a `WKWebView` instance once. It enables scrolling and sets up the optional `Coordinator` as the navigation delegate.
3.  **`updateUIView`:** This method is crucial. Whenever the `mermaidString` input changes:
    *   It constructs an HTML string on-the-fly.
    *   This HTML includes:
        *   Basic boilerplate and CSS styling.
        *   The user-provided Mermaid syntax embedded within a `<pre class="mermaid">` tag.
        *   A `<script>` tag to load `mermaid.min.js` from a CDN.
        *   An inline `<script>` tag to initialize Mermaid (`mermaid.initialize()`) after the page loads, which finds the `<pre>` tag and renders the diagram.
    *   It calls `webView.loadHTMLString(...)` on the `WKWebView` instance to load this generated HTML.
4.  **`Coordinator`:** An optional class conforming to `WKNavigationDelegate` to handle WebView events like load success or failure.

## Requirements

*   iOS 14.0+ / macOS 11.0+
*   Xcode 13.0+
*   Swift 5.5+
*   **Active Internet Connection:** Required at runtime for the `WKWebView` to fetch the Mermaid.js library from the CDN.

## Installation

1.  Copy the `MermaidWebView.swift` file (containing the `MermaidWebView` struct, `Coordinator`, and helper extensions) into your Xcode project.
2.  Ensure your project is linked against the `WebKit` framework (usually added automatically when importing `WebKit`).

## Example Usage

Here's how you can use `MermaidWebView` in your SwiftUI `ContentView`:

```swift
import SwiftUI
// Make sure WebKit is imported if you need to reference its types directly,
// though it's primarily used within MermaidWebView.swift
// import WebKit

struct ContentView: View {
    // State variable to hold the Mermaid syntax
    @State private var mermaidInput: String = """
    graph TD
        A[Start] --> B{Is it Live?};
        B -- Yes --> C[Deploy!];
        B -- No --> D[Keep Coding];
        C --> E[Profit!];
        D --> B; // Loop back
        E --> F[End];
    """

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // TextEditor for inputting Mermaid syntax
                TextEditor(text: $mermaidInput)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.5), width: 1)
                    .padding([.horizontal, .top])

                Divider().padding(.horizontal)

                // MermaidWebView to display the rendered diagram
                MermaidWebView(mermaidString: mermaidInput)
                    // Takes remaining space
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // Optional: Add padding if needed
                    // .padding()
            }
            .navigationTitle("MermaidCanvas Demo")
            .navigationBarTitleDisplayMode(.inline)
            // Basic keyboard dismissal
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationViewStyle(.stack)
    }
}

// Helper to hide keyboard (place in a separate file or extension)
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

## Customization

*   **Styling:** Modify the CSS within the `htmlContent` string in `MermaidWebView.swift`'s `updateUIView` method.
*   **Mermaid Configuration:** Pass configuration options to `mermaid.initialize({ ... })` in the final `<script>` tag within `htmlContent`. See [Mermaid.js documentation](https://mermaid.js.org/config/schema-docs/config.html) for options (e.g., `theme: 'dark'`).
*   **WebView Behavior:** Adjust properties of the `WKWebView` instance in `makeUIView` (e.g., disable scrolling, change background color, disable zoom). If changing the background to transparent, ensure the `body` background in the CSS is also set appropriately (e.g., `background-color: transparent;`).
*   **Offline Support:** For offline use, you would need to bundle the Mermaid.js library within your app and adjust the `<script src="...">` tag in `htmlContent` to load it from the app's bundle resources using `loadFileURL(_:allowingReadAccessTo:)` on the `WKWebView` instead of `loadHTMLString`. This is a more advanced setup.
*   **Delegate Logic:** Add more complex interaction logic within the `Coordinator` by implementing other `WKNavigationDelegate` methods.

## Contributing

Found a bug or have an improvement? Feel free to open an Issue or submit a Pull Request!

## License


- **MIT License:**  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) - Full text in [LICENSE](LICENSE) file.
- **Creative Commons Attribution 4.0 International:** [![License: CC BY 4.0](https://licensebuttons.net/l/by/4.0/88x31.png)](LICENSE-CC-BY) - Legal details in [LICENSE-CC-BY](LICENSE-CC-BY) and at [Creative Commons official site](http://creativecommons.org/licenses/by/4.0/).

---
