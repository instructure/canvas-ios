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
import Foundation

struct SubmissionsSortComparator: SortComparator {

    let mode: SubmissionsSortMode
    var order: SortOrder

    func compare(_ lhs: Core.Submission, _ rhs: Core.Submission) -> ComparisonResult {
        let sub1KindOrder = SubmissionListSection.Kind(submission: lhs).position
        let sub2KindOrder = SubmissionListSection.Kind(submission: rhs).position

        if sub1KindOrder != sub2KindOrder {
            return sub1KindOrder < sub2KindOrder ? .orderedAscending : .orderedDescending
        }

        for descriptor in sortDescriptors {
            let result = descriptor.compare(lhs, rhs)
            if result != .orderedSame {
                return result
            }
        }

        return .orderedSame
    }

    private var sortDescriptors: [SortDescriptor<Submission>] {
        return mode.typedSortDescriptors.map({ descriptor in
            var tweaked = descriptor
            tweaked.order = order
            return tweaked
        })
    }
}

extension SortComparator where Self == SubmissionsSortComparator {
    static func submissionsComparator(mode: SubmissionsSortMode) -> SubmissionsSortComparator {
        SubmissionsSortComparator(mode: mode, order: .forward)
    }
}

// MARK: Convenience Extensions

extension Array where Element == Submission {

    func toSectionedItems(assignment: Assignment?) -> [SubmissionListSection] {
        let submissionsPerKind = Dictionary(grouping: self) {
            SubmissionListSection.Kind(submission: $0)
        }

        var displayIndex = 0
        let sections = SubmissionListSection.Kind.allCases
            .compactMap { kind -> SubmissionListSection? in
                guard let submissions = submissionsPerKind[kind]?.nilIfEmpty else { return nil }

                let items = submissions.map { submission in
                    displayIndex += 1
                    return SubmissionListItem(
                        submission: submission,
                        assignment: assignment,
                        displayIndex: displayIndex
                    )
                }

                return SubmissionListSection(kind: kind, items: items)
            }

        return sections
    }
}
