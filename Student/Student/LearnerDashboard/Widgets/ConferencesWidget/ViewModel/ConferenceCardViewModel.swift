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
    let context: Context
    let joinURL: URL?
    private let environment: AppEnvironment
    private let snackBarViewModel: SnackBarViewModel
    private let onDismiss: (String) -> Void

    var joinRoute: String {
        "\(context.pathComponent)/conferences/\(id)/join"
    }

    init(
        id: String,
        title: String,
        contextName: String,
        context: Context,
        joinURL: URL?,
        environment: AppEnvironment,
        snackBarViewModel: SnackBarViewModel,
        onDismiss: @escaping (String) -> Void
    ) {
        self.id = id
        self.title = title
        self.contextName = contextName
        self.context = context
        self.joinURL = joinURL
        self.environment = environment
        self.snackBarViewModel = snackBarViewModel
        self.onDismiss = onDismiss
    }

    func join() {
        if let joinURL {
            environment.loginDelegate?.openExternalURL(joinURL)
        }
    }

    func dismiss() {
        snackBarViewModel.showSnack(
            String(localized: "Dismissed \(title)", bundle: .student)
        )
        onDismiss(id)
    }

    static func == (lhs: ConferenceCardViewModel, rhs: ConferenceCardViewModel) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.contextName == rhs.contextName &&
        lhs.joinURL == rhs.joinURL
    }
}
