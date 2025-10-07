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

extension HorizonUI.InputChip {
    struct Storybook: View {
        var body: some View {
            ZStack {
                Color.huiColors.surface.cardSecondary
                VStack(alignment: .leading) {
                    HStack {
                        HorizonUI.InputChip(
                            title: "Body Text",
                            style: .ai(state: .default),
                            size: .small,
                            leadingIcon: Image.huiIcons.ai
                        ) { }

                        HorizonUI.InputChip(
                            title: "Body Text",
                            style: .ai(state: .disable),
                            size: .medium,
                            leadingIcon: Image.huiIcons.ai
                        ) { }
                        HorizonUI.InputChip(
                            title: "Body Text",
                            style: .ai(state: .focused),
                            size: .small,
                            leadingIcon: Image.huiIcons.ai
                        ) { }

                    }
                    HStack {
                        HorizonUI.InputChip(
                            title: "Body Text",
                            style: .primary(state: .default),
                            size: .small,
                            leadingIcon: Image.huiIcons.add
                        ) {}

                        HorizonUI.InputChip(
                            title: "Body Text",
                            style: .primary(state: .disable),
                            size: .small,
                            leadingIcon: Image.huiIcons.add
                        ) {}
                        HorizonUI.InputChip(
                            title: "Body Text",
                            style: .primary(state: .focused),
                            size: .small,
                            leadingIcon: Image.huiIcons.add
                        ) {}
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    HorizonUI.InputChip.Storybook()
}
