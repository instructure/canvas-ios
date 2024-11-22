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

/// The purpose of this modifier is to dynamically turn the nav bar logo on and off
/// when the tab bar changes between its regular and elevated designs.
/// When the elevated tab bar is displayed we hide the logo so the tab bar can take the logo's place and there won't be
/// an extra line in the nav bar below the elevated tab bar just to display the logo.
struct DashboardNavigationBar: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isElevatedTabBar = false

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
                .toolbarBackground(Color(uiColor: Brand.shared.navBackground), for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        navBarLogo
                    }
                }
                .onChange(of: horizontalSizeClass, initial: true) { oldValue, newValue in
                    updateNavBarLogoVisibility(horizontalSizeClass: newValue)
                }
        } else {
            content
                .navigationBarGlobal()
        }
    }

    private func updateNavBarLogoVisibility(horizontalSizeClass: UserInterfaceSizeClass?) {
        // We can't use `self.horizontalSizeClass` here because it's still holding the old value
        isElevatedTabBar = horizontalSizeClass == .regular
    }

    @ViewBuilder
    private var navBarLogo: some View {
        if !isElevatedTabBar, let headerImage = Brand.shared.headerImage {
            ZStack {
                Color(Brand.shared.headerImageBackground)
                Image(uiImage: headerImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: 44, height: 44)
        }
    }
}

extension View {

    func navigationBarDashboard() -> some View {
        modifier(DashboardNavigationBar())
    }
}
