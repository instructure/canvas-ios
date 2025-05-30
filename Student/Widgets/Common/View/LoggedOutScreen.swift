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

struct LoggedOutScreen: View {
    var body: some View {
        VStack {
            HStack {
                title
                    .font(.semibold12)
                    .foregroundColor(.textDark)
                    .allowsTightening(true)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
                Image("student-logomark")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            message
                .font(.semibold12)
                .foregroundColor(.textDark)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .containerBackground(for: .widget) {
            SwiftUI.EmptyView()
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
struct LoggedOutScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoggedOutScreen(title: Text("Let's Get You Logged in!"),
                  message: Text("To see your to-dos, please log in to your account in the app. It'll just take a sec."))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Logged out Todo")
    }
}
#endif
