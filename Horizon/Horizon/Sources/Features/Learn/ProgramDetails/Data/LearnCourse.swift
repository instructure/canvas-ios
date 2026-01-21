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

struct LearnCourse {
    let id: String
    let name: String
    let enrollmentId: String

    init(id: String, name: String, enrollmentId: String) {
        self.id = id
        self.name = name
        self.enrollmentId = enrollmentId
    }

    init?(from entity: CDHLearnCourse?) {
        guard let entity else {
            return nil
        }
        self.id = entity.id
        self.name = entity.name
        self.enrollmentId = entity.enrollmentId
    }
}
