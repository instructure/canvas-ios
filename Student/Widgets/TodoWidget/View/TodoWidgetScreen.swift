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

struct TodoWidgetScreen: View {
    private let model: TodoModel

    @Environment(\.widgetFamily)
    private var family
    private let lineCountByFamily: [WidgetFamily: Int] = [
        .systemMedium: 2,
        .systemLarge: 5,
        .systemExtraLarge: 5
    ]

    var body: some View {
        buildView()
            .containerBackground(for: .widget) {
                Color.backgroundLightest
            }
    }

    @ViewBuilder
    private func buildView() -> some View {
        if model.todoItems.isNotEmpty {
            switch family {
            case .systemMedium:
                MediumTodoScreen(model: model)
            case .systemLarge:
                MediumTodoScreen(model: model)
            default:
                MediumTodoScreen(model: model)
            }
        } else if model.isLoggedIn {
            EmptyView(title: Text("Oops! Something Went Wrong"), message: Text("We're having trouble showing your tasks right now. Please try again in a bit or head to the app."))
        } else {
            LoggedOutScreen(title: Text("Let's Get You Logged in!"), message: Text("To see your to-dos, please log in to your account in the app. It'll just take a sec."))
        }
    }

    init(model: TodoModel) {
        self.model = model
    }
}

#if DEBUG

struct TodoWidgetPreviews: PreviewProvider {
    static var previews: some View {
        TodoWidgetScreen(model: TodoModel.make()).previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

#endif
