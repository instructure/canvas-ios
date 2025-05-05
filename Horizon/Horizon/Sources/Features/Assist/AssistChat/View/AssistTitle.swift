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

import HorizonUI
import SwiftUI

struct AssistTitle: View {
    typealias AssistTitleClose = () -> Void

    private let onClose: AssistTitleClose?

    init(onClose: AssistTitleClose? = nil) {
        self.onClose = onClose
    }

    var body: some View {
        HStack {
            closeButton()
                .opacity(0)

            title

           closeButton()
        }
    }

    private var title: some View {
        HStack {
            HorizonUI.icons.ai
            Text(String(localized: "Assist", bundle: .horizon))
                .font(.bold20)
        }
        .foregroundStyle(Color.textLightest)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func closeButton() -> some View {
        if let onClose = onClose {
            HorizonUI.IconButton(
                Image(systemName: "xmark"),
                type: .white,
                isSmall: true,
                action: onClose
            )
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        AssistTitle {
        }
    }
    .frame(maxHeight: .infinity)
    .padding(.horizontal, .huiSpaces.space16)
    .background(Color.gray)
}
