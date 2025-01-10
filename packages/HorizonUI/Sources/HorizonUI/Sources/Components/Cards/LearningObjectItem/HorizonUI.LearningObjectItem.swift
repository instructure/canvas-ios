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

public extension HorizonUI {
    struct LearningObjectItem: View {

        // MARK: - Properties

        private let cornerRadius: CornerRadius = .level3

        // MARK: - Dependencies

        private let name: String
        private let isSelected: Bool
        private let requirement: RequirementType
        private let status: Status?
        private let type: LearningObjectItem.ItemType
        private let duration: String
        private let dueDate: String?
        private let lockedDate: String?
        private let points: Double?
        private let isOverdue: Bool

        // MARK: - Init

        public init(
            name: String,
            isSelected: Bool,
            requirement: RequirementType,
            status: Status? = nil,
            type: LearningObjectItem.ItemType,
            duration: String,
            dueDate: String? = nil,
            lockedDate: String? = nil,
            points: Double? = nil,
            isOverdue: Bool = false
        ) {
            self.name = name
            self.isSelected = isSelected
            self.requirement = requirement
            self.status = status
            self.type = type
            self.duration = duration
            self.dueDate = dueDate
            self.lockedDate = lockedDate
            self.points = points
            self.isOverdue = isOverdue
        }

        public var body: some View {
            HStack {
                contentView
                Spacer()
                StatusView(
                    status: status,
                    requirement: requirement,
                    dueDate: lockedDate
                )
            }
            .padding(.vertical, .huiSpaces.primitives.small)
            .padding(.horizontal, .huiSpaces.primitives.smallMedium)
            .background {
                Rectangle()
                    .fill(Color.huiColors.surface.cardPrimary)
                    .huiCornerRadius(level: .level2)
            }
            .huiBorder(
                level: isSelected ? .level2 : .level1,
                color: isSelected ? .huiColors.surface.institution : .huiColors.lineAndBorders.lineStroke,
                radius: cornerRadius.attributes.radius
            )
        }

        private var contentView: some View {
            VStack(alignment: .leading) {
                Text(name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.huiColors.text.body)
                    .multilineTextAlignment(.leading)
                    .huiTypography(.p2)

                HStack(spacing: .huiSpaces.primitives.mediumSmall) {
                    HorizonUI.Pill(
                        title: type.name,
                        style:.inline(
                            .init(
                                textColor: Color.huiColors.text.body,
                                iconColor: Color.huiColors.surface.institution
                            )
                        ),
                        isSmall: false,
                        isUppercased: true,
                        icon: type.icon
                    )
                    Text(itemStatusText)
                        .foregroundStyle(Color.huiColors.text.body)
                        .huiTypography(.p3)
                        .foregroundStyle(Color.huiColors.text.timestamp)

                    Text(duration)
                        .foregroundStyle(Color.huiColors.text.timestamp)
                        .huiTypography(.p3)
                        .padding(.leading, .huiSpaces.primitives.mediumSmall)
                }

                HStack(spacing: .huiSpaces.primitives.mediumSmall) {
                    if let dueDate {
                        dueDateView(dueDate)
                    }

                    if let points {
                        Text("\(points.description) pts")
                            .foregroundStyle(Color.huiColors.text.timestamp)
                    }
                }
                .huiTypography(.p3)
            }
        }

        private var itemStatusText: String {
            if status == .completed, requirement == .required {
                return type.status
            }
            return requirement.title
        }

        @ViewBuilder
        private func dueDateView(_ date: String) -> some View {
            let dueText = isOverdue ? String(localized: "Past Due") : String(localized: "Due")
            Text("\(dueText) \(date)")
                .foregroundStyle(isOverdue ? Color.huiColors.text.error : Color.huiColors.text.timestamp)
        }
    }
}

#Preview {
    HorizonUI.LearningObjectItem(
        name: "Module Item Name",
        isSelected: true,
        requirement: .required,
        status: .completed,
        type: .externalLink,
        duration: "XX Mins",
        dueDate: "22/12",
        points: 22,
        isOverdue: true
    )
}
