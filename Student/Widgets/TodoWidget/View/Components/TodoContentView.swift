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

    @ScaledMetric private var uiScale: CGFloat = 1

    fileprivate let logoRoute: URL?
    fileprivate let content: () -> Content
    fileprivate let actionView: () -> ActionView

    init(
        logoRoute: URL? = nil,
        content: @escaping () -> Content,
        actionView: @escaping () -> ActionView,
    ) {
        self.logoRoute = logoRoute
        self.content = content
        self.actionView = actionView
    }

    var body: some View {
        ZStack {
            content()
            VStack {
                topView
                Spacer()

                let aView = actionView()
                if aView.isVisible {
                    aView
                }
            }
            .padding(10)
        }
    }

    private var logoView: some View {
        ZStack {
            Circle()
                .fill(Color.backgroundDanger)
                .frame(width: 32 * uiScale.iconScale)
            Image("student-logomark")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Color.backgroundLightest)
                .frame(width: 18 * uiScale.iconScale, height: 18 * uiScale.iconScale)
        }
    }

    private var topView: some View {
        HStack {
            Spacer()
            if let logoRoute {
                Link(destination: logoRoute) {
                    logoView
                }
                .accessibilityLabel(String(localized: "Canvas Todo Widget"))
                .accessibilityHint(Text("Tap to view full list of Todos"))
            } else {
                logoView
            }
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

#endif
