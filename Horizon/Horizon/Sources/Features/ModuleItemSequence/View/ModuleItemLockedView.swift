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
        VStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.h2)

            Spacer()

            Image("PandaLocked", bundle: .core)
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 128)

            Text("Locked", bundle: .horizon)
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.h3)
                .padding(.top, .huiSpaces.primitives.medium)

            WebView(html: "<p class=\"lock-explanation\">\(lockExplanation)</p>")
                .frameToFit()

            Spacer()
        }
        .padding(.huiSpaces.primitives.mediumSmall)
    }
}

#Preview {
    ModuleItemLockedView(
        title: "Locked Title",
        lockExplanation: "<html> <h1>The content is locked because it is not yet available.</h1> </html>"
    )
}
