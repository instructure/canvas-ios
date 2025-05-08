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

public extension HorizonUI.SegmentedControl {
    struct Storybook: View {
        private let smallSetItems: [String] = ["Item 1", "Item 2"]
        private let mediumSetItems: [String] = ["Item 1", "Item 2", "Item 3"]
        private let largeSetItems: [String] = ["Item 1", "Item 2", "Item 3", "Item 4"]
        private let extraLargeSetItems: [String] = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]

        @State private var selectedIndices: [Int] = Array(repeating: 0, count: 13)

        public var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    HorizonUI.SegmentedControl(
                        items: smallSetItems,
                        icon: .add,
                        iconAlignment: .leading,
                        selectedIndex: $selectedIndices[0]
                    )

                    HorizonUI.SegmentedControl(
                        items: smallSetItems,
                        icon: .add,
                        selectedIndex: $selectedIndices[1]
                    )

                    HorizonUI.SegmentedControl(
                        items: smallSetItems,
                        selectedIndex: $selectedIndices[2]
                    )

                    HorizonUI.SegmentedControl(
                        items: smallSetItems,
                        icon: .checkMark,
                        iconAlignment: .leading,
                        selectedIndex: $selectedIndices[3]
                    )

                    HorizonUI.SegmentedControl(
                        items: smallSetItems,
                        icon: .checkMark,
                        iconAlignment: .trailing,
                        selectedIndex: $selectedIndices[4]
                    )

                    HorizonUI.SegmentedControl(
                        items: smallSetItems,
                        icon: .checkMark,
                        iconAlignment: .trailing,
                        isShowIconForAllItems: false,
                        selectedIndex: $selectedIndices[5]
                    )

                    HorizonUI.SegmentedControl(
                        items: mediumSetItems,
                        icon: .checkMark,
                        iconAlignment: .trailing,
                        isShowIconForAllItems: false,
                        selectedIndex: $selectedIndices[6]
                    )

                    HorizonUI.SegmentedControl(
                        items: mediumSetItems,
                        icon: .add,
                        iconAlignment: .leading,
                        isShowIconForAllItems: false,
                        selectedIndex: $selectedIndices[7]
                    )

                    HorizonUI.SegmentedControl(
                        items: mediumSetItems,
                        icon: .add,
                        iconAlignment: .leading,
                        selectedIndex: $selectedIndices[8]
                    )

                    HorizonUI.SegmentedControl(
                        items: mediumSetItems,
                        icon: .checkMark,
                        iconAlignment: .trailing,
                        selectedIndex: $selectedIndices[9]
                    )

                    HorizonUI.SegmentedControl(
                        items: mediumSetItems,
                        selectedIndex: $selectedIndices[10]
                    )

                    HorizonUI.SegmentedControl(
                        items: largeSetItems,
                        selectedIndex: $selectedIndices[11]
                    )

                    HorizonUI.SegmentedControl(
                        items: extraLargeSetItems,
                        selectedIndex: $selectedIndices[12]
                    )
                }
                .padding()
                .navigationTitle("Segmented Control")
            }
        }
    }
}

#Preview {
    HorizonUI.SegmentedControl.Storybook()
}
