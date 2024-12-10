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
    private static func initBeige(
        isSmall: Bool = false,
        width: HorizonButtonWidth = .infinity,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonButtonStyle {
        self.init(
            background: ButtonColors.beige,
            foreground: ButtonColors.dark,
            leading: leading,
            width: width,
            trailing: trailing
        )
    }

    static var beige: HorizonButtonStyle {
        self.initBeige()
    }

    static var beigeSmall: HorizonButtonStyle {
        self.initBeige(isSmall: true)
    }

    static func beige(
        width: HorizonButtonWidth = .infinity,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonButtonStyle {
        self.initBeige(
            width: width,
            leading: leading,
            trailing: trailing
        )
    }

    static func beigeSmall(
        width: HorizonButtonWidth = .infinity,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonButtonStyle {
        self.initBeige(
            isSmall: true,
            width: width,
            leading: leading,
            trailing: trailing
        )
    }
}
