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

public extension HorizonUI.Tag {
    struct Storybook: View {
        public var body: some View {
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 16
            ) {
                // MARK: - DEFAULT styles

                HorizonUI.Tag(
                    title: "Lorem ipsum",
                    style: .standalone,
                    size: .large,
                    onCloseAction: {}
                )

                HorizonUI.Tag(
                    title: "Lorem ipsum",
                    style: .standalone,
                    size: .medium,
                    onCloseAction: {}
                )

                HorizonUI.Tag(
                    title: "Lorem ipsum",
                    style: .standalone,
                    size: .small,
                    onCloseAction: {}
                )

                HorizonUI.Tag(
                    title: "Lorem ipsum",
                    style: .standalone,
                    size: .large
                )

                HorizonUI.Tag(
                    title: "Lorem ipsum",
                    style: .standalone,
                    size: .medium
                )

                HorizonUI.Tag(
                    title: "Lorem ipsum",
                    style: .standalone,
                    size: .small
                )

                HorizonUI.Tag(
                    title: "Lorem ipsum",
                    style: .inline,
                    size: .large,
                    onCloseAction: {}
                )

                HorizonUI.Tag(
                    title: "Lorem ipsum",
                    style: .inline,
                    size: .medium,
                    onCloseAction: {}
                )

                HorizonUI.Tag(
                    title: "Lorem ipsum",
                    style: .inline,
                    size: .small,
                    onCloseAction: {}
                )

                HorizonUI.Tag(
                    title: "Lorem ipsum",
                    style: .inline,
                    size: .large
                )

                HorizonUI.Tag(
                    title: "Lorem ipsum",
                    style: .inline,
                    size: .medium
                )

                HorizonUI.Tag(
                    title: "Lorem ipsum",
                    style: .inline,
                    size: .small
                )
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.all, 16)
            .navigationTitle("Tag")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HorizonUI.Tag.Storybook()
}
