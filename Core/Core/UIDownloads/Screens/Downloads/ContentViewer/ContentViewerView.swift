import Combine
import SwiftUI
import mobile_offline_downloader_ios
import PDFKit

public struct ContentViewerView: View, Navigatable {

    // MARK: - Injected -

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.openURL) var openURL

    // MARK: - Properties -

    @StateObject private var viewModel: ContentViewerViewModel

    @State private var url: URL? {
        didSet {
            isActiveWebView = true
        }
    }
    @State private var isActiveWebView: Bool = false

    init(
        entry: OfflineDownloaderEntry,
        courseDataModel: CourseStorageDataModel,
        onDeleted: ((OfflineDownloaderEntry) -> Void)? = nil
    ) {
        let model = ContentViewerViewModel(
            entry: entry,
            courseDataModel: courseDataModel,
            onDeleted: onDeleted
        )
        self._viewModel = .init(wrappedValue: model)
    }

    // MARK: - Views -

    public var body: some View {
        viewModel.requestType.flatMap { type in
            SUWebView(
                configurator: .init(
                    requestType: type
                ),
                onLinkActivated: { url in
                    if url.scheme?.contains("http") == true {
                        openURL(url)
                        return
                    }

                    if UIDevice.current.userInterfaceIdiom == .pad {
                        self.url = url
                    } else {
                        onLinkActivated(url)
                    }
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.title)
                        .foregroundColor(.white)
                        .font(.semibold16)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if viewModel.canShare {
                        Button {
                            share()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        }
                        .foregroundColor(.white)
                    }
                    Button {
                        viewModel.delete()
                    } label: {
                        Image(systemName: "trash.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .foregroundColor(.white)
                }
            }
            .if(UIDevice.current.userInterfaceIdiom == .pad) { view in
                view.background(
                    NavigationLink(
                        destination: destination,
                        isActive: $isActiveWebView
                    ) {
                        SwiftUI.EmptyView()
                    }.hidden()
                )
            }
            .onReceive(viewModel.viewDismissalModePublisher) { shouldDismiss in
                if shouldDismiss {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .if(UIDevice.current.userInterfaceIdiom == .pad) { view in
                view.introspect(.viewController, on: .iOS(.v13, .v14, .v15, .v16, .v17)) {
                    $0.navigationController?.navigationBar.prefersLargeTitles = false
                    $0.navigationController?.navigationBar.tintColor = .white
                }
            }
        }
    }

    @ViewBuilder
    private var destination: some View {
        if let url = url, url.scheme?.contains("file") == true {
            if DocViewerViewController.hasPSPDFKitLicense {
                DocViewer(
                    filename: url.lastPathComponent,
                    previewURL: url,
                    fallbackURL: url
                )
            } else {
                CoreWebViewRepresentable(url: url)
            }
        }
    }

    private func onLinkActivated(_ url: URL) {
        if url.scheme?.contains("file") == true {
            guard DocViewerViewController.hasPSPDFKitLicense else {
                webView(for: url)
                return
            }
            let root = DocViewer(
                filename: url.lastPathComponent,
                previewURL: url,
                fallbackURL: url
            )
            let hosting = CoreHostingController(root)
            navigationController?.pushViewController(hosting, animated: true)
        }
    }

    func webView(for url: URL, isLocalURL: Bool = true) {
        let webView = CoreWebViewRepresentable(url: url)
        let hosting = CoreHostingController(webView)
        navigationController?.pushViewController(hosting, animated: true)
    }

    func share() {
        guard case .url(let url) = viewModel.requestType  else {
           return
        }
        let controller = CoreActivityViewController(activityItems: [url], applicationActivities: nil)
        navigationController?.present(controller, animated: true)
    }
}
