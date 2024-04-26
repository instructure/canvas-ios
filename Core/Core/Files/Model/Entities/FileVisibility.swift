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

public enum FileVisibility: String, CaseIterable, Identifiable {
    case inheritCourse = "inherit"
    case courseMembers = "context"
    case institutionMembers = "institution"
    case publiclyAvailable = "public"

    public var id: FileVisibility { self }
    public var label: String {
        switch self {
        case .inheritCourse: return String(localized: "Inherit From Course", bundle: .core)
        case .courseMembers: return String(localized: "Course Members", bundle: .core)
        case .institutionMembers: return String(localized: "Institution Members", bundle: .core)
        case .publiclyAvailable: return String(localized: "Public", bundle: .core)
        }
    }
    public var isLastCase: Bool {
        Self.allCases.last == self
    }
}
