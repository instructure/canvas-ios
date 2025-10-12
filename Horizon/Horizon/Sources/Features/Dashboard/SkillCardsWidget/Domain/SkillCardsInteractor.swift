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

import Core
import Combine
import Foundation

protocol SkillCardsInteractor {
    func getSkills(ignoreCache: Bool) -> AnyPublisher<[SkillCardModel], Error>
}

final class SkillCardsInteractorLive: SkillCardsInteractor {
    // MARK: - Dependencies

    private let skillUseCase: GetHSkillsUseCase

    // MARK: - Init

    init(skillUseCase: GetHSkillsUseCase = GetHSkillsUseCase()) {
        self.skillUseCase = skillUseCase
    }

    func getSkills(ignoreCache: Bool) -> AnyPublisher<[SkillCardModel], Error> {
        ReactiveStore(useCase: skillUseCase)
            .getEntities(ignoreCache: ignoreCache)
            .map { skills in
                let proficiencyOrder: [String] = ProficiencyLevel.allCases.map(\.rawValue)
                let sortedSkills = skills.sorted { lhs, rhs in
                    guard
                        let lhsIndex = proficiencyOrder.firstIndex(of: lhs.proficiencyLevel),
                        let rhsIndex = proficiencyOrder.firstIndex(of: rhs.proficiencyLevel)
                    else {
                        return false
                    }
                    return lhsIndex < rhsIndex
                }
                return sortedSkills.map {
                    SkillCardModel(id: $0.id, title: $0.name, status: $0.proficiencyLevel)
                }
            }
            .eraseToAnyPublisher()
    }
}
