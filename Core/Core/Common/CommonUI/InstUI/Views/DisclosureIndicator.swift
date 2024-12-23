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

    public struct DisclosureIndicator: View {
        @ScaledMetric private var uiScale: CGFloat = 1

        public var body: some View {
            Image.arrowOpenRightLine
                .resizable()
                .scaledToFit()
                .frame(width: uiScale.iconScale * 16,
                       height: uiScale.iconScale * 16)
                .foregroundStyle(Color.textDark)
        }
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 0) {
        InstUI.Divider()
        Cell(title: "InstUI: arrowOpenRightLine") { InstUI.DisclosureIndicator() }
        Cell(title: "Legacy: arrowOpenRightSolid") { Core.InstDisclosureIndicator() }
        Cell(title: "Legacy: iOS chevron.right") { Core.DisclosureIndicator() }
    }
}

private struct Cell<Content: View>: View {
    private let title: String
    @ViewBuilder private let disclosure: Content

    init(title: String, @ViewBuilder disclosure: () -> Content) {
        self.title = title
        self.disclosure = disclosure()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(title).textStyle(.cellLabel)
                Text(verbatim: "Some value").textStyle(.cellValue)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                disclosure
                    .paddingStyle(.leading, .cellAccessoryPadding)
            }
            .paddingStyle(set: .standardCell)

            InstUI.Divider()
        }
    }
}

#endif
