//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import SwiftUI

public struct PrimaryButton<Label>: View where Label: View {

    let action: () -> Void
    let label: Label
    @ObservedObject private var offlineServiceModel: OfflineModeViewModel
    private let isAvailableOffline: Bool

    public init(viewModel: OfflineModeViewModel = OfflineModeViewModel(interactor: OfflineModeInteractorLive.shared),
                isAvailableOffline: Bool = false,
                action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.offlineServiceModel = viewModel
        self.isAvailableOffline = isAvailableOffline
        self.action = action
        self.label = label()
    }

    public var body: some View {
        let unavailable = !isAvailableOffline && offlineServiceModel.isOffline
        Button {
            if unavailable {
                showAlert()
            } else {
                action()
            }
        } label: {
            label
        }
        .opacity(unavailable ? 0.3 : 1.0)
    }

    private func showAlert() {
        let title = NSLocalizedString("Offline mode", comment: "")
        let message = NSLocalizedString("This item is not available offline.", comment: "")
        let action = NSLocalizedString("OK", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default))

        if let top = AppEnvironment.shared.topViewController {
            AppEnvironment.shared.router.show(alert, from: top, options: .modal())
        }
    }
}
