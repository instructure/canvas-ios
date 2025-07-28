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

    var order: SortOrder

    func compare(_ lhs: Core.Submission, _ rhs: Core.Submission) -> ComparisonResult {
        let sub1KindOrder = lhs.listSectionKind.order
        let sub2KindOrder = rhs.listSectionKind.order

        if sub1KindOrder != sub2KindOrder {
            return sub1KindOrder < sub2KindOrder ? inOrder : againstOrder
        }

        // This is to match ordering of submission as
        // they are being fetched to submission list
        // via GetSubmissions use case.
        if lhs != rhs {
            return lhs < rhs ? inOrder : againstOrder
        }

        return .orderedSame
    }

    private var inOrder: ComparisonResult {
        order == .forward ? .orderedAscending : .orderedDescending
    }

    private var againstOrder: ComparisonResult {
        order == .forward ? .orderedDescending : .orderedAscending
    }
}

// MARK: Convenience Extensions

extension Array where Element == Submission {

    func toSectionedItems(assignment: Assignment? = nil) -> [SubmissionListSection] {
        let list = sorted(using: .submissionsSortComparator)

        var displayIndex = 0
        return Dictionary(grouping: list, by: { $0.listSectionKind })
            .sorted(by: { $0.key.order < $1.key.order })
            .filter { $0.value.isNotEmpty }
            .map { (kind, submissions) in
                SubmissionListSection(
                    kind: kind,
                    items: submissions.map { sub in
                        displayIndex += 1
                        return SubmissionListItem(submission: sub, assignment: assignment, displayIndex: displayIndex)
                    }
                )
            }
    }
}

extension SortComparator where Self == SubmissionsSortComparator {
    static var submissionsSortComparator: Self {
        SubmissionsSortComparator(order: .forward)
    }
}

// MARK: Sorting Helper Extensions

private extension SubmissionListSection.Kind {
    var order: Int { return Self.allCases.firstIndex(of: self) ?? -1 }
}

extension Submission {
    var listSectionKind: SubmissionListSection.Kind {
        SubmissionListSection.Kind
            .allCases
            .first(where: { $0.filter(self) }) ?? .others
    }
}
