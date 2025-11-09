//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Core
import Combine
import WebKit

class ParentSubmissionViewController: UINavigationController {
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: ParentSubmissionViewModel
    private unowned let webView: WKWebView
    private weak var loadingIndicator: CircleProgressView?
    private weak var downloadAlert: UIAlertController?

    public init(viewModel: ParentSubmissionViewModel) {
        self.viewModel = viewModel

        let controller = CoreWebViewController(features: [.hideHideCanvasMenus])
        controller.addDoneButton()
        controller.setupBackToolbarButton()
        controller.title = String(localized: "Submission", bundle: .core)
        self.webView = controller.webView

        super.init(rootViewController: controller)

        controller.webView.linkDelegate = self

        addLoadingIndicator(to: controller.view)
        navigationBar.useModalStyle()
        modalPresentationCapturesStatusBarAppearance = true

        showLoadingIndicator()

        viewModel
            .hideLoadingIndicator
            .sink { [weak self] _ in
                self?.hideLoadingIndicator()
            }
            .store(in: &subscriptions)

        viewModel
            .fileDownloadViewAction
            .sink { [weak self] action in
                switch action {
                case .showDownloadAlert:
                    self?.showDownloadAlert()
                case .showShareSheet(let url):
                    self?.dismissDownloadAlert {
                        self?.showShareSheet(for: url)
                    }
                case .showErrorAlert:
                    self?.dismissDownloadAlert {
                        self?.showDownloadErrorAlert()
                    }
                }
            }
            .store(in: &subscriptions)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        viewModel.viewDidLoad(viewController: self, webView: webView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func showLoadingIndicator() {
        loadingIndicator?.startAnimating()
        webView.alpha = 0
    }

    private func hideLoadingIndicator() {
        UIView.animate(withDuration: 0.2) { [loadingIndicator, webView] in
            loadingIndicator?.alpha = 0
            webView.alpha = 1
        } completion: { [loadingIndicator] _ in
            loadingIndicator?.stopAnimating()
        }
    }

    private func addLoadingIndicator(to parent: UIView) {
        let progressView = CircleProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 40),
            progressView.heightAnchor.constraint(equalToConstant: 40),
            progressView.centerXAnchor.constraint(equalTo: parent.centerXAnchor, constant: 0),
            progressView.centerYAnchor.constraint(equalTo: parent.centerYAnchor, constant: 0)
        ])
        self.loadingIndicator = progressView
    }
}

// MARK: - CoreWebViewLinkDelegate

extension ParentSubmissionViewController: CoreWebViewLinkDelegate {

    func handleLink(_ url: URL) -> Bool {
        // Open all links inside the web view
        false
    }

    func coreWebView(_ webView: Core.CoreWebView, didStartDownloadAttachment attachment: CoreWebAttachment) {
        viewModel.fileDownloadEvent.send(.started)
    }

    func coreWebView(_ webView: Core.CoreWebView, didFinishAttachmentDownload attachment: CoreWebAttachment) {
        viewModel.fileDownloadEvent.send(.completed(url: attachment.url))
    }

    func coreWebView(_ webView: Core.CoreWebView, didFailAttachmentDownload attachment: CoreWebAttachment, with error: any Error) {
        viewModel.fileDownloadEvent.send(.failed(error: error))
    }
}

// MARK: - Download Alert

extension ParentSubmissionViewController {

    private func showDownloadAlert() {
        let alert = UIAlertController(
            title: String(localized: "Downloading", bundle: .parent),
            message: String(localized: "Please wait...", bundle: .parent),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: String(localized: "Cancel", bundle: .parent),
                style: .cancel,
                handler: { [weak webView] _ in
                    webView?.stopLoading()
                }
            )
        )

        downloadAlert = alert
        viewModel.router.show(alert, from: self, options: .modal())
    }

    private func dismissDownloadAlert(completion: @escaping () -> Void) {
        guard let downloadAlert else {
            completion()
            return
        }

        downloadAlert.dismiss(animated: true) {
            completion()
        }
        self.downloadAlert = nil
    }

    private func showDownloadErrorAlert() {
        let alert = UIAlertController(
            title: String(localized: "Download Failed", bundle: .parent),
            message: String(localized: "There was an error downloading the file. Please try again.", bundle: .parent),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: String(localized: "OK", bundle: .parent),
                style: .default
            )
        )
        viewModel.router.show(alert, from: self, options: .modal())
    }

    private func showShareSheet(for url: URL) {
        let shareSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let popover = shareSheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        let routeOptions = RouteOptions.modal(
            .pageSheet,
            isDismissable: true
        )
        viewModel.router.show(shareSheet, from: self, options: routeOptions)
    }

    var coreWebViewFeaturesContext: Context? { nil }
}
