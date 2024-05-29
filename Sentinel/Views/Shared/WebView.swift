import SwiftUI
import WebKit
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}

struct WebKitView: UIViewRepresentable {
    var url: URL
    var onNavigate: ((String) -> Void)?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }

    // Coordinator to act as WKNavigationDelegate
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebKitView

        init(_ webView: WebKitView) {
            self.parent = webView
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                parent.onNavigate?(url.absoluteString)
            }
            decisionHandler(.allow)
        }
    }
}

struct WebView: View {
    let url: String
    var onNavigate: ((String) -> Void)?

    init(url: String, onNavigate: ((String) -> Void)? = nil) {
        self.url = url
        self.onNavigate = onNavigate
    }

    var body: some View {
        WebKitView(url: URL(string: url)!, onNavigate: onNavigate)
    }
}
