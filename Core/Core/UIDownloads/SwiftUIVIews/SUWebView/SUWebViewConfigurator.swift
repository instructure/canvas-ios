import WebKit

public struct WebViewConfigurator {
    var requestType: RequestType
}

public extension WebViewConfigurator {
    enum RequestType {
        case url(URL)
        case indexURL(_ url: URL,_ allowingReadAccessTo: URL)
        case request(URLRequest)
    }
}

// MARK: - Parameters -

extension WebViewConfigurator {
    var webViewConfiguration: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        return configuration
    }
}
