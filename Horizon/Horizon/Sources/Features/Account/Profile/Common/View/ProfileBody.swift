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

struct ProfileBody<Content: View>: View {

    let page: HTitleBar.Page
    @ViewBuilder let content: Content
    @Environment(\.appEnvironment) var environment
    @Environment(\.viewController) var viewController

    init(_ page: HTitleBar.Page, @ViewBuilder content: @escaping () -> Content) {
        self.page = page
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            HTitleBar(page: page) { _ in
                environment.router.pop(from: viewController)
            }

            VStack(spacing: 0) {
                content
            }
            .background(Color.huiColors.surface.pageSecondary)
            .huiCornerRadius(level: .level5, corners: [.topLeft, .topRight])
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .toolbar(.hidden)
        .background(Color.huiColors.surface.pagePrimary)
    }
}
