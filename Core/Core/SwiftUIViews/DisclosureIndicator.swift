//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public struct DisclosureIndicator: View {
    public init() {}

    public var body: some View {
        Image(systemName: "chevron.right")
            .flipsForRightToLeftLayoutDirection(true)
            .foregroundColor(.borderMedium)
    }
}

public struct InstDisclosureIndicator: View {
    @ScaledMetric private var uiScale: CGFloat = 1

    public var body: some View {
        Image.arrowOpenRightSolid
            .resizable()
            .scaledToFit()
            .frame(width: uiScale.iconScale * 16,
                   height: uiScale.iconScale * 16)
            .foregroundColor(.textDark)
    }
}
