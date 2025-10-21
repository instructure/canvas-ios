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
    enum FileDownloadViewAction: Equatable {
        case showDownloadAlert
        case showShareSheet(url: URL)
        case showErrorAlert
    }

    public let hideLoadingIndicator = PassthroughSubject<Void, Never>()
    public let fileDownloadViewAction = PassthroughSubject<FileDownloadViewAction, Never>()

    // MARK: - Inputs
    enum FileDownloadEvent {
        case started
        case completed(url: URL)
        case failed(error: Error)
    }

    public let fileDownloadEvent = PassthroughSubject<FileDownloadEvent, Never>()
    public let router: Router

    // MARK: - Private
    private let interactor: ParentSubmissionInteractor
    private var subscriptions = Set<AnyCancellable>()
    private weak var viewController: UIViewController?

    public init(
        interactor: ParentSubmissionInteractor,
        router: Router
    ) {
        self.interactor = interactor
        self.router = router

        fileDownloadEvent
            .sink { [weak self] event in
                self?.handleFileDownloadEvent(event)
            }
            .store(in: &subscriptions)
    }

    public func viewDidLoad(
        viewController: UIViewController,
        webView: WKWebView
    ) {
        self.viewController = viewController

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

    private func handleFileDownloadEvent(_ event: FileDownloadEvent) {
        switch event {
        case .started:
            fileDownloadViewAction.send(.showDownloadAlert)
        case .completed(let url):
            fileDownloadViewAction.send(.showShareSheet(url: url))
        case .failed(let error):
            RemoteLogger.shared.logError(name: "[ParentSubmissionViewModel] File download failed", reason: error.localizedDescription)
            fileDownloadViewAction.send(.showErrorAlert)
        }
    }
}
