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

    let model: TodoModel

    var body: some View {
        if model.isLoggedIn {

            if let error = model.error {
                TodoFailureView(title: Text("Failure"), message: Text("Failure message"))

            } else if model.items.isEmpty {
                TodoEmptyView(
                    title: Text("Oops! Something Went Wrong"),
                    message: Text("We're having trouble showing your tasks right now. Please try again in a bit or head to the app.")
                )
            } else {
                TodoListView(model: model)
            }

        } else {

            LoggedOutScreen(
                title: Text("Let's Get You Logged in!"),
                message: Text("To see your to-dos, please log in to your account in the app. It'll just take a sec.")
            )
        }
    }
}

extension View {
    func defaultTodoWidgetContainer() -> some View {
        containerBackground(for: .widget) { Color.mint }
    }
}

#if DEBUG

struct TodoWidgetPreviews: PreviewProvider {
    static var previews: some View {
        TodoWidgetScreen(model: TodoModel.make())
            .defaultTodoWidgetContainer()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

#endif
