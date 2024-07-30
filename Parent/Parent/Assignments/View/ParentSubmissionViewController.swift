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

class ParentSubmissionViewController: UINavigationController, ErrorViewController {
    private var subscriptions = Set<AnyCancellable>()
    private let interactor: ParentSubmissionInteractor
    private unowned let webView: WKWebView
    private weak var loadingIndicator: CircleProgressView?

    public init(interactor: ParentSubmissionInteractor) {
        self.interactor = interactor

        let controller = CoreWebViewController()
        controller.addDoneButton()
        controller.title = String(localized: "Submission", bundle: .core)
        self.webView = controller.webView

        super.init(rootViewController: controller)

        addLoadingIndicator(to: controller.view)
        navigationBar.useModalStyle()
        modalPresentationCapturesStatusBarAppearance = true

        showLoadingIndicator()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        interactor
            .loadParentFeedbackView(webView: webView)
            .sink { [weak self] completion in
                switch completion {
                case .finished: self?.hideLoadingIndicator()
                case .failure: self?.showAlert()
                }

            } receiveValue: { _ in }
            .store(in: &subscriptions)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func showLoadingIndicator() {
        loadingIndicator?.startAnimating()
        webView.alpha = 0
    }

    private func showAlert() {
        let alert = UIAlertController(
            title: String(localized: "Something went wrong", bundle: .core),
            message: String(localized: "There was an error while communicating with the server", bundle: .core),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: String(localized: "OK", bundle: .core),
                style: .default,
                handler: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                }
            )
        )
        AppEnvironment.shared.router.show(alert, from: self, options: .modal())
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
