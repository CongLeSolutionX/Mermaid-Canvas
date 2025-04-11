//
//  MermaidCanvasLocalView.swift
//  Mermaid_Canvas
//
//  Created by Cong Le on 4/10/25.
//

import SwiftUI
import WebKit // Essential for WKWebView

// MARK: - Mermaid WebView (UIViewRepresentable Wrapper - LOCAL VERSION)

struct MermaidWebView: UIViewRepresentable {

    // The Mermaid syntax string to render
    let mermaidString: String

    // Coordinator class (remains the same)
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: MermaidWebView

        init(_ parent: MermaidWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Mermaid WebView finished loading (Local).")
            // Optional: Inject JS after load if needed
            // webView.evaluateJavaScript("console.log('Hello from Swift after load!');")
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
             print("Mermaid WebView committed navigation (Local).")
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Mermaid WebView failed navigation (Local): \(error.localizedDescription)")
        }
         func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
             print("Mermaid WebView failed provisional navigation (Local): \(error.localizedDescription)")
             // You might want to display an error to the user here if the local file couldn't be loaded
             let errorHTML = """
             <p style="color: red; font-family: sans-serif;">
                 Error loading base HTML or local Mermaid script. Check console. <br>
                 Error: \(error.localizedDescription)
             </p>
             """
             webView.loadHTMLString(errorHTML, baseURL: nil) // BaseURL nil here is ok for simple error string
         }
    }

    // makeUIView remains largely the same
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        // Optional: Configure background transparency
        // webView.isOpaque = false
        // webView.backgroundColor = UIColor.clear
        // webView.scrollView.backgroundColor = UIColor.clear
        return webView
    }

    // Updates the WKWebView when the mermaidString changes
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 1. Get the latest Mermaid string
        let content = mermaidString.trimmingCharacters(in: .whitespacesAndNewlines)

        // 2. Construct the HTML content
        //    - Uses the LOCAL mermaid.min.js file (must be in the app bundle)
        //    - Includes basic viewport meta tag for scaling
        //    - Places the Mermaid syntax string inside a <pre class="mermaid"> tag
        //    - Initializes Mermaid after the content is loaded
        let htmlContent = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Mermaid Render (Local)</title>
            <style>
                /* Basic styling (same as before) */
                body {
                    margin: 15px;
                    display: flex;
                    justify-content: center;
                    align-items: flex-start;
                    min-height: 95vh;
                    background-color: #FFFFFF; /* Or use #clear if transparent */
                 }
                .mermaid {
                     text-align: center;
                     max-width: 100%;
                 }
                /* Optional: Dark mode support */
                 @media (prefers-color-scheme: dark) {
                     body {
                         background-color: #1C1C1E;
                     }
                     /* You might need to explicitly set a Mermaid theme for dark mode */
                 }
            </style>
        </head>
        <body>
            <pre class="mermaid">
        \(content)
            </pre>

            <!-- *** CHANGED: Load Mermaid library from LOCAL bundle *** -->
            <script src="mermaid-11.6.0.min.js"></script>

            <!-- Initialize Mermaid (same as before) -->
            <script>
                try {
                  // Optional: Set dark theme based on CSS media query if needed
                  // const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                  // mermaid.initialize({ startOnLoad: true, theme: prefersDark ? 'dark' : 'default' });

                  // Default initialization
                  mermaid.initialize({ startOnLoad: true });

                  console.log('Local Mermaid initialized successfully.');
                } catch (e) {
                  console.error('Error initializing local Mermaid:', e);
                  document.body.innerHTML = '<p style="color: red; font-family: sans-serif;">Error rendering Mermaid diagram: ' + e.message + '. Check console.</p>';
                }
            </script>
        </body>
        </html>
        """

        // 3. Load the HTML string into the WKWebView
        //    *** CHANGED: Provide the bundle resource URL as the baseURL ***
        //    This tells the WKWebView where to find "mermaid.min.js"
        if let baseURL = Bundle.main.resourceURL {
            uiView.loadHTMLString(htmlContent, baseURL: baseURL)
        } else {
            print("Error: Could not find bundle resource URL.")
            // Handle error: Maybe load an error message into the WebView
             uiView.loadHTMLString("<p>Error loading: Bundle resource URL not found.</p>", baseURL: nil)
        }
    }
}

// MARK: - Content View (Example Usage - No changes needed here)

struct MermaidCanvasLocalView: View {
    // (State variable and body remain the same as the previous example)
    @State private var mermaidInput: String = """
    graph TD
        A["Local Start"] --> B{"Use Local JS?"}
        B -- Yes --> C["Render Offline!"]
        B -- No --> D["Needs Network (Old Way)"]
        C --> E["Profit!"]
        D --> F["Risky..."]
        E --> G["End"]
    """ // Example diagram

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextEditor(text: $mermaidInput)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.gray.opacity(0.5), width: 1)
                    .padding([.horizontal, .top])

                Divider().padding(.horizontal)

                MermaidWebView(mermaidString: mermaidInput)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Mermaid Renderer (Local)")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Keyboard Helper (No changes needed)

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

// MARK: - Preview Provider (No changes needed)

struct MermaidCanvasLocalView_Previews: PreviewProvider {
    static var previews: some View {
        MermaidCanvasLocalView()
    }
}

// MARK: - App Entry Point (If needed)
/*
@main
struct MermaidLocalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/
