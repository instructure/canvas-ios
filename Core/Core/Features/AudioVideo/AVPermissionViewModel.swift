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

import Foundation
import UIKit

public struct AVPermissionViewModel {
    private let interactor: AVPermissionInteractor
    private let env: AppEnvironment

    public init(
        interactor: AVPermissionInteractor = AVPermissionInteractorLive(),
        env: AppEnvironment = .shared
    ) {
        self.interactor = interactor
        self.env = env
    }

    // MARK: - Main methods

    public func performAfterCameraPermission(from viewController: WeakViewController, action: @escaping () -> Void) {
        if let isPermitted = interactor.isCameraPermitted {
            cameraPermissionHandler(isPermitted, from: viewController, action: action)
        } else {
            interactor.requestCameraPermission { isPermitted in
                performUIUpdate {
                    cameraPermissionHandler(isPermitted, from: viewController, action: action)
                }
            }
        }
    }

    public func performAfterMicrophonePermission(from viewController: WeakViewController, action: @escaping () -> Void) {
        if let isPermitted = interactor.isMicrophonePermitted {
            microphonePermissionHandler(isPermitted, from: viewController, action: action)
        } else {
            interactor.requestMicrophonePermission { isPermitted in
                performUIUpdate {
                    microphonePermissionHandler(isPermitted, from: viewController, action: action)
                }
            }
        }
    }

    public func performAfterVideoPermissions(from viewController: WeakViewController, action: @escaping () -> Void) {
        performAfterCameraPermission(from: viewController) {
            performAfterMicrophonePermission(from: viewController, action: action)
        }
    }

    // MARK: - Permission handlers

    private func cameraPermissionHandler(
        _ isPermitted: Bool,
        from viewController: WeakViewController,
        action: @escaping () -> Void
    ) {
        if isPermitted {
            action()
        } else {
            showCameraPermissionError(from: viewController)
        }
    }

    private func microphonePermissionHandler(
        _ isPermitted: Bool,
        from viewController: WeakViewController,
        action: @escaping () -> Void
    ) {
        if isPermitted {
            action()
        } else {
            showMicrophonePermissionError(from: viewController)
        }
    }

    // MARK: - Permission error dialogs

    private func showCameraPermissionError(from viewController: WeakViewController) {
        showPermissionError(
            message: String(localized: "You must enable Camera permissions in Settings.", bundle: .core),
            from: viewController
        )
    }

    private func showMicrophonePermissionError(from viewController: WeakViewController) {
        showPermissionError(
            message: String(localized: "You must enable Microphone permissions in Settings.", bundle: .core),
            from: viewController
        )
    }

    private func showPermissionError(message: String, from viewController: WeakViewController) {
        let alert = UIAlertController(
            title: String(localized: "Permission Needed", bundle: .core),
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            AlertAction(String(localized: "Settings", bundle: .core), style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                env.loginDelegate?.openExternalURL(url)
            }
        )

        alert.addAction(
            AlertAction(String(localized: "Cancel", bundle: .core), style: .cancel)
        )

        env.router.show(alert, from: viewController, options: .modal())
    }
}
