//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

enum OfflineType {
    case course
    case file(courseID: String)
    case program
    case learningLibrary
    func path(for id: String) -> String {
        switch self {
        case .course:
            return "offline/course/\(id)"
        case .file(let courseID):
            return "offline/course/\(courseID)/file/\(id)"
        case .program:
            return "offline/program/\(id)"
        case .learningLibrary:
            return "offline/learningLibrary/\(id)"
        }
    }
}
