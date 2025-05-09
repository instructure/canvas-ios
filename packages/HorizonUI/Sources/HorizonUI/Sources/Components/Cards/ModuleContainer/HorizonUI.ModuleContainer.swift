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
        private let subtitle: String?
        private let status: ModuleContainer.Status
        private let numberOfItems: Int
        private let numberOfPastDueItems: Int
        private let duration: String?
        private let isCollapsed: Bool

        // MARK: - Init

        public init(
            title: String,
            subtitle: String? = nil,
            status: ModuleContainer.Status,
            numberOfItems: Int,
            numberOfPastDueItems: Int = 0,
            duration: String? = nil,
            isCollapsed: Bool = false
        ) {
            self.title = title
            self.subtitle = subtitle
            self.status = status
            self.numberOfItems = numberOfItems
            self.numberOfPastDueItems = numberOfPastDueItems
            self.duration = duration
            self.isCollapsed = isCollapsed
        }

        public var body: some View {
            VStack(spacing: .zero) {
                contentView
                subtitleView
            }
            .padding(.huiSpaces.space16)
            .background(Color.huiColors.surface.cardPrimary)
            .huiCornerRadius(level: .level2)
        }

        private var contentView: some View {
            HStack(alignment: .top, spacing: .huiSpaces.space8) {
                collapsedImage
                    .foregroundStyle(Color.huiColors.icon.default)
                VStack(alignment: .leading, spacing: .huiSpaces.space4) {
                    StatusView(status: status)
                    headerView
                    moduleOverview
                }
            }
        }

        private var collapsedImage: some View {
            Image.huiIcons
                .keyboardArrowDown
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: status.imageHeight)
                .rotationEffect(isCollapsed ? .degrees(-180) : .degrees(0))
        }

        private var headerView: some View {
            HStack(alignment: .top) {
                Text(title)
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.labelLargeBold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(isCollapsed ? nil : 2)

                Spacer()
            }
        }

        private var moduleOverview: some View {
            HStack(spacing: .huiSpaces.space12) {
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

        @ViewBuilder
        private var subtitleView: some View {
            if isCollapsed, let subtitle {
                Text(subtitle)
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.p2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, .huiSpaces.space24)
            }
        }
    }
}

#Preview {
    HorizonUI.ModuleContainer(
        title: "[Module name]",
        subtitle: "subtitle",
        status: .completed,
        numberOfItems: 4,
        numberOfPastDueItems: 32
    )
}
