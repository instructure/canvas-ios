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

struct TodoFailureView: View {

    var body: some View {
        TodoContentView(
            logoRoute: .todoListRoute,
            actionIcon: .refreshLine,
            actionHandler: {
                WidgetCenter.shared.reloadTimelines(ofKind: TodoWidget.kind)
            },
            content: { content }
        )
    }

    private var content: some View {
        VStack {
            title
                .font(.semibold12)
                .foregroundColor(.textDark)
                .allowsTightening(true)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            message
                .font(.semibold12)
                .foregroundColor(.textDark)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private let title: Text
    private let message: Text

    init(title: Text, message: Text) {
        self.title = title
        self.message = message
    }
}

#if DEBUG
struct FailureView_Previews: PreviewProvider {

    static var previews: some View {

        TodoFailureView(
            title: Text("Announcements"),
            message: Text("Please log in via the application")
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("Empty Announcements")

        TodoFailureView(
            title: Text("Grades"),
            message: Text("Please log in via the application")
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        .previewDisplayName("Empty Grades")
    }
}
#endif
