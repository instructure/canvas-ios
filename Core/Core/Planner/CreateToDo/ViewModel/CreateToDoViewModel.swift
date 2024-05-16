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

final class CreateToDoViewModel: ObservableObject {

    // MARK: - Output

    let pageTitle = String(localized: "New To Do", bundle: .core)
    let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/new")
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    @Published var state: InstUI.ScreenState = .data
    @Published var title: String = ""
    @Published var date: Date?
    @Published var calendar: String? // ???
    @Published var details: String?

    // MARK: - Input

    let didTapCancel = PassthroughSubject<WeakViewController, Never>()
    let didTapDone = PassthroughSubject<WeakViewController, Never>()

    // MARK: - Private

    private let interactor: CreateToDoInteractor
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        interactor: CreateToDoInteractor,
        router: Router = AppEnvironment.shared.router
    ) {
        self.interactor = interactor

        didTapCancel
            .sink { router.dismiss($0) }
            .store(in: &subscriptions)

        didTapDone
            .sink { router.dismiss($0) }
            .store(in: &subscriptions)
    }

}
