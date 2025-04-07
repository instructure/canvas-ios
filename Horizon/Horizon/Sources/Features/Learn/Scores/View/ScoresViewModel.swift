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
import CombineExt
import Core
import Foundation
import Observation

@Observable
final class ScoresViewModel {
    enum ViewState {
        case loading
        case data
        case error
    }

    // MARK: - Outputs

    var selectedSortOption: String = ScoreDetails.SortOption.dueDate.localizedTitle {
        didSet {
            selectedFilterOptionRelay.accept(ScoreDetails.SortOption(from: selectedSortOption))
        }
    }

    private(set) var viewState: ViewState = .loading
    private(set) var scoreDetails: ScoreDetails?

    // MARK: - Dependencies

    private let interactor: ScoresInteractor
    private let router: Router

    // MARK: - Private properties

    private var selectedFilterOptionRelay = CurrentValueRelay(ScoreDetails.SortOption.dueDate)
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        interactor: ScoresInteractor,
        router: Router
    ) {
        self.interactor = interactor
        self.router = router

        weak var weakSelf = self

        selectedFilterOptionRelay
            .flatMap { sortedBy in
                self.interactor.getScores(sortedBy: sortedBy)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    weakSelf?.viewState = .error
                }

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
