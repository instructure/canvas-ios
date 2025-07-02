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
import WidgetKit

enum CourseTotalGradeStatus {
    case failure
    case loggedOut

    var iconName: String {
        switch self {
        case .failure: "PandaUnsupported"
        case .loggedOut: "no-match-panda"
        }
    }

    var title: String {
        switch self {
        case .failure:
            String(localized: "Something Went Wrong!")
        case .loggedOut:
            String(localized: "Let's Get You Logged In!")
        }
    }

    var subtitle: String {
        switch self {
        case .failure:
            String(localized: "We're having trouble showing your grades right now.")
        case .loggedOut:
            String(localized: "To see your grades, please log in to your account in the app.")
        }
    }
}

struct CourseTotalGradeStatusView: View {

    @Environment(\.widgetFamily) private var family
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let status: CourseTotalGradeStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(status.iconName, bundle: .core)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                .accessibilityLabel(Text("Canvas single grade widget"))
            VStack(alignment: .leading, spacing: 4) {
                Text(status.title)
                    .font(.scaledRestrictly(.semibold12))
                    .foregroundStyle(Color.textDarkest)
                Text(status.subtitle)
                    .font(.scaledRestrictly(.regular12))
                    .foregroundStyle(Color.textDarkest)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG

struct CourseTotalGradeErrorView_Previews: PreviewProvider {

    static var previews: some View {
        CourseTotalGradeStatusView(status: .failure)
            .defaultWidgetContainerBackground()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Failure")

        CourseTotalGradeStatusView(status: .loggedOut)
            .defaultWidgetContainerBackground()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Logged Out")
    }
}

#endif
