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

public extension InstUI.Styles {
    enum Padding: CGFloat {
        case standard = 16
        case cellTop = 12
        case cellBottom = 14
        case paragraphTop = 24
        case paragraphBottom = 28
        /// When displaying multiple Text components below each other we use this spacing to separate them
        case textVertical = 4
    }
}

public extension View {

    @inlinable func paddingStyle(
        _ edges: Edge.Set = .all,
        _ padding: InstUI.Styles.Padding? = nil
    ) -> some View {
        self.padding(edges, padding?.rawValue)
    }
}
