//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

struct EmptyView: View {
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.semibold12).foregroundColor(.textDark)
                Spacer()
                Image("student-logomark")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            Text(message)
                .font(.semibold12)
                .foregroundColor(.textDark)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }.padding()
    }

    private let title: String
    private let message: String

    init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}

#if DEBUG
struct EmptyView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView(title: "Announcements", message: "Please log in via the application").previewContext(WidgetPreviewContext(family: .systemSmall))
        EmptyView(title: "Grades", message: "Please log in via the application").previewContext(WidgetPreviewContext(family: .systemMedium))
        EmptyView(title: "Grades", message: "Please log in via the application").previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
#endif
