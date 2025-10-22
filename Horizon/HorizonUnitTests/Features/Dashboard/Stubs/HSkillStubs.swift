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

@testable import Core
@testable import Horizon

enum HSkillStubs {
    static let token = "test_token"
    static let response = GetHSkillResponse(
        data: .init(
            skills: [
                .init(id: "1", name: "Skill 1", proficiencyLevel: "expert"),
                .init(id: "2", name: "Skill 2", proficiencyLevel: "proficient"),
                .init(id: "3", name: "Skill 3", proficiencyLevel: "beginner"),
                .init(id: "4", name: "Skill 4", proficiencyLevel: "proficient"),
                .init(id: "5", name: "Skill 5", proficiencyLevel: "beginner"),
                .init(id: "6", name: "Skill 6", proficiencyLevel: "advanced")
            ]
        )
    )

    static let skills: [SkillWidgetModel] = [
        .init(id: "1", title: "Skill 1", status: "expert"),
        .init(id: "2", title: "Skill 2", status: "proficient"),
        .init(id: "3", title: "Skill 3", status: "beginner"),
        .init(id: "4", title: "Skill 4", status: "proficient"),
        .init(id: "5", title: "Skill 5", status: "beginner"),
        .init(id: "6", title: "Skill 6", status: "advanced")
    ]
}
