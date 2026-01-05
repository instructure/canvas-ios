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

import HorizonUI
import Foundation

enum CourseDetailsAccessibility {
    static func moduleItem(
        item: HModuleItem,
        type: HorizonUI.LearningObjectItem.ItemType
    ) -> String {
        var components: [String] = []
        components.append(item.title)

        if let status = item.status {
            switch status {
            case .completed:
                components.append(
                    String(
                        format: String(localized: "Status is %@ "),
                        String(localized: "Completed")
                    )
                )
            case .locked:
                components
                    .append(
                        String(
                            format: String(localized: "Status is %@ "),
                            String(localized: "Locked")
                        )
                    )
            }
        }

        components.append(String(format: String(localized: "Type is %@"), type.name))

        if !item.statusDescription.isEmpty {
            components.append(item.statusDescription)
        }

        if let duration = item.estimatedDurationFormatted {
            components.append(String(localized: "Duration: \(duration)"))
        }

        if let dueDate = item.dueAt?.formatted(format: "MM/dd") {
            let dueText = item.isOverDue
            ? String(localized: "Past Due date is")
            : String(localized: "Due date is")
            components.append("\(dueText): \(dueDate)")
        }

        if let points = item.points?.trimmedString {
            components.append(String(format: String(localized: "Number of points is %@"), points))
        }

        if let lockedMessage = item.lockedMessage, item.status == .locked {
            components.append(lockedMessage)
        }

        return components.joined(separator: ". ")
    }

    static func moduleContainer(
        module: HModule,
        status: HorizonUI.ModuleContainer.Status,
        isCollapsed: Bool
    ) -> String {
        var components: [String] = []

        components.append(module.name)
        components.append(String(format: String(localized: "Status is %@"), status.title))

        if let subtitle = module.moduleStatus.subHeader {
            components.append(subtitle)
        }

        components.append(String(format: String(localized: "Count of items is %d"), module.contentItems.count))

        if module.dueItemsCount > 0 {
            components.append(String(format: String(localized: "Count of past due items is %d"), module.dueItemsCount))
        }

        if let duration = module.estimatedDurationFormatted {
            components.append(String(format: String(localized: "Duration is %@"), duration))
        }

        if isCollapsed {
            components.append(String(localized: "Double tap to Expanded"))
        } else {
            components.append(String(localized: "Double tap to Collapsed"))
        }

        return components.joined(separator: ". ")
    }
}
