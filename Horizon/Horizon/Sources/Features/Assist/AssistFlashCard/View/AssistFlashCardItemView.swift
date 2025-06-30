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

import HorizonUI
import SwiftUI
import Core

struct AssistFlashCardItemView: View {
    let item: AssistFlashCardModel
    @State private var height: CGFloat = 0
    @State private var isScrollable: Bool = true

    private var isFlipped: Bool {
        item.isFlipped
    }

    private var textColor: Color {
        isFlipped ? HorizonUI.colors.text.body : HorizonUI.colors.text.surfaceColored
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Text(item.title)
                    .foregroundStyle(textColor)
                    .huiTypography(.p1)
                    .padding(.horizontal, HorizonUI.spaces.space24)
                    .padding(.top, HorizonUI.spaces.space24)
                Spacer()
                ScrollView(
                    [.vertical],
                    showsIndicators: isScrollable
                ) {
                    Text(item.currentContent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(textColor)
                        .huiTypography(.sh3)
                        .padding(.horizontal, HorizonUI.spaces.space24)
                        .readingFrame { frame in
                            isScrollable = frame.size.height > geometry.size.height
                            height = frame.size.height
                        }
                }
                .frame(height: height)
                .disabled(!isScrollable)
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Text("Tap to flip", bundle: .horizon)
                    .huiTypography(.labelSmall)
                    .foregroundStyle(textColor)
                    .padding(.horizontal, HorizonUI.spaces.space24)
                    .padding(.bottom, HorizonUI.spaces.space24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(item.isFlipped ? Color.textLightest : Color.textDark)
            .rotation3DEffect(.degrees(item.isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))
            .background {
                RoundedRectangle(cornerRadius: HorizonUI.spaces.space16)
                    .fill(Color.backgroundLightest.opacity(item.isFlipped ? 1.0 : 0.1))
            }
        }
    }
}

#if DEBUG
#Preview {
    AssistFlashCardItemView(item: AssistFlashCardModel.mock[0])
}
#endif
