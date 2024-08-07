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

class ParentSubmissionViewModel {
    // MARK: - Outputs
    public let hideLoadingIndicator = PassthroughSubject<Void, Never>()
    public let showWebBackNavigationButton = CurrentValueSubject<Bool, Never>(false)

    // MARK: - Inputs
    public let didTapNavigateWebBackButton = PassthroughSubject<Void, Never>()

    // MARK: - Private
    private let interactor: ParentSubmissionInteractor
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()
    private weak var viewController: UIViewController?

    public init(
        interactor: ParentSubmissionInteractor,
        router: Router
    ) {
        self.interactor = interactor
        self.router = router
    }

    public func viewDidLoad(
        viewController: UIViewController,
        webView: WKWebView
    ) {
        self.viewController = viewController

        handleWebBackButtonTap(webView: webView)
        showBackNavigationButtonIfWebViewCanGoBack(webView: webView)
        handleFeedbackViewLoadResult(viewController: viewController, webView: webView)
    }

    private func handleFeedbackViewLoadResult(
        viewController: UIViewController,
        webView: WKWebView
    ) {
        interactor
            .loadParentFeedbackView(webView: webView)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished: self?.hideLoadingIndicator.send(())
                case .failure: self?.showAlert(viewController: viewController)
                }

            } receiveValue: { _ in }
            .store(in: &subscriptions)
    }

    private func handleWebBackButtonTap(
        webView: WKWebView
    ) {
        didTapNavigateWebBackButton
            .sink { [weak webView] in
                webView?.goBack()
            }
            .store(in: &subscriptions)
    }

    private func showBackNavigationButtonIfWebViewCanGoBack(
        webView: WKWebView
    ) {
        webView
            .publisher(for: \.canGoBack)
            .sink { [weak showWebBackNavigationButton] canGoBack in
                showWebBackNavigationButton?.send(canGoBack)
            }
            .store(in: &subscriptions)
    }

    private func showAlert(viewController: UIViewController?) {
        guard let viewController else { return }

        let alert = UIAlertController(
            title: String(localized: "Something went wrong", bundle: .core),
            message: String(localized: "There was an error while communicating with the server", bundle: .core),
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: String(localized: "OK", bundle: .core),
                style: .default,
                handler: { _ in
                    viewController.dismiss(animated: true, completion: nil)
                }
            )
        )
        router.show(alert, from: viewController, options: .modal())
    }
}
