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

import Combine
import Core
import Foundation

final class SplashViewModel: ObservableObject {
    // MARK: - Input

    private(set) var viewDidAppear = PassthroughSubject<Void, Never>()

    // MARK: - Private properties

    private let interactor: SessionInteractor
    private let router: Router
    private let environment: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()

    init(
        interactor: SessionInteractor,
        router: Router,
        environment: AppEnvironment = .shared
    ) {
        self.interactor = interactor
        self.router = router
        self.environment = environment

        unowned let unownedSelf = self

        viewDidAppear
            .delay(for: .milliseconds(500), scheduler: RunLoop.main)
            .flatMap { _ in
                interactor.refreshCurrentUserDetails()
                    .catch { unownedSelf.showErrorAlert(error: $0) }
            }
            .flatMap { unownedSelf.showLanguageAlertIfNeeded(locale: $0.locale) }
            .flatMap { unownedSelf.setBrandTheme() }
            .replaceError(with: ())
            .sink(receiveValue: { _ in
                router.setRootViewController(
                    isLoginTransition: true,
                    viewController: HorizonTabBarController()
                )
            })
            .store(in: &subscriptions)
    }

    private func showErrorAlert(error: Error) -> AnyPublisher<UserProfile, Error> {
        if error is LoginError {
            // replace window with login
            router.setRootViewController(
                isLoginTransition: false,
                viewController: LoginNavigationController.create(
                    loginDelegate: interactor,
                    app: .horizon
                )
            )
        } else {
            // show error alert
        }
        return Empty().setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    private func showLanguageAlertIfNeeded(locale: String?) -> AnyPublisher<Void, Error> {
        LocalizationManager.localizeForApp(
            UIApplication.shared,
            locale: locale
        )
        .flatMap { [weak self] languageAlert -> AnyPublisher<Void, Error> in
            if let languageAlert, let rootVC = self?.environment.window?.rootViewController {
                if let presented = rootVC.presentedViewController { // QR login alert
                    self?.router.dismiss(presented) {
                        self?.router.show(languageAlert, from: rootVC, options: .modal())
                    }
                } else {
                    self?.router.show(languageAlert, from: rootVC, options: .modal())
                }
                return Empty().setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    private func setBrandTheme() -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetBrandVariables())
            .getEntities()
            .compactMap { $0.first }
            .map { $0.applyBrandTheme() }
            .eraseToAnyPublisher()
    }
}
