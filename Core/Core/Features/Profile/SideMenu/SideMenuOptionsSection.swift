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

struct SideMenuOptionsSection: View {
    @Environment(\.appEnvironment) var env
    @ObservedObject private var viewModel = OptionsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            SideMenuSubHeaderView(title: Text("OPTIONS", bundle: .core))
                .accessibility(addTraits: .isHeader)
            SideMenuToggleItem(id: "darkMode",
                               image: .imageLine,
                               title: Text("Dark Mode", bundle: .core),
                               isOn: $viewModel.darkMode)
            .onTapGesture {
                withAnimation {
                    viewModel.darkMode.toggle()
                }
            }
        }
    }
}

extension SideMenuOptionsSection {
    final class OptionsViewModel: ObservableObject {
        @Published var darkMode: Bool = false {
            willSet {
                if newValue != darkMode {
                    let style: UIUserInterfaceStyle = newValue ? .dark : .light
                    if let window = env.window {
                        window.updateInterfaceStyle(style)
                    }
                    env.userDefaults?.interfaceStyle = style
                }
            }
        }

        private let env = AppEnvironment.shared

        init() {
            darkMode = env.userDefaults?.interfaceStyle == .dark
        }
    }
}

#if DEBUG

struct SideMenuOptionsSection_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuOptionsSection()
    }
}

#endif
