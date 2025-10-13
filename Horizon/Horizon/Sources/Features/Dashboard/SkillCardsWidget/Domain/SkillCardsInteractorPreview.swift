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

#if DEBUG
import Combine

final class SkillCardsInteractorPreview: SkillWidgetInteractor {
    func getSkills(ignoreCache: Bool) -> AnyPublisher<[SkillCardModel], Error> {
        Just(
            [
                .init(id: "1", title: "Skill 1", status: "expert"),
                .init(id: "2", title: "Skill 2", status: "advanced"),
                .init(id: "3", title: "Skill 3", status: "beginner")
            ]
        )
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
}
#endif
