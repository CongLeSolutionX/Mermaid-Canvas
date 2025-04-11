---
created: 2025-04-10 05:31:26
author: Cong Le
version: "1.0"
license(s): MIT, CC BY 4.0
copyright: Copyright (c) 2025 Cong Le. All Rights Reserved.
---



# A Diagrammatic Guide
> **Disclaimer:**
>
> This document contains my personal notes on the topic,
> compiled from publicly available documentation and various cited sources.
> The materials are intended for educational purposes, personal study, and reference.
> The content is dual-licensed:
> 1. **MIT License:** Applies to all code implementations (Swift, Mermaid, and other programming languages).
> 2. **Creative Commons Attribution 4.0 International License (CC BY 4.0):** Applies to all non-code content, including text, explanations, diagrams, and illustrations.
---


---

Let's break down the provided Swift code and illustrate the underlying concepts and interactions using Mermaid diagrams. 

The code defines a SwiftUI view (`MermaidWebView`) that uses `UIViewRepresentable` to wrap a `WKWebView` for rendering Mermaid diagrams defined in a string.

Here's a collection of diagrams explaining the key aspects:

## 1. SwiftUI <-> UIKit Bridge (`UIViewRepresentable`) Interaction


This diagram shows the high-level interaction between the SwiftUI world and the UIKit world facilitated by `UIViewRepresentable`.

```mermaid
---
title: "SwiftUI <-> UIKit Bridge (`UIViewRepresentable`) Interaction"
author: "Cong Le"
version: "1.0"
license(s): "MIT, CC BY 4.0"
copyright: "Copyright (c) 2025 Cong Le. All Rights Reserved."
config:
  layout: elk
  look: handDrawn
  theme: base
---
%%%%%%%% Mermaid version v11.4.1-b.14
%%%%%%%% Toggle theme value to `base` to activate the initilization below for the customized theme version.
%%%%%%%% Available curve styles include the following keywords:
%% basis, bumpX, bumpY, cardinal, catmullRom, linear, monotoneX, monotoneY, natural, step, stepAfter, stepBefore.
%%{
  init: {
    'graph': { 'htmlLabels': false, 'curve': 'natual' },
    'fontFamily': 'Monospace',
    'themeVariables': {
      'primaryColor': '#BEF',
      'primaryTextColor': '#55ff',
      'primaryBorderColor': '#7c2',
      'lineColor': '#F8B229',
      'secondaryColor': '#EE2',
      'tertiaryColor': '#fff',
      'stroke':'#3323',
      'stroke-width': '0.5px'
    }
  }
}%%
graph TD
    subgraph SwiftUI_Realm["SwiftUI Realm"]
    style SwiftUI_Realm fill:#E6F7FF,stroke:#0050B3,stroke-width:1px

        MermaidCanvasView["MermaidCanvasView<br/>(@State mermaidInput)"] -- Contains --> MermaidView("MermaidWebView")
        MermaidView -- mermaidString --> UpdateCheck{"State Change?"}
        UpdateCheck -- Yes --> CallUpdateUIView("Calls updateUIView")
    end

    subgraph UIViewRepresentable_Bridge["UIViewRepresentable Bridge"]
    style UIViewRepresentable_Bridge fill:#FFF7E6,stroke:#D46B08,stroke-width:1px
        
        protocol["UIViewRepresentable Protocol"]

        MermaidView -- Implements --> protocol
        protocol -- Requires --> MakeUIView(makeUIView)
        protocol -- Requires --> UpdateUIView(updateUIView)
        protocol -- Optional --> MakeCoordinator(makeCoordinator)
    end

    subgraph UIKit_Realm["UIKit Realm"]
    style UIKit_Realm fill:#F6FFED,stroke:#389E0D,stroke-width:1px

        MakeUIView -- Creates & Configures --> WKWebViewInstance[WKWebView Instance]
        CallUpdateUIView -- Modifies --> WKWebViewInstance
        MakeCoordinator -- Creates --> CoordinatorInstance[Coordinator]
        CoordinatorInstance -- Acts as --> WKNavDelegate(WKNavigationDelegate)
        WKWebViewInstance -- Sets Delegate --> CoordinatorInstance
        WKWebViewInstance -- Calls Delegate Methods --> CoordinatorInstance
    end

    %% Relationships
    CoordinatorInstance -- References --> MermaidView
    
```


*   **Explanation:** This flowchart illustrates the bridge between SwiftUI and UIKit.
    *   `ContentView` holds the state (`mermaidInput`).
    *   When `mermaidInput` changes, SwiftUI detects the state change.
    *   `MermaidWebView`, conforming to `UIViewRepresentable`, is responsible for the bridge.
    *   `makeUIView` is called *once* initially to create the `WKWebView` instance.
    *   `updateUIView` is called initially *and* whenever the `mermaidString` input changes, triggering the reload of HTML content in the `WKWebView`.
    *   The optional `Coordinator` is created via `makeCoordinator` and set as the `WKWebView`'s `navigationDelegate` to handle navigation events (like load success or failure).

---

## 2. Rendering Pipeline: From String to Diagram

This sequence diagram details the flow of data and actions when the Mermaid string is updated and rendered.

```mermaid
---
title: "Rendering Pipeline: From String to Diagram"
author: "Cong Le"
version: "1.0"
license(s): "MIT, CC BY 4.0"
copyright: "Copyright (c) 2025 Cong Le. All Rights Reserved."
config:
  layout: elk
  look: handDrawn
  theme: base
---
%%%%%%%% Mermaid version v11.4.1-b.14
%%%%%%%% Toggle theme value to `base` to activate the initilization below for the customized theme version.
%%%%%%%% Available curve styles include the following keywords:
%% basis, bumpX, bumpY, cardinal, catmullRom, linear, monotoneX, monotoneY, natural, step, stepAfter, stepBefore.
%%{
  init: {
    'graph': { 'htmlLabels': false, 'curve': 'natual' },
    'fontFamily': 'Monospace',
    'themeVariables': {
      'primaryColor': '#BEF',
      'primaryTextColor': '#55ff',
      'primaryBorderColor': '#7c2',
      'lineColor': '#F8B229',
      'secondaryColor': '#EE2',
      'tertiaryColor': '#fff',
      'stroke':'#3323',
      'stroke-width': '0.5px'
    }
  }
}%%
sequenceDiagram
    autonumber

    actor User

    box rgb(200, 15, 255, 0.2) The App System
        participant CView as ContentView from SwiftUI
        participant TE as TextEditor from SwiftUI
        participant MWV as MermaidWebView from SwiftUI/Representable
        participant WV as WKWebView from UIKit/WebKit
        participant JS as MermaidJS from CDN/External
    end

    User ->> TE: Types Mermaid syntax
    TE ->> CView: Updates @State mermaidInput
    CView ->> MWV: Triggers updateUIView<br/>(provides new mermaidString)
    MWV ->> MWV: Constructs HTML String<br/>(with CSS, <pre>, JS CDN link, init script)
    MWV ->> WV: loadHTMLString(htmlContent, baseURL: nil)
    WV ->> WV: Clears previous content, parses HTML
    
    Note over WV, JS: WKWebView fetches Mermaid.js from CDN<br/>(Network Request)
    
    WV ->> JS: Requests mermaid.min.js
    JS -->> WV: Returns mermaid.min.js
    WV ->> WV: Executes embedded <script> tag
    Note over WV: mermaid.initialize({ startOnLoad: true }) runs
    WV ->> WV: Finds `<pre class="mermaid">`
    WV ->> WV: Renders Mermaid syntax into SVG
    WV ->> User: Displays rendered diagram
    
```


*   **Explanation:** This diagram shows the sequence of events:
    1.  User input modifies the `@State` variable in `ContentView`.
    2.  SwiftUI detects the change and calls `updateUIView` on `MermaidWebView`.
    3.  `MermaidWebView` dynamically builds an HTML document containing the Mermaid syntax, styling, and necessary JavaScript (including the CDN link and initialization code).
    4.  The `WKWebView` is instructed to load this HTML string.
    5.  The `WKWebView` fetches the external Mermaid.js library from the CDN.
    6.  Once the HTML is parsed and the external script is loaded, the inline initialization script (`mermaid.initialize`) runs.
    7.  Mermaid.js finds the `<pre class="mermaid">` tag, parses its content, and renders it (typically as an SVG) within the WebView.

-----

## 3. Coordinator Pattern and Delegation


This class diagram shows the relationship between `MermaidWebView`, its `Coordinator`, and the `WKWebView`'s delegation mechanism.

```mermaid
---
title: "Coordinator Pattern and Delegation"
author: "Cong Le"
version: "1.0"
license(s): "MIT, CC BY 4.0"
copyright: "Copyright (c) 2025 Cong Le. All Rights Reserved."
config:
  look: handDrawn
  theme: base
---
%%%%%%%% Mermaid version v11.4.1-b.14
%%%%%%%% Toggle theme value to `base` to activate the initilization below for the customized theme version.
%%%%%%%% Available curve styles include the following keywords:
%% basis, bumpX, bumpY, cardinal, catmullRom, linear, monotoneX, monotoneY, natural, step, stepAfter, stepBefore.
%%{
  init: {
    '<<protocol>>': { 'htmlLabels': false, 'curve': 'natual' },
    'fontFamily': 'Monospace',
    'themeVariables': {
      'primaryColor': '#BEF',
      'primaryTextColor': '#55ff',
      'primaryBorderColor': '#7c2',
      'lineColor': '#F8B229',
      'secondaryColor': '#EE2',
      'tertiaryColor': '#fff'
    }
  }
}%%
classDiagram
    class MermaidWebView {
        +mermaidString: String
        +makeUIView() WKWebView
        +updateUIView(WKWebView)
        +makeCoordinator() Coordinator
    }

    class Coordinator {
        +parent: MermaidWebView
        +webView(didFinish:)
        +webView(didFail:)
        +webView(didCommit:)
        +webView(didFailProvisionalNavigation:)
        + init(MermaidWebView)
    }

    class WKWebView {
        +navigationDelegate: WKNavigationDelegate?
        +loadHTMLString()
        +scrollView
        #isOpaque
        #backgroundColor
    }

    class WKNavigationDelegate {
    <<protocol>>
        +webView(didFinish:)
        +webView(didFail:)
        +webView(didCommit:)
        +webView(didFailProvisionalNavigation:)
        ... other methods
    }

    MermaidWebView "1" *--> "1" Coordinator : Creates & Owns
    Coordinator ..|> WKNavigationDelegate : Implements
    Coordinator --> MermaidWebView : References Parent
    WKWebView o--> "0..1" WKNavigationDelegate : delegate
    MermaidWebView ..> WKWebView : Uses (via UIViewRepresentable)
    
```


*   **Explanation:**
    *   `MermaidWebView` creates and holds a reference to its `Coordinator`.
    *   The `Coordinator` holds a reference back to the `MermaidWebView` (`parent`) to potentially pass data or trigger actions in the SwiftUI view if needed.
    *   The `Coordinator` conforms to the `WKNavigationDelegate` protocol, implementing methods to react to WebView navigation events.
    *   The `WKWebView` instance created in `makeUIView` has its `navigationDelegate` property set to the `Coordinator` instance. This connects the WebView's events to the `Coordinator`'s methods.

---

## 4. HTML Structure Generated in `updateUIView`


This diagram visualizes the structure of the HTML string being constructed and loaded into the `WKWebView`.

```mermaid
---
title: "HTML Structure Generated in `updateUIView`"
author: "Cong Le"
version: "1.0"
license(s): "MIT, CC BY 4.0"
copyright: "Copyright (c) 2025 Cong Le. All Rights Reserved."
config:
  layout: elk
  look: handDrawn
  theme: base
---
%%%%%%%% Mermaid version v11.4.1-b.14
%%%%%%%% Toggle theme value to `base` to activate the initilization below for the customized theme version.
%%%%%%%% Available curve styles include the following keywords:
%% basis, bumpX, bumpY, cardinal, catmullRom, linear, monotoneX, monotoneY, natural, step, stepAfter, stepBefore.
%%{
  init: {
    'graph': { 'htmlLabels': false, 'curve': 'natural' },
    'fontFamily': 'Monospace',
    'themeVariables': {
      'primaryColor': '#BEF',
      'primaryTextColor': '#55ff',
      'primaryBorderColor': '#7c2',
      'lineColor': '#F8B229',
      'secondaryColor': '#EE2',
      'tertiaryColor': '#fff'
    }
  }
}%%
graph TD
    HTML_Doc["<!DOCTYPE html>...</html>"] --> Head["<head>"]
    HTML_Doc --> Body["<body>"];

    Head --> MetaCharset["<meta charset='UTF-8'>"]
    Head --> MetaViewport["<meta name='viewport'>"]
    Head --> Title["<title>Mermaid Render</title>"]
    Head --> Style["<style>... CSS Rules ...</style>"]

    Body --> PreTag["<pre class='mermaid'>"]
    Body --> MermaidScriptCDN["<script src='CDN URL'></script>"]
    Body --> InitScript["<script> mermaid.initialize() </script>"]

    Style --> BodyStyle["body { margin, display, justify, align, min-height, background }"]
    Style --> MermaidStyle[".mermaid { text-align, max-width }"]
    Style --> DarkModeStyle["@media (prefers-color-scheme: dark) { ... }"]

    PreTag -- Contains --> MermaidSyntax["User-provided Mermaid Syntax"]

    InitScript -- Contains --> TryCatch["try...catch block"]
    TryCatch -- Try --> MermaidInit["mermaid.initialize(...)"]
    TryCatch -- Catch --> ErrorHandling["console.error / document.body.innerHTML = Error Msg"]

    classDef default fill:#f9f,stroke:#333,stroke-width:2px
    
```



*   **Explanation:** This flowchart breaks down the HTML structure:
    *   Standard HTML boilerplate (`DOCTYPE`, `html`, `head`, `body`).
    *   `<head>` includes metadata, title, and crucial `<style>` block for basic layout, centering, and optional dark mode.
    *   `<body>` contains the core elements:
        *   The `<pre class="mermaid">` tag, which is essential for Mermaid.js to find the syntax. The user's `mermaidString` is injected here.
        *   A `<script>` tag to load the Mermaid.js library from the specified CDN.
        *   An inline `<script>` tag to execute `mermaid.initialize()`, which starts the rendering process. This script also includes basic `try...catch` JavaScript error handling.

Note: The diagram version below used to display the text since we have issues with special characters when rendering Mermaid syntax.


```mermaid
---
title: "HTML Structure Generated in `updateUIView`"
author: "Cong Le"
version: "1.0"
license(s): "MIT, CC BY 4.0"
copyright: "Copyright (c) 2025 Cong Le. All Rights Reserved."
config:
  layout: elk
  look: handDrawn
  theme: base
---
%%%%%%%% Mermaid version v11.4.1-b.14
%%%%%%%% Toggle theme value to `base` to activate the initilization below for the customized theme version.
%%%%%%%% Available curve styles include the following keywords:
%% basis, bumpX, bumpY, cardinal, catmullRom, linear, monotoneX, monotoneY, natural, step, stepAfter, stepBefore.
%%{
  init: {
    'graph': { 'htmlLabels': false, 'curve': 'natural' },
    'fontFamily': 'Monospace',
    'themeVariables': {
      'primaryColor': '#E23E',
      'primaryTextColor': '#000',
      'primaryBorderColor': '#7c2',
      'lineColor': '#F8B229',
      'secondaryColor': '#EE2',
      'tertiaryColor': '#fff'
    }
  }
}%%
graph TD
    HTML_Doc["DOCTYPE html...html"] --> Head["head"]
    HTML_Doc --> Body["body"]

    Head --> MetaCharset["meta charset='UTF-8'"]
    Head --> MetaViewport["meta name='viewport'"]
    Head --> Title["title Mermaid Render title"]
    Head --> Style["style... CSS Rules ...style"]

    Body --> PreTag["pre class='mermaid'"]
    Body --> MermaidScriptCDN["script src='CDN URL' script"]
    Body --> InitScript["script mermaid.initialize() script"]

    Style --> BodyStyle["body { margin, display, justify, align, min-height, background }"]
    Style --> MermaidStyle[".mermaid { text-align, max-width }"]
    Style --> DarkModeStyle["@media (prefers-color-scheme: dark) { ... }"]

    PreTag -- Contains --> MermaidSyntax["User-provided Mermaid Syntax"]

    InitScript -- Contains --> TryCatch["try...catch block"]
    TryCatch -- Try --> MermaidInit["mermaid.initialize(...)"]
    TryCatch -- Catch --> ErrorHandling["console.error / document.body.innerHTML = Error Msg"]

    classDef default fill:#f9f,stroke:#333,stroke-width:2px
    
```





----

## 5. Potential States and Error Handling Points


This state diagram shows the different phases the WebView might go through and where errors can occur.

```mermaid
---
title: "Potential States and Error Handling Points"
author: "Cong Le"
version: "1.0"
license(s): "MIT, CC BY 4.0"
copyright: "Copyright (c) 2025 Cong Le. All Rights Reserved."
config:
  look: handDrawn
  theme: base
---
%%%%%%%% Mermaid version v11.4.1-b.14
%%%%%%%% Toggle theme value to `base` to activate the initilization below for the customized theme version.
%%%%%%%% Available curve styles include the following keywords:
%% basis, bumpX, bumpY, cardinal, catmullRom, linear, monotoneX, monotoneY, natural, step, stepAfter, stepBefore.
%%{
  init: {
    'stateDiagram-v2': { 'htmlLabels': false, 'curve': 'natural' },
    'fontFamily': 'Monospace',
    'themeVariables': {
      'primaryColor': '#E333',
      'primaryTextColor': '#ffff',
      'primaryBorderColor': '#7c2',
      'lineColor': '#F8B229',
      'secondaryColor': '#EADE',
      'tertiaryColor': '#fff'
    }
  }
}%%
stateDiagram-v2
    [*] --> Initializing : App Launches

    Initializing --> LoadingHTML : updateUIView called
    LoadingHTML --> FetchingJS : WKWebView starts loading HTML
    LoadingHTML --> NavError_Load : webView(didFailProvisionalNavigation)

    FetchingJS --> Rendering : Mermaid.js fetched from CDN
    FetchingJS --> NavError_Resource : Network Error<br/>(CDN unreachable) / webView(didFail)

    Rendering --> Success : mermaid.initialize() succeeds
    Rendering --> JSError : mermaid.initialize() fails<br/>(JS try/catch)

    NavError_Load --> FailedState
    NavError_Resource --> FailedState
    JSError --> FailedState

    Success --> [*] : (Idle, awaits next update)
    FailedState --> [*] : <br/>(Error state, may display message)

    note left of FetchingJS : Requires Internet Connection
    note right of Rendering : Depends on valid Mermaid Syntax & JS execution
    note right of NavError_Load : Delegate method called
    note right of NavError_Resource : Delegate method called
    note right of JSError : Error caught in embedded <script>
    
```



*   **Explanation:** This diagram highlights the lifecycle and potential failure points:
    *   Starts in an `Initializing` state.
    *   Moves to `LoadingHTML` when `updateUIView` calls `loadHTMLString`. Failure here triggers `didFailProvisionalNavigation`.
    *   If HTML loads, it proceeds to `FetchingJS` (Mermaid library from CDN). Network errors or other load issues here trigger `didFail`.
    *   If JS is fetched, it enters `Rendering` where `mermaid.initialize` runs. JavaScript errors (e.g., syntax errors in Mermaid code, Mermaid library issues) are caught by the `try...catch` block within the HTML.
    *   Successful rendering leads to the `Success` state.
    *   Failures (Navigation or JavaScript) lead to a `FailedState`. The `Coordinator` handles navigation errors, while the JavaScript `catch` block handles initialization errors.

---

## 6. Component Dependencies


This diagram illustrates the internal and external dependencies involved.

```mermaid
---
title: "CHANGE_ME_DADDY"
author: "Cong Le"
version: "1.0"
license(s): "MIT, CC BY 4.0"
copyright: "Copyright (c) 2025 Cong Le. All Rights Reserved."
config:
  layout: elk
  look: handDrawn
  theme: base
---
%%%%%%%% Mermaid version v11.4.1-b.14
%%%%%%%% Toggle theme value to `base` to activate the initilization below for the customized theme version.
%%%%%%%% Available curve styles include the following keywords:
%% basis, bumpX, bumpY, cardinal, catmullRom, linear, monotoneX, monotoneY, natural, step, stepAfter, stepBefore.
%%{
  init: {
    'stateDiagram-v2': { 'htmlLabels': false, 'curve': 'natural' },
    'fontFamily': 'Monospace',
    'themeVariables': {
      'primaryColor': '#E333',
      'primaryTextColor': '#022',
      'primaryBorderColor': '#7c2',
      'lineColor': '#F8B229',
      'secondaryColor': '#EE2',
      'tertiaryColor': '#fff'
    }
  }
}%%
graph TD
    subgraph YourApp["Your SwiftUI App"]
    style YourApp fill:#ECEFF1,stroke:#37474F,stroke-width:1px
        ContentView["ContentView"]
        MermaidWebView["MermaidWebView<br/>(UIViewRepresentable)"]
        Coordinator["Coordinator"]
    end

    subgraph AppleFrameworks["Apple Frameworks"]
    style AppleFrameworks fill:#E3F2FD,stroke:#0D47A1,stroke-width:1px
        SwiftUI["SwiftUI"]
        UIKit["UIKit"]
        WebKit["WebKit<br/>(WKWebView)"]
        Foundation["Foundation"]
    end

    subgraph External["External Dependencies"]
    style External fill:#FFF3E0,stroke:#E65100,stroke-width:1px
        MermaidCDN["Mermaid.js CDN<br/>(e.g., cdn.jsdelivr.net)"]
        Internet["Internet Connection"]
    end

    ContentView --> MermaidWebView
    MermaidWebView --> Coordinator

    MermaidWebView -- Depends On --> SwiftUI
    MermaidWebView -- Depends On --> WebKit

    Coordinator -- Depends On --> Foundation["NSObject from Foundation"]


    Coordinator -- Depends On --> WebKit["WKNavigationDelegate from WebKit"]

    SwiftUI -- Underlying --> UIKit["UIKit for UIViewRepresentable context"]

    WebKit -- Depends On --> Foundation

    WebKit -- Needs --> Internet["Internet for loading external resources"]

    WKWebView -- Fetches Resource --> MermaidCDN

    MermaidCDN -- Requires --> Internet

    classDef default stroke:#333,stroke-width:1px
    
```


*   **Explanation:** This diagram shows the layers of dependencies:
    *   **Your App:** Contains the specific SwiftUI Views (`ContentView`, `MermaidWebView`) and the `Coordinator`.
    *   **Apple Frameworks:** Your app relies heavily on SwiftUI, WebKit (for `WKWebView`), UIKit (needed for `UIViewRepresentable` and `WKWebView`), and Foundation (basic types).
    *   **External Dependencies:** The crucial external dependency is the Mermaid.js library hosted on a CDN. Accessing this CDN requires an active Internet connection for the `WKWebView`.


## 7. Adding Mermaid.js as a local bundle resource in iOS device

Download the raw Mermaid js package by following the CDN link below.
https://www.jsdelivr.com/package/npm/mermaid

Please note that you can switch versions through the dropdown box at the top right.

![Mermaid CDN dashboard](./Media/Mermaid_CDN_dashboard.png)

After download the Mermaid package, go the the package folder to get the raw file `mermaid.min.js`.

![Local_Mermaid_js_file](./Media/Local_Mermaid_js_file.png)


then, integrate the `mermaid.min.js` file into your Xcode project, following the steps below:

![Integrate_Mermaid_js_into_Xcode_project](./Media/Integrate_Mermaid_js_into_Xcode_project.png)


**Add to Project Bundle:** Include the downloaded `.js` file in your Xcode project and ensure it's part of your app target's "Copy Bundle Resources" build phase.

**Update HTML:** Modify the `<script src="...">` tag within the generated HTML to point to the *relative path* of the local `mermaid.min.js` file.

**Set Base URL:** When loading the HTML string into the `WKWebView`, provide the URL of the app's main bundle resource directory as the `baseURL`. This tells the `WKWebView` where to look for files referenced with relative paths (like `mermaid.min.js`).

---
**Licenses:**

- **MIT License:**  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) - Full text in [LICENSE](LICENSE) file.
- **Creative Commons Attribution 4.0 International:** [![License: CC BY 4.0](https://licensebuttons.net/l/by/4.0/88x31.png)](LICENSE-CC-BY) - Legal details in [LICENSE-CC-BY](LICENSE-CC-BY) and at [Creative Commons official site](http://creativecommons.org/licenses/by/4.0/).

---