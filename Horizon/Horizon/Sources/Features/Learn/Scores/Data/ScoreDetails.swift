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

struct ScoreDetails {
    enum SortOption: String, CaseIterable {
        case dueDate
        case assignmentName

        var localizedTitle: String {
            switch self {
            case .dueDate:
                return String(localized: "Due Date", bundle: .horizon)
            case .assignmentName:
                return String(localized: "Assignment Name", bundle: .horizon)
            }
        }

        init(from string: String) {
            switch string {
            case String(localized: "Due Date", bundle: .horizon):
                self = .dueDate
            case String(localized: "Assignment Name", bundle: .horizon):
                self = .assignmentName
            default:
                self = .dueDate
            }
        }
    }

    let score: String
    let assignmentGroups: [ScoresAssignmentGroup]
    let sortOption: SortOption

    var assignments: [ScoresAssignment] {
        assignmentGroups.flatMap(\.assignments)
            .sorted { lhs, rhs in
                switch sortOption {
                case .dueDate:
                    return (lhs.dueAt ?? Date.distantFuture) < (rhs.dueAt ?? Date.distantFuture)
                case .assignmentName:
                    return lhs.name.lowercased() < rhs.name.lowercased()
                }
            }
    }

    func getAccessibilityDescription(isExpanded: Bool) -> String {
        var components: [String] = []

        // Total Score
        components.append(String.localizedStringWithFormat(
            String(localized: "Total: %@"),
            score
        ))

        if assignmentGroups.isAssignmentGroupWeightsVisible {
            // Header
            components.append(String(localized: "Assignment Group Weights"))

            // State
            let state = isExpanded ? String(localized: "Expanded") : String(localized: "Collapsed")
            components.append(state)

            // Hint for action
            let hint = isExpanded ? String(localized: "Tap to collapse") : String(localized: "Tap to expand")
            components.append(hint)
            if isExpanded {
                // Group details
                assignmentGroups.forEach { group in
                    if group.groupWeight != nil {
                        var groupComponents: [String] = [group.name]
                        if let weight = group.groupWeightString {
                            groupComponents.append(String.localizedStringWithFormat(
                                String(localized: "Weight: %@%%"),
                                weight
                            ))
                        }
                        components.append(groupComponents.joined(separator: ", "))
                    }
                }

                // Total Weight
                components.append(String.localizedStringWithFormat(
                    String(localized: "Total Weight: %@%%"),
                    assignmentGroups.groupWeightSumString
                ))
            }
        }
        return components.joined(separator: ". ")
    }
}
