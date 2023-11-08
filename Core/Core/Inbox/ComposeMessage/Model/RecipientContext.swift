//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Foundation

public class RecipientContext {
    let id: String
    let name: String
    let contextType: ContextType

    init(_ course: Course) {
        self.id = course.id
        self.name = course.name ?? course.courseCode ?? ""
        self.contextType = .course
    }

    init(_ group: Group) {
        self.id = group.id
        self.name = group.name
        self.contextType = .group
    }

    func getContext() -> Context {
        return switch contextType {
        case .course:
            Context.course(id)
        case .group:
            Context.group(id)
        default:
            Context.course(id)
        }
    }
}
