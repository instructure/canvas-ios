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

public extension HorizonUI.StatusChip {
    struct Storybook: View {
        public var body: some View {
            VStack {
                HorizonUI.StatusChip(
                    title: "Title",
                    style: .gray,
                    icon: Image.huiIcons.accountCircleFilled,
                    label: nil,
                    isFilled: true,
                    hasBorder: true
                )

                HorizonUI.StatusChip(
                    title: "Title",
                    style: .white,
                    icon: Image.huiIcons.accountCircleFilled,
                    label: nil,
                    isFilled: true,
                    hasBorder: false
                )

                HorizonUI.StatusChip(
                    title: "Title",
                    style: .red,
                    icon: Image.huiIcons.accountCircleFilled,
                    label: nil,
                    isFilled: true,
                    hasBorder: false
                )

                HorizonUI.StatusChip(
                    title: "Title",
                    style: .orange,
                    icon: nil,
                    label: nil,
                    isFilled: true,
                    hasBorder: false
                )

                HorizonUI.StatusChip(
                    title: "Title",
                    style: .hone,
                    icon: nil,
                    label: nil,
                    isFilled: true,
                    hasBorder: false
                )
                HorizonUI.StatusChip(
                    title: "Title",
                    style: .plum,
                    icon: nil,
                    label: nil,
                    isFilled: false,
                    hasBorder: false
                )
            }
        }
    }
}

#Preview {
    HorizonUI.StatusChip.Storybook()
}
