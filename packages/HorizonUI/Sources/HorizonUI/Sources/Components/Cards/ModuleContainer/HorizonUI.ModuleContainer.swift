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
    struct ModuleContainer: View {

        // MARK: - Dependencies

        private let title: String
        private let numberOfItems: Int
        private let numberOfPastDueItems: Int
        private let duration: String?
        private let isCompleted: Bool
        private let isCollapsed: Bool

        // MARK: - Init

        public init(
            title: String,
            numberOfItems: Int,
            numberOfPastDueItems: Int = 0,
            duration: String? = nil,
            isCompleted: Bool = false,
            isCollapsed: Bool = false
        ) {
            self.title = title
            self.numberOfItems = numberOfItems
            self.numberOfPastDueItems = numberOfPastDueItems
            self.duration = duration
            self.isCompleted = isCompleted
            self.isCollapsed = isCollapsed
        }

        public var body: some View {
            HStack(alignment: .top, spacing: .huiSpaces.primitives.small) {
                completedImage
                    .foregroundStyle(Color.huiColors.surface.institution)
                VStack(alignment: .leading, spacing: .huiSpaces.primitives.xxSmall) {
                    headerView
                    moduleOverview
                }
            }
            .padding(.huiSpaces.primitives.mediumSmall)
            .background(Color.huiColors.surface.cardPrimary)
            .huiCornerRadius(level: .level2)
        }

        private var completedImage: some View {
            isCompleted ? Image.huiIcons.checkCircleFull : Image.huiIcons.radioButtonUnchecked
        }

        private var collapsedImage: some View {
            Image.huiIcons
                .keyboardArrowDown
                .rotationEffect(isCollapsed ? .degrees(-180) : .degrees(0))
        }

        private var headerView: some View {
            HStack(alignment: .top) {
                Text(title)
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.labelLargeBold)
                    .multilineTextAlignment(.leading)

                Spacer()
                collapsedImage
                    .foregroundStyle(Color.huiColors.surface.institution)
            }
        }

        private var moduleOverview: some View {
            HStack(spacing: .huiSpaces.primitives.small) {
                Text("\(numberOfItems.description) Items")
                    .foregroundStyle(Color.huiColors.text.body)

                if numberOfPastDueItems > 0 {
                    Text("\(numberOfPastDueItems.description) Past Due")
                        .foregroundStyle(Color.huiColors.text.error)
                }

                if let duration {
                    Text(duration)
                        .foregroundStyle(Color.huiColors.text.body)
                }
            }
            .huiTypography(.labelSmall)
        }
    }
}

#Preview {
    HorizonUI.ModuleContainer(
        title: "[Module name]",
        numberOfItems: 4,
        numberOfPastDueItems: 32
    )
}
