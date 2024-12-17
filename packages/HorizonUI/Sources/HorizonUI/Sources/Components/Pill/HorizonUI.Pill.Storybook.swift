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

public extension HorizonUI.Pill {
    struct Storybook: View {
        public var body: some View {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // MARK: - Regular uppercase

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {
                        // MARK: Default colors, no icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.default),
                            isSmall: false,
                            isUppercased: true,
                            icon: nil
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.default),
                            isSmall: false,
                            isUppercased: true,
                            icon: nil
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .inline(.default),
                            isSmall: false,
                            isUppercased: true,
                            icon: nil
                        )

                        // MARK: Default colors, icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.default),
                            isSmall: false,
                            isUppercased: true,
                            icon: .huiIcons.calendarToday
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.default),
                            isSmall: false,
                            isUppercased: true,
                            icon: .huiIcons.calendarToday
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .inline(.default),
                            isSmall: false,
                            isUppercased: true,
                            icon: .huiIcons.calendarToday
                        )

                        // MARK: Danger colors, no icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.danger),
                            isSmall: false,
                            isUppercased: true,
                            icon: nil
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.danger),
                            isSmall: false,
                            isUppercased: true,
                            icon: nil
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .inline(.danger),
                            isSmall: false,
                            isUppercased: true,
                            icon: nil
                        )

                        // MARK: Danger colors, icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.danger),
                            isSmall: false,
                            isUppercased: true,
                            icon: .huiIcons.calendarToday
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.danger),
                            isSmall: false,
                            isUppercased: true,
                            icon: .huiIcons.calendarToday
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .inline(.danger),
                            isSmall: false,
                            isUppercased: true,
                            icon: .huiIcons.calendarToday
                        )

                        Spacer()
                    }

                    // MARK: - Small uppercase

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {
                        // MARK: Default colors, no icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.default),
                            isSmall: true,
                            isUppercased: true,
                            icon: nil
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.default),
                            isSmall: true,
                            isUppercased: true,
                            icon: nil
                        )

                        // MARK: Default colors, icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.default),
                            isSmall: true,
                            isUppercased: true,
                            icon: .huiIcons.calendarToday
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.default),
                            isSmall: true,
                            isUppercased: true,
                            icon: .huiIcons.calendarToday
                        )

                        // MARK: Danger colors, no icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.danger),
                            isSmall: true,
                            isUppercased: true,
                            icon: nil
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.danger),
                            isSmall: true,
                            isUppercased: true,
                            icon: nil
                        )

                        // MARK: Danger colors, icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.danger),
                            isSmall: true,
                            isUppercased: true,
                            icon: .huiIcons.calendarToday
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.danger),
                            isSmall: true,
                            isUppercased: true,
                            icon: .huiIcons.calendarToday
                        )

                        Spacer()
                    }

                    // MARK: - Regular, lowercase

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {
                        // MARK: Default colors, no icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.default),
                            isSmall: false,
                            isUppercased: false,
                            icon: nil
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.default),
                            isSmall: false,
                            isUppercased: false,
                            icon: nil
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .inline(.default),
                            isSmall: false,
                            isUppercased: false,
                            icon: nil
                        )

                        // MARK: Default colors, icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.default),
                            isSmall: false,
                            isUppercased: false,
                            icon: .huiIcons.calendarToday
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.default),
                            isSmall: false,
                            isUppercased: false,
                            icon: .huiIcons.calendarToday
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .inline(.default),
                            isSmall: false,
                            isUppercased: false,
                            icon: .huiIcons.calendarToday
                        )

                        // MARK: Danger colors, no icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.danger),
                            isSmall: false,
                            isUppercased: false,
                            icon: nil
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.danger),
                            isSmall: false,
                            isUppercased: true,
                            icon: nil
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .inline(.danger),
                            isSmall: false,
                            isUppercased: false,
                            icon: nil
                        )

                        // MARK: Danger colors, icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.danger),
                            isSmall: false,
                            isUppercased: false,
                            icon: .huiIcons.calendarToday
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.danger),
                            isSmall: false,
                            isUppercased: false,
                            icon: .huiIcons.calendarToday
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .inline(.danger),
                            isSmall: false,
                            isUppercased: false,
                            icon: .huiIcons.calendarToday
                        )

                        Spacer()
                    }

                    // MARK: - Small, lowercase

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {
                        // MARK: Default colors, no icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.default),
                            isSmall: true,
                            isUppercased: false,
                            icon: nil
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.default),
                            isSmall: true,
                            isUppercased: false,
                            icon: nil
                        )

                        // MARK: Default colors, icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.default),
                            isSmall: true,
                            isUppercased: false,
                            icon: .huiIcons.calendarToday
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.default),
                            isSmall: true,
                            isUppercased: false,
                            icon: .huiIcons.calendarToday
                        )

                        // MARK: Danger colors, no icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.danger),
                            isSmall: true,
                            isUppercased: false,
                            icon: nil
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.danger),
                            isSmall: true,
                            isUppercased: false,
                            icon: nil
                        )

                        // MARK: Danger colors, icon

                        HorizonUI.Pill(
                            title: "default",
                            style: .outline(.danger),
                            isSmall: true,
                            isUppercased: false,
                            icon: .huiIcons.calendarToday
                        )

                        HorizonUI.Pill(
                            title: "default",
                            style: .solid(.danger),
                            isSmall: true,
                            isUppercased: false,
                            icon: .huiIcons.calendarToday
                        )

                        Spacer()
                    }
                }
                .padding(.all, 16)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle("Pill")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HorizonUI.Pill.Storybook()
}
