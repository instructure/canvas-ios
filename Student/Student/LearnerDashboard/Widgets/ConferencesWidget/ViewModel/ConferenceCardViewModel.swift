//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Foundation

@Observable
final class ConferenceCardViewModel: Identifiable, Equatable {
    let id: String
    let title: String
    let contextName: String

    private let joinRoute: String
    private let joinUrl: URL?

    private let snackBarViewModel: SnackBarViewModel
    private let environment: AppEnvironment
    private let onDismiss: (String) -> Void

    init(
        model: ConferencesWidgetItem,
        snackBarViewModel: SnackBarViewModel,
        environment: AppEnvironment,
        onDismiss: @escaping (String) -> Void
    ) {
        self.id = model.id
        self.title = model.title
        self.contextName = model.contextName
        self.joinRoute = model.joinRoute
        self.joinUrl = model.joinUrl
        self.snackBarViewModel = snackBarViewModel
        self.environment = environment
        self.onDismiss = onDismiss
    }

    func didTapJoin(controller: WeakViewController) {
        if let joinUrl {
            environment.loginDelegate?.openExternalURL(joinUrl)
        } else {
            environment.router.route(to: joinRoute, from: controller, options: .modal())
        }
    }

    func didTapDismiss() {
        snackBarViewModel.showSnack(
            String(localized: "Dismissed \(title)", bundle: .student)
        )
        onDismiss(id)
    }

    static func == (lhs: ConferenceCardViewModel, rhs: ConferenceCardViewModel) -> Bool {
        lhs.id == rhs.id
        && lhs.title == rhs.title
        && lhs.contextName == rhs.contextName
        && lhs.joinRoute == rhs.joinRoute
        && lhs.joinUrl == rhs.joinUrl
    }
}
