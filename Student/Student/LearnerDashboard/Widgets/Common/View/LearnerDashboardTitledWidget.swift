//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core
import SwiftUI

struct LearnerDashboardTitledWidget<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: InstUI.Styles.Padding.sectionHeaderVertical.rawValue
        ) {
            Text(title)
                .font(.regular14, lineHeight: .fit)
                .foregroundColor(.textDarkest)
            content
        }
    }
}

#if DEBUG

#Preview {
    LearnerDashboardTitledWidget("Weekly Summary") {
        Text(verbatim: InstUI.PreviewData.loremIpsumShort)
    }
}

#endif
