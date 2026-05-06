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
    case course(id: String, enrollmentID: String)
    case file(courseID: String, fileID: String)
    case program(id: String)
    case learningLibrary(id: String)

    enum OfflinePathKey {
        static let root = "offline"
        static let course = "course"
        static let file = "file"
        static let program = "program"
        static let learningLibrary = "learningLibrary"
    }

    func path() -> String {
        switch self {
        case .course(let id, let enrollmentID):
            return "\(OfflinePathKey.root)/\(OfflinePathKey.course)/\(id)/\(enrollmentID)"

        case .file(let courseID, let fileID):
            return "\(OfflinePathKey.root)/\(OfflinePathKey.course)/\(courseID)/\(OfflinePathKey.file)/\(fileID)"

        case .program(let id):
            return "\(OfflinePathKey.root)/\(OfflinePathKey.program)/\(id)"

        case .learningLibrary(let id):
            return "\(OfflinePathKey.root)/\(OfflinePathKey.learningLibrary)/\(id)"
        }
    }

    static func parse(path: String) -> OfflineType? {
        var components = path.split(separator: "/").map(String.init).dropFirst(1)
        guard let type = components.popFirst() else { return nil }
        switch type {
        case OfflinePathKey.course:
            guard let courseID = components.popFirst() else { return nil }
            if components.first == OfflinePathKey.file {
                components.removeFirst()
                guard let fileID = components.first else { return nil }
                return .file(courseID: courseID, fileID: fileID)
            }
            // Old-format paths (pre-enrollmentID) have no 4th component; default to "".
            let enrollmentID = components.first ?? ""
            return .course(id: courseID, enrollmentID: enrollmentID)

        case OfflinePathKey.program:
            guard let id = components.first else { return nil }
            return .program(id: id)

        case OfflinePathKey.learningLibrary:
            guard let id = components.first else { return nil }
            return .learningLibrary(id: id)

        default:
            return nil
        }
    }
}
