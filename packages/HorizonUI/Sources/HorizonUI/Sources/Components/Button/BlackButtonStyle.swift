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
    private static func initBlack(
        isSmall: Bool = false,
        width: HorizonButtonWidth = .infinity,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonButtonStyle {
        self.init(
            background: ButtonColors.dark,
            foreground: ButtonColors.white,
            leading: leading,
            width: width,
            trailing: trailing
        )
    }

    static var black: HorizonButtonStyle {
        self.initBlack()
    }

    static var blackSmall: HorizonButtonStyle {
        self.initBlack(isSmall: true)
    }

    static func black(
        width: HorizonButtonWidth = .infinity,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonButtonStyle {
        self.initBlack(
            width: width,
            leading: leading,
            trailing: trailing
        )
    }

    static func blackSmall(
        width: HorizonButtonWidth = .infinity,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonButtonStyle {
        self.initBlack(
            isSmall: true,
            width: width,
            leading: leading,
            trailing: trailing
        )
    }
}
