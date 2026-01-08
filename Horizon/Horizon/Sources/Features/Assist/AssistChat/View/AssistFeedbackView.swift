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

import Combine
import HorizonUI
import SwiftUI

struct AssistFeedbackView: View {
    private var onChange: (Bool?) -> Void
    @State private var selected: Bool?
    @State private var isFeedbackVisiable = true
    @State private var opacity: Double = 0.0

    init(onChange: @escaping (Bool?) -> Void) {
        self.onChange = onChange
    }

    var body: some View {
        VStack {
            if selected == nil {
                HStack(spacing: HorizonUI.spaces.space8) {
                    thumbUpIcon
                    thumbDownIcon
                }
                .padding(.top, .huiSpaces.space8)
            }

            if selected != nil, isFeedbackVisiable {
                Text(String(localized: "Thank you for your feedback!", bundle: .horizon))
                    .huiTypography(.p1)
                    .foregroundColor(HorizonUI.colors.text.surfaceColored)
                    .opacity(opacity)
                    .animation(.easeInOut(duration: 0.2), value: opacity)
                    .padding(.top, .huiSpaces.space10)
            }
        }
        .animation(.smooth, value: selected)
    }

    private var thumbUpIcon: some View {
        HorizonUI.icons.thumbUp
            .foregroundStyle(HorizonUI.colors.text.surfaceColored)
            .onTapGesture { onTap(true) }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: "Like"))
            .accessibilityAddTraits(.isButton)

    }

    private var thumbDownIcon: some View {
        HorizonUI.icons.thumbDown
            .foregroundStyle(HorizonUI.colors.text.surfaceColored)
            .onTapGesture { onTap(false) }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: "Unlike"))
            .accessibilityAddTraits(.isButton)
    }

    private func onTap(_ value: Bool) {
        opacity = 1
        selected = value
        onChange(selected)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                opacity = 0.0
            } completion: {
                isFeedbackVisiable = false
            }
        }
    }
}
