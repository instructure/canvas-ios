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
    struct LearningObjectCard: View {
        // MARK: - Dependencies

        private let status: String?
        private let moduleTitle: String
        private let learningObjectName: String
        private let duration: String?
        private let type: String?
        private let dueDate: String?
        private let onTapButton: () -> Void

        // MARK: - Init

        public init(
            status: String? = nil,
            moduleTitle: String,
            learningObjectName: String,
            duration: String? = nil,
            type: String? = nil,
            dueDate: String? = nil,
            onTapButton: @escaping () -> Void = { }
        ) {
            self.status = status
            self.moduleTitle = moduleTitle
            self.learningObjectName = learningObjectName
            self.duration = duration
            self.type = type
            self.dueDate = dueDate
            self.onTapButton = onTapButton
        }


        public var body: some View {
            HorizonUI.Card {
                if let status {
                    HorizonUI.Pill(
                        title: status,
                        style: .outline(.default),
                        isSmall: false,
                        isUppercased: true,
                        icon: nil
                    )
                }

                Text(moduleTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.p2)
                    .padding(.top, .huiSpaces.space16)

                Text(learningObjectName)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.huiColors.surface.institution)
                    .huiTypography(.h3)
                    .padding(.top, .huiSpaces.space4)

                courseInfoView()
                    .padding(.top, .huiSpaces.space48)
            }
        }

        private func courseInfoView() -> some View {
            HStack(alignment: .bottom) {
                setCoursePropertiesView()
                Spacer()
                iconButton
            }
        }

        private func setCoursePropertiesView() -> some View {
            VStack(alignment: .leading, spacing: .huiSpaces.space8) {
                if let duration {
                    HorizonUI.Pill(
                        title: duration,
                        style: .inline(.init(textColor: .huiColors.text.body, iconColor: .huiColors.surface.institution)),
                        isSmall: true,
                        isUppercased: false,
                        icon: Image.huiIcons.schedule
                    )
                }

                if let type {
                    HorizonUI.Pill(
                        title: type,
                        style: .inline(.init(textColor: .huiColors.text.body, iconColor: .huiColors.surface.institution)),
                        isSmall: true,
                        isUppercased: false,
                        icon: Image.huiIcons.textSnippet
                    )
                }

                if let dueDate {
                    HorizonUI.Pill(
                        title: "Due \(dueDate)",
                        style: .inline(.init(textColor: .huiColors.text.body, iconColor: .huiColors.surface.institution)),
                        isSmall: true,
                        isUppercased: false,
                        icon: Image.huiIcons.calendarToday
                    )
                }
            }
        }

        // TODO: will reuse iconButton component
        private var iconButton: some View {
            Button {
                onTapButton()
            } label: {
                Rectangle()
                    .fill(Color.huiColors.surface.institution)
                    .frame(width: 44, height: 44)
                    .huiCornerRadius(level: .level6)
                    .overlay {
                        Image.huiIcons.arrowForward
                            .foregroundStyle(Color.huiColors.icon.surfaceColored)
                    }
            }
        }
    }
}

#Preview {
    HorizonUI.LearningObjectCard(
        status: "Default",
        moduleTitle: "Module Title Lorem Ipsum Dolor Sit Amet Adipiscing Elit So Do",
        learningObjectName: "Learning Object Name Lorem Ipsum Dolor",
        duration: "20 Mins",
        type: "Learning Object Type",
        dueDate: "10/10/2015"
    )
}
