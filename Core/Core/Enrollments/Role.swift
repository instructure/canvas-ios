//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public enum Role: RawRepresentable {
    case custom(String)
    case designer
    case observer
    case student
    case ta
    case teacher

    public var rawValue: String {
        switch self {
        case .ta: return "TaEnrollment"
        case .teacher: return "TeacherEnrollment"
        case .student: return "StudentEnrollment"
        case .observer: return "ObserverEnrollment"
        case .designer: return "DesignerEnrollment"
        case .custom(let role): return role
        }
    }

    public init?(rawValue: String) {
        switch rawValue {
        case "StudentEnrollment":
            self = .student
        case "TeacherEnrollment":
            self = .teacher
        case "TaEnrollment":
            self = .ta
        case "ObserverEnrollment":
            self = .observer
        case "DesignerEnrollment":
            self = .designer
        default:
            self = .custom(rawValue)
        }
    }

    public func description() -> String {
        switch self {
        case .student:
            return String(localized: "Student", bundle: .core)
        case .teacher:
            return String(localized: "Teacher", bundle: .core)
        case .ta:
            return String(localized: "TA", bundle: .core, comment: "Teacher's Assistant (abbreviated)")
        case .observer:
            return String(localized: "Observer", bundle: .core)
        case .designer:
            return String(localized: "Designer", bundle: .core)
        case .custom(let role):
            return role
        }
    }
}

extension Role: Equatable {
    public static func == (lhs: Role, rhs: Role) -> Bool {
        switch (lhs, rhs) {
        case (.ta, ta): return true
        case (.teacher, .teacher): return true
        case (.student, .student): return true
        case (.observer, .observer): return true
        case (.designer, .designer): return true
        case let (.custom(lhs), .custom(rhs)): return lhs == rhs
        default: return false
        }
    }
}
