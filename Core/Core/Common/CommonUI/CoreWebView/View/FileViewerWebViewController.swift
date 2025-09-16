//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import UIKit
import WebKit

// We use this controller to render file links pointing directly to canvas-user-content.com. These links need a session cookie to work,
// which we can provide via WKWebView and its shared cookie store.
public class FileViewerWebViewController: UIViewController {
    let url: URL
    private let webView: WKWebView
    private weak var progressIndicator: CircleProgressView?

    public init(url: URL) {
        self.url = url
        self.webView = WKWebView(
            frame: .zero,
            configuration: .defaultConfiguration
        )
        super.init(nibName: nil, bundle: nil)
        webView.navigationDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadURL()
    }

    private func setupUI() {
        navigationController?.navigationBar.useStyle(.global)
        view.backgroundColor = .backgroundLightest
        navigationItem.title = String(
            localized: "File Viewer",
            bundle: .core,
            comment: "Title for a screen that displays the contents of a file"
        )

        view.addSubview(webView)
        webView.pin(inside: self.view)

        addProgressIndicator()
        showProgressIndicator()
    }

    private func addProgressIndicator() {
        let progressView = CircleProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalToConstant: 40),
            progressView.heightAnchor.constraint(equalToConstant: 40),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        self.progressIndicator = progressView
    }

    private func showProgressIndicator() {
        progressIndicator?.startAnimating()
        webView.alpha = 0
    }

    private func hideProgressIndicator() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.progressIndicator?.alpha = 0
            self?.webView.alpha = 1
        } completion: { [weak self] _ in
            self?.progressIndicator?.stopAnimating()
        }
    }

    private func loadURL() {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func showError(_ error: Error) {
        hideProgressIndicator()

        let alert = UIAlertController(
            title: String(localized: "Failed to load file", bundle: .core),
            message: error.localizedDescription,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: String(localized: "OK", bundle: .core),
            style: .default
        ) { [weak self] _ in
            self?.dismiss(animated: true)
        })

        present(alert, animated: true)
    }
}

extension FileViewerWebViewController: WKNavigationDelegate {

    public func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        hideProgressIndicator()
    }

    public func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        showError(error)
    }

    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        showError(error)
    }
}

#if DEBUG

#Preview {
    CoreNavigationController(rootViewController: FileViewerWebViewController(url: URL(string: "/")!))

}

#endif
