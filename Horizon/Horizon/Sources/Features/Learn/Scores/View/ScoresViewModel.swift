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

import Combine
import Core
import Observation

@Observable
final class ScoresViewModel {
    enum ViewState {
        case loading
        case data
        case error
    }

    // MARK: - Outputs

    private(set) var viewState: ViewState = .loading
    private(set) var scoreDetails: ScoreDetails?

    // MARK: - Dependencies

    private let router: Router

    // MARK: - Private properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        interactor: ScoresInteractor,
        router: Router
    ) {
        self.router = router

        weak var weakSelf = self

        interactor.getScores()
            .sink(receiveCompletion: { _ in

            }, receiveValue: { value in
                weakSelf?.viewState = .data
                weakSelf?.scoreDetails = value
            })
            .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func navigateToCourseDetails(url: URL?, viewController: WeakViewController) {
        guard let url else { return }
        router.route(to: url, from: viewController)
    }
}
