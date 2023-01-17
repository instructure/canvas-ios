//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public enum SwipeEdge {
    case leading
    case trailing
}

public extension View {

    /**
     This view modifier allows the iOS 15 only `swipeActions` modifier to be used without the need of in place iOS availability checks. This method does nothing below iOS 15.
     */
    @available(iOS, obsoleted: 15)
    @ViewBuilder
    func iOS15SwipeActions<T>(edge: SwipeEdge = .trailing,
                              allowsFullSwipe: Bool = true,
                              @ViewBuilder content: @escaping () -> T)
    -> some View where T: View {
        if #available(iOS 15, *) {
            self.swipeActions(edge: edge == .leading ? .leading : .trailing,
                                     allowsFullSwipe: allowsFullSwipe,
                                     content: content)
        } else {
            self
        }
    }
}
