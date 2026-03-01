//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public enum DashboardSwitchAlert {
    public static func makeAlert(isEnabling: Bool, onSwitch: @escaping () -> Void) -> Alert {
        let title = Text("Switch Dashboard?", bundle: .core)
        let message: Text = isEnabling
            ? Text("You're about to switch to the new mobile dashboard. You can change back later in Dashboard Settings screen.", bundle: .core)
            : Text("You're about to switch to the classic dashboard. You can change back later in Dashboard Settings screen.", bundle: .core)

        return Alert(
            title: title,
            message: message,
            primaryButton: .default(Text("Switch", bundle: .core)) {
                onSwitch()
            },
            secondaryButton: .cancel()
        )
    }
}
