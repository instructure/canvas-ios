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

import Foundation

public enum BaseEnrollmentType: String, CaseIterable {
    case designer, observer, student, ta, teacher

    var name: String {
        switch self {
        case .designer:
            return String(localized: "Designers", bundle: .core)
        case .observer:
            return String(localized: "Observers", bundle: .core)
        case .student:
            return String(localized: "Students", bundle: .core)
        case .ta:
            return String(localized: "Teaching Assistants", bundle: .core)
        case .teacher:
            return String(localized: "Teachers", bundle: .core)
        }
    }
}
