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

import CombineSchedulers
import Combine
import Observation
import Foundation

@Observable
final class SkillListWidgetViewModel {
    enum ViewState: Equatable {
        case data
        case empty
        case error
        case loading
    }

    // MARK: - Outputs

    private(set) var state: ViewState = .loading
    private(set) var skills: [SkillCardModel] = []
    private(set) var countSkills: Int = 0

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()
    private let scheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Dependencies

    private let interactor: SkillWidgetInteractor

    // MARK: - Init

    init(
        interactor: SkillWidgetInteractor,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.scheduler = scheduler
        getSkills()
    }

    func getSkills(ignoreCache: Bool = false) {
        state = .loading
        interactor
            .getSkills(ignoreCache: ignoreCache)
            .receive(on: scheduler)
            .sinkFailureOrValue { [weak self] _ in
                self?.state = .error
            } receiveValue: { [weak self] skills in
                self?.countSkills = skills.count
                if skills.isEmpty {
                    self?.state = .empty
                } else {
                    self?.skills = Array(skills.prefix(5))
                    self?.state = .data
                }
            }
            .store(in: &subscriptions)
    }
}
