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

import SwiftUI

enum FileVisibility: String, CaseIterable, Identifiable {
    case inheritCourse = "inherit"
    case courseMembers = "course"
    case institutionMembers = "institution"
    case publiclyAvailable = "public"

    var id: FileVisibility { self }
    var label: Text {
        switch self {
        case .inheritCourse: return Text("Inherit From Course")
        case .courseMembers: return Text("Course Members")
        case .institutionMembers: return Text("Institution Members")
        case .publiclyAvailable: return Text("Public")
        }
    }
    var isLastCase: Bool {
        Self.allCases.last == self
    }
}
