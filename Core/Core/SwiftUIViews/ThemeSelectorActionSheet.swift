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

extension View {

    func showThemeSelectorActionSheet(isPresented: Binding<Bool>) -> some View {
        return self.actionSheet(isPresented: isPresented) {
            let systemButton = ActionSheet.Button.default(Text("System settings", bundle: .core)) {
                setStyle(style: .unspecified)
            }

            let lightButton = ActionSheet.Button.default(Text("Light theme", bundle: .core)) {
                setStyle(style: .light)
            }

            let darkButton = ActionSheet.Button.default(Text("Dark theme", bundle: .core)) {
                setStyle(style: .dark)
            }

            let cancelButton = ActionSheet.Button.cancel(Text("Cancel", bundle: .core)) {
                setStyle(style: .light)
            }

            return ActionSheet(title: Text("Canvas is now available in dark theme", bundle: .core),
                               message: Text("Choose your app appearance\nYou can change it later in the settings menu", bundle: .core),
                               buttons: [systemButton, lightButton, darkButton, cancelButton])
        }
    }

    private func setStyle(style: UIUserInterfaceStyle?) {
        let env = AppEnvironment.shared
        env.userDefaults?.interfaceStyle = style
        if let window = env.window {
            window.updateInterfaceStyle(style)
        }
    }
}
