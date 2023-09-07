import SwiftUI
import WebKit

public struct SUWebView: View {

    // MARK: - Properties -

    var configurator: WebViewConfigurator
    @State private var isContentLoaded: Bool = false
    var onLinkActivated: ((URL) -> Void)?

    // MARK: - Lifecycle -

    public var body: some View {
        ZStack {
            webViewRepresentable
            loadingView.hidden(isContentLoaded)
        }
    }

    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(1.5, anchor: .center)
    }

    @ViewBuilder
    private var webViewRepresentable: some View {
        SUWebViewRepresentable(
            configurator: configurator,
            onLoaded: $isContentLoaded,
            onLinkActivated: onLinkActivated
        )
    }
}
