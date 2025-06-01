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

struct TodoContentView<Content: View>: View {

    let logoRoute: URL?

    let actionIcon: Image
    let actionRoute: URL?
    let actionHandler: (() -> Void)?

    let content: () -> Content

    init(logoRoute: URL? = nil,
         actionIcon: Image = .addLine,
         actionRoute: URL,
         content: @escaping () -> Content
    ) {
        self.logoRoute = logoRoute
        self.actionIcon = actionIcon
        self.actionRoute = actionRoute
        self.actionHandler = nil
        self.content = content
    }

    init(logoRoute: URL? = nil,
         actionIcon: Image,
         actionHandler: @escaping () -> Void,
         content: @escaping () -> Content
    ) {
        self.logoRoute = logoRoute
        self.actionIcon = actionIcon
        self.actionRoute = nil
        self.actionHandler = actionHandler
        self.content = content
    }

    var body: some View {
        ZStack {
            content()
            VStack {
                topView
                Spacer()
                bottomView
            }
        }
        .defaultTodoWidgetContainer()
    }

    private var logoView: some View {
        ZStack {
            Circle()
                .fill(Color.backgroundDanger)
                .frame(width: 32)
            Image("student-logomark")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.backgroundLightest)
                .frame(width: 18, height: 18)
        }
    }

    private var actionView: some View {
        ZStack {
            Circle()
                .fill(Color.purple)
                .frame(width: 32)
            actionIcon
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.backgroundLightest)
                .frame(width: 18, height: 18)
        }
        .frame(minHeight: 32)
    }

    private var topView: some View {
        HStack {
            Spacer()
            if let logoRoute {
                Link(destination: logoRoute) {
                    logoView
                }
            } else {
                logoView
            }
        }
    }

    private var bottomView: some View {
        HStack {
            Spacer()
            if let route = actionRoute {
                Link(destination: route) {
                    actionView
                }
            } else if let actionHandler {
                Button(action: actionHandler) {
                    actionView
                }
            } else {
                actionView
            }
        }
        .frame(maxHeight: 32)
    }
}
