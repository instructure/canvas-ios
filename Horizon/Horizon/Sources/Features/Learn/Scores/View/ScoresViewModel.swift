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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(
        interactor: ScoresInteractor,
        router: Router
    ) {
        self.interactor = interactor
        self.router = router

        listenForFilterChange()
        listenForForceRefresh()
    }

    private func listenForFilterChange() {
        unowned let unownedSelf = self

        selectedFilterOptionRelay
            .dropFirst() // Using dropFirst because we already triggered courseDetailsForceRefreshed via NotificationCenter to avoid duplication.
            .flatMap { filter in
                unownedSelf.interactor.getScores(
                    sortedBy: filter,
                    ignoreCache: false
                )
                .catch { _ in
                    unownedSelf.viewState = .error
                    return Empty<ScoreDetails, Error>().eraseToAnyPublisher()
                }
            }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { value in
                    unownedSelf.viewState = .data
                    unownedSelf.scoreDetails = value
                }
            )
            .store(in: &subscriptions)
    }

    private func listenForForceRefresh() {
        unowned let unownedSelf = self

        Publishers.CombineLatest(
            NotificationCenter.default
                .publisher(for: .moduleItemRequirementCompleted)
                .prepend(
                    .init(
                        name: .moduleItemRequirementCompleted,
                        object: ModuleItemAttributes(
                            courseID: unownedSelf.interactor.courseID,
                            moduleID: "",
                            itemID: ""
                        )
                    )
                )
                .compactMap { $0.object as? ModuleItemAttributes }
                .map { $0.courseID }
                .filter { $0 == unownedSelf.interactor.courseID },
            NotificationCenter.default
                .publisher(for: .courseDetailsForceRefreshed)
                .prepend(.init(name: .courseDetailsForceRefreshed))
        )
        .flatMap { _ in
            unownedSelf.interactor.getScores(
                sortedBy: unownedSelf.selectedFilterOptionRelay.value,
                ignoreCache: true
            )
            .catch { _ in
                unownedSelf.viewState = .error
                return Empty<ScoreDetails, Error>().eraseToAnyPublisher()
            }
        }
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { value in
                unownedSelf.viewState = .data
                unownedSelf.scoreDetails = value
            }
        )
        .store(in: &subscriptions)
    }

    // MARK: - Inputs

    func navigateToCourseDetails(url: URL?, viewController: WeakViewController) {
        guard let url else { return }
        router.route(to: url, from: viewController)
    }
}
