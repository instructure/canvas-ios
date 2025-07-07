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
import Core
import SwiftUI
import AppIntents

struct TodoFailureView: View {

    var body: some View {
        TodoContentView(
            content: {
                TodoStatusView(status: .failure)
                    .invalidatableContent()
            },
            actionView: {
                IntentActionView(
                    icon: .refreshSolid,
                    intent: ReloadWidgetIntent(),
                    accessibilityLabel: String(localized: "Reload")
                )
            }
        )
    }
}

#if DEBUG
struct TodoFailureView_Previews: PreviewProvider {
    static var previews: some View {

        TodoFailureView()
            .defaultTodoWidgetContainer()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Failure Todo - Medium")

        TodoFailureView()
            .defaultTodoWidgetContainer()
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .previewDisplayName("Failure Todo - Large")
    }
}
#endif
