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

import SwiftUI
import Core

struct AssistFlashCardItemView: View {
    let item: AssistFlashCardModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .font(.regular16)
            Spacer()
            Text(item.currentContent)
                .multilineTextAlignment(.leading)
                .font(.regular20)

            Spacer()
            Text("Tap to flip", bundle: .horizon)
                .font(.regular12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(item.isFlipped ? Color.textLightest : Color.textDark)
        .rotation3DEffect(.degrees(item.isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(item.isFlipped ? Color.backgroundLightest.opacity(0.2) : Color.backgroundLightest)
        }
    }
}

#if DEBUG
#Preview {
    AssistFlashCardItemView(item: AssistFlashCardModel.mock[0])
}
#endif
