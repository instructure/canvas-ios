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
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 16
            ) {
                // MARK: - DEFAULT styles

                HorizonUI.Pill(
                    title: "default",
                    style: .default,
                    isBordered: true,
                    isUppercased: true,
                    icon: nil
                )
                HorizonUI.Pill(
                    title: "default",
                    style: .default,
                    isBordered: false,
                    isUppercased: true,
                    icon: nil
                )
                HorizonUI.Pill(
                    title: "default",
                    style: .default,
                    isBordered: true,
                    isUppercased: false,
                    icon: nil
                )
                HorizonUI.Pill(
                    title: "default",
                    style: .default,
                    isBordered: false,
                    isUppercased: true,
                    icon: nil
                )
                HorizonUI.Pill(
                    title: "default",
                    style: .default,
                    isBordered: true,
                    isUppercased: true,
                    icon: HorizonUI.Pill.PlaceholderIcon(name: "calendar")
                )
                HorizonUI.Pill(
                    title: "default",
                    style: .default,
                    isBordered: false,
                    isUppercased: true,
                    icon: HorizonUI.Pill.PlaceholderIcon(name: "calendar")
                )
                HorizonUI.Pill(
                    title: "default",
                    style: .default,
                    isBordered: true,
                    isUppercased: false,
                    icon: HorizonUI.Pill.PlaceholderIcon(name: "calendar")
                )
                HorizonUI.Pill(
                    title: "default",
                    style: .default,
                    isBordered: false,
                    isUppercased: false,
                    icon: HorizonUI.Pill.PlaceholderIcon(name: "calendar")
                )

                // MARK: DANGER styles

                HorizonUI.Pill(
                    title: "danger",
                    style: .danger,
                    isBordered: true,
                    isUppercased: true,
                    icon: nil
                )
                HorizonUI.Pill(
                    title: "danger",
                    style: .danger,
                    isBordered: false,
                    isUppercased: true,
                    icon: nil
                )
                HorizonUI.Pill(
                    title: "danger",
                    style: .danger,
                    isBordered: true,
                    isUppercased: false,
                    icon: nil
                )
                HorizonUI.Pill(
                    title: "danger",
                    style: .danger,
                    isBordered: false,
                    isUppercased: true,
                    icon: nil
                )
                HorizonUI.Pill(
                    title: "danger",
                    style: .danger,
                    isBordered: true,
                    isUppercased: true,
                    icon: HorizonUI.Pill.PlaceholderIcon(name: "calendar")
                )
                HorizonUI.Pill(
                    title: "danger",
                    style: .danger,
                    isBordered: false,
                    isUppercased: true,
                    icon: HorizonUI.Pill.PlaceholderIcon(name: "calendar")
                )
                HorizonUI.Pill(
                    title: "danger",
                    style: .danger,
                    isBordered: true,
                    isUppercased: false,
                    icon: HorizonUI.Pill.PlaceholderIcon(name: "calendar")
                )
                HorizonUI.Pill(
                    title: "danger",
                    style: .danger,
                    isBordered: false,
                    isUppercased: false,
                    icon: HorizonUI.Pill.PlaceholderIcon(name: "calendar")
                )
                Spacer()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.all, 16)
            .navigationTitle("Pill")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HorizonUI.Pill.Storybook()
}
