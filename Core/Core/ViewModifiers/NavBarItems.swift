//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

extension View {

    public func navBarItems<T>(trailing: T) -> some View where T: View {
        navBarItems(trailing: { trailing })
    }

    public func navBarItems<T>(trailing: () -> T) -> some View where T: View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarTrailing, content: trailing)
        }
    }

    public func navBarItems<L, T>(leading: L, trailing: T) -> some View where L: View, T: View {
        navBarItems(leading: { leading }, trailing: { trailing })
    }

    public func navBarItems<L, T>(leading: () -> L, trailing: () -> T) -> some View where L: View, T: View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarLeading, content: leading)
            ToolbarItem(placement: .navigationBarTrailing, content: trailing)
        }
    }
}
