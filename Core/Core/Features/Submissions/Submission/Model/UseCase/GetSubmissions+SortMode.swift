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

import Foundation

// MARK: - Sort Mode

extension GetSubmissions {

    public enum SortMode: String, CaseIterable {
        case studentSortableName
        case studentName
        case submissionDate
        case submissionStatus

        public var name: String {
            switch self {
            case .studentSortableName:
                String(localized: "Student sortable name", bundle: .core)
            case .studentName:
                String(localized: "Student name", bundle: .core)
            case .submissionDate:
                String(localized: "Submission date", bundle: .core)
            case .submissionStatus:
                String(localized: "Submission status", bundle: .core)
            }
        }

        public var sortDescriptors: [NSSortDescriptor] {
            let descriptors: [NSSortDescriptor]

            switch self {
            case .studentSortableName:
                descriptors = [
                    NSSortDescriptor(key: #keyPath(Submission.user.sortableName), naturally: true),
                    NSSortDescriptor(key: #keyPath(Submission.sortableName), naturally: true) // In case of a group submission this is the name of the group
                ]
            case .studentName:
                descriptors = [
                    NSSortDescriptor(key: #keyPath(Submission.user.name), naturally: true)
                ]
            case .submissionDate:
                descriptors = [
                    NSSortDescriptor(key: #keyPath(Submission.submittedAt), ascending: true)
                ]
            case .submissionStatus:
                descriptors = [
                    NSSortDescriptor(key: #keyPath(Submission.workflowStateRaw), naturally: true)
                ]
            }

            return descriptors + [NSSortDescriptor(key: #keyPath(Submission.userID), naturally: true)]
        }

        public var typedSortDescriptors: [SortDescriptor<Submission>] {
            return sortDescriptors.compactMap { descriptor in
                SortDescriptor<Submission>(descriptor, comparing: Submission.self)
            }
        }

        public var query: String {
            return "sort=\(rawValue)"
        }
    }
}
