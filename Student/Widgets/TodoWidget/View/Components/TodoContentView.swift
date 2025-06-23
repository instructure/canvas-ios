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

import WidgetKit
import SwiftUI
import AppIntents

struct TodoContentView<Content: View, ActionView: BottomActionView>: View {

    fileprivate let logoRoute: URL?
    fileprivate let content: () -> Content
    fileprivate let actionView: () -> ActionView

    init(
        logoRoute: URL? = nil,
        content: @escaping () -> Content,
        actionView: @escaping () -> ActionView
    ) {
        self.logoRoute = logoRoute
        self.content = content
        self.actionView = actionView
    }

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerRelativeFrame(.vertical, alignment: .top)
            .accessibilitySortPriority(1)
            .overlay(alignment: .topTrailing) {
                Group {
                    if let logoRoute {
                        Link(destination: logoRoute) {
                            LogoView()
                        }
                        .accessibilityLabel(Text("Canvas To-do Widget"))
                        .accessibilityHint(Text("Double tap to view full list of to-dos"))
                        .accessibilitySortPriority(2)
                    } else {
                        LogoView()
                            .accessibilityHidden(true)
                    }
                }
                .padding(10)
            }
            .overlay(alignment: .bottomTrailing) {
                let aView = actionView()
                if aView.isVisible {
                    aView.padding(10)
                }
            }
    }
}

private struct LogoView: View {

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.backgroundDanger)
                .scaledFrame(width: 32, useIconScale: true)
            Image("student-logomark")
                .renderingMode(.template)
                .scaledIcon(size: 18)
                .foregroundStyle(Color.backgroundLightest)
        }
    }
}

extension TodoContentView where ActionView == NoActionView {

    init(logoRoute: URL? = nil, content: @escaping () -> Content) {
        self.logoRoute = logoRoute
        self.content = content
        self.actionView = { ActionView() }
    }
}

#if DEBUG

#Preview("TodoWidgetData", as: .systemMedium) {
    TodoWidget()
} timeline: {
    TodoWidgetEntry(data: TodoModel.make(), date: Date())
}

#Preview("TodoWidgetFailure", as: .systemLarge) {
    TodoWidget()
} timeline: {
    let model = TodoModel(error: .fetchingDataFailure)
    TodoWidgetEntry(data: model, date: Date())
}

#Preview("TodoWidgetLoggedout", as: .systemLarge) {
    TodoWidget()
} timeline: {
    let model = TodoModel(isLoggedIn: false)
    TodoWidgetEntry(data: model, date: Date())
}

#Preview("TodoWidgetEmpty", as: .systemLarge) {
    TodoWidget()
} timeline: {
    let model = TodoModel(items: [])
    TodoWidgetEntry(data: model, date: Date())
}

#endif
