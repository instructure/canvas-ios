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
import CombineExt
import Foundation

final class GradeListViewModel: ObservableObject {
    enum ViewState {
        case loading
        case data(GradeListData)
        case empty
        case error
    }

    // MARK: - Dependencies

    private let interactor: GradeListInteractorLive

    // MARK: - Output

    @Published private(set) var state: ViewState = .loading

    // MARK: - Input

    let selectedGradingPeriod = PassthroughRelay<GradingPeriod?>()
    let sortByAscendingOrder = CurrentValueRelay(true)

    // MARK: - Private properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(interactor: GradeListInteractorLive) {
        self.interactor = interactor

        sortByAscendingOrder
            .flatMap {
                interactor.getGrades(byAscendingOrder: $0).map {
                    if $0.assignmentSections.count == 0 {
                        return ViewState.empty
                    } else {
                        return ViewState.data($0)
                    }
                }
            }
            .replaceError(with: .error)
            .assign(to: &$state)

        selectedGradingPeriod
            .flatMap { interactor.updateGradingPeriod(id: $0?.id) }
            .sink()
            .store(in: &subscriptions)
    }

    public func refresh(completion: @escaping () -> Void) {
        interactor
            .refresh()
            .sink { _ in
                completion()
            }
            .store(in: &subscriptions)
    }
}
