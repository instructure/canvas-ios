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

extension HorizonButtonStyle {
    private static func initWhite(
        isSmall: Bool = false,
        width: HorizonButtonWidth = .infinity,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonButtonStyle {
        self.init(
            background: ButtonColors.white,
            foreground: ButtonColors.dark,
            leading: leading,
            width: width,
            trailing: trailing
        )
    }

    static var white: HorizonButtonStyle {
        self.initWhite()
    }

    static var whiteSmall: HorizonButtonStyle {
        self.initWhite(isSmall: true)
    }

    static func white(
        width: HorizonButtonWidth = .infinity,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonButtonStyle {
        .initWhite(width: width, leading: leading, trailing: trailing)
    }

    static func whiteSmall(
        width: HorizonButtonWidth = .infinity,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonButtonStyle {
        .initWhite(
            isSmall: true,
            width: width,
            leading: leading,
            trailing: trailing
        )
    }
}
