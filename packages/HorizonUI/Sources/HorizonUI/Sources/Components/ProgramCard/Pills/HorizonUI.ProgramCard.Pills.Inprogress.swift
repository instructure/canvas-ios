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

import SwiftUI

extension HorizonUI.ProgramCard.Pills {
    struct InProgress: View {
        let isEnrolled: Bool
        let isRequired: Bool
        let estimatedTime: String?
        let dueDate: String?

        init(
            isEnrolled: Bool = false,
            isRequired: Bool,
            estimatedTime: String?,
            dueDate: String?
        ) {
            self.isEnrolled = isEnrolled
            self.isRequired = isRequired
            self.estimatedTime = estimatedTime
            self.dueDate = dueDate
        }

        var body: some View {
            HorizonUI.HFlow {
                if isEnrolled {
                    HorizonUI.Pill(
                        title: String(localized: "Enrolled"),
                        style: .solid(
                            .init(
                                backgroundColor: Color.huiColors.primitives.green12,
                                textColor: Color.huiColors.primitives.green82,
                                iconColor: Color.huiColors.primitives.green82
                            )
                        ),
                        isSmall: true,
                        cornerRadius: .level1,
                        icon: .huiIcons.checkCircleFull
                    )
                }
                defaultPill(title: isRequired
                            ? String(localized: "Required")
                            : String(localized: "Optional")
                )

                if let estimatedTime {
                    defaultPill(title: estimatedTime)
                }

                if let dueDate {
                    HorizonUI.Pill(
                        title: dueDate,
                        style: .solid(
                            .init(
                                backgroundColor: Color.huiColors.primitives.grey11,
                                textColor: Color.huiColors.text.title,
                                iconColor: Color.huiColors.icon.default
                            )
                        ),
                        isSmall: true,
                        cornerRadius: .level1,
                        icon: .huiIcons.calendarToday
                    )
                }
            }
        }

        private func defaultPill(title: String) -> some View {
            HorizonUI.Pill(
                title: title,
                style: .solid(
                    .init(
                        backgroundColor: Color.huiColors.primitives.grey11,
                        textColor: Color.huiColors.text.title
                    )
                ),
                isSmall: true,
                cornerRadius: .level1,
            )
        }
    }
}

#Preview {
    HorizonUI.ProgramCard.Pills
        .InProgress(
            isEnrolled: true,
            isRequired: true,
            estimatedTime: "10 hours",
            dueDate: "10-10-2020"
        )
}
