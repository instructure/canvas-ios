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
import HorizonUI
import Core

struct ModuleItemLockedView: View {
    // MARK: - Dependencies

    private let title: String
    private let lockExplanation: String

    init(
        title: String,
        lockExplanation: String
    ) {
        self.title = title
        self.lockExplanation = lockExplanation
    }

    var body: some View {
        VStack(alignment: .leading) {
            HorizonUI.Pill(
                title: String(localized: "Locked Content", bundle: .horizon),
                    style: .inline(.init(
                        textColor: Color.huiColors.text.body,
                        iconColor: Color.huiColors.surface.institution
                    )),
                    isUppercased: false,
                    icon: Image.huiIcons.lock
                )

            WebView(html: "<p class=\"lock-explanation\">\(lockExplanation)</p>")
                .frameToFit()
                .padding(.horizontal, -(.huiSpaces.space24))

            Spacer()
        }
        .padding(.huiSpaces.space24)
    }
}

#Preview {
    ModuleItemLockedView(
        title: "Locked Title",
        lockExplanation: "<html> <h1>The content is locked because it is not yet available.</h1> </html>"
    )
}
