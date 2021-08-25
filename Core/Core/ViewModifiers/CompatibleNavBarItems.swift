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

    @available(iOS, obsoleted: 14)
    @ViewBuilder
    public func compatibleNavBarItems<T>(trailing: () -> T) -> some View where T: View {
        if #available(iOS 14, *) {
            self.toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: trailing)
            }
        } else {
            self.navigationBarItems(trailing: trailing())
        }
    }

    @available(iOS, obsoleted: 14)
    @ViewBuilder
    public func compatibleNavBarItems<L, T>(leading: () -> L, trailing: () -> T) -> some View where L: View, T: View {
        if #available(iOS 14, *) {
            self.toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: leading)
                ToolbarItem(placement: .navigationBarTrailing, content: trailing)
            }
        } else {
            self.navigationBarItems(leading: leading(), trailing: trailing())
        }
    }
}
