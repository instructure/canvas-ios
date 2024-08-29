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

extension InstUI {

    enum Icons {

        struct Selection: View {
            static let leadingPadding: CGFloat = 12

            @ScaledMetric private var uiScale: CGFloat = 1

            public var body: some View {
                Image.arrowUpDownLine
                    .resizable()
                    .scaledToFit()
                    .frame(width: uiScale.iconScale * 16,
                           height: uiScale.iconScale * 16)
                    .foregroundStyle(Color.textDark)
            }
        }

        struct Checkmark: View {
            @ScaledMetric private var uiScale: CGFloat = 1

            public var body: some View {
                Image.checkLine
                    .resizable()
                    .scaledToFit()
                    .frame(width: uiScale.iconScale * 18,
                           height: uiScale.iconScale * 18)
                    .foregroundStyle(Color.textDarkest)
            }
        }

        struct Back: View {
            @ScaledMetric private var uiScale: CGFloat = 1

            public var body: some View {
                Image.arrowOpenLeftLine
                    .resizable()
                    .scaledToFit()
                    .frame(width: uiScale.iconScale * 18,
                           height: uiScale.iconScale * 18)
                    .foregroundStyle(Color.textDarkest)
            }
        }
    }
}
