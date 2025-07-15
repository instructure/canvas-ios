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
import Combine
import HorizonUI
import SwiftUI

struct AssistFeedbackView: View {
    private var onChange: AssistChatMessageViewModel.OnFeedbackChange
    @State private var selected: Bool?
    @State private var thumbsOpacity: Double = 1.0
    @State private var thanksOpacity: Double = 0.0

    init(onChange: @escaping AssistChatMessageViewModel.OnFeedbackChange) {
        self.onChange = onChange
    }

    private var thumbsUpOpacity: Double {
        selected == true ? 1 : 0
    }
    private var thumbsDownOpacity: Double {
        selected == false ? 1 : 0
    }

    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: HorizonUI.spaces.space8) {
                thumbUpIcon
                thumbDownIcon
            }
            .opacity(thumbsOpacity)
            .animation(.easeInOut(duration: 0.2), value: thumbsOpacity)

            Text(String(localized: "Thank you for your feedback!", bundle: .horizon))
                .huiTypography(.p1)
                .foregroundColor(HorizonUI.colors.text.surfaceColored)
                .opacity(thanksOpacity)
                .animation(.easeInOut(duration: 0.2), value: thanksOpacity)
        }
    }

    private var thumbUpIcon: some View {
        ZStack {
            HorizonUI.icons.thumbUp
                .renderingMode(.template)
                .foregroundColor(HorizonUI.colors.text.surfaceColored)
                .onTapGesture {
                    onTap(true)
                }
            HorizonUI.icons.thumbUpFilled
                .renderingMode(.template)
                .foregroundColor(HorizonUI.colors.text.surfaceColored)
                .opacity(thumbsUpOpacity)
                .animation(.easeInOut(duration: 0.2), value: thumbsUpOpacity)
                .onTapGesture {
                    onTap(true)
                }
        }
    }

    private var thumbDownIcon: some View {
        ZStack {
            HorizonUI.icons.thumbDown
                .renderingMode(.template)
                .foregroundColor(HorizonUI.colors.text.surfaceColored)
                .onTapGesture {
                    onTap(false)
                }
            HorizonUI.icons.thumbDownFilled
                .renderingMode(.template)
                .foregroundColor(HorizonUI.colors.text.surfaceColored)
                .opacity(thumbsDownOpacity)
                .animation(.easeInOut(duration: 0.2), value: thumbsDownOpacity)
                .onTapGesture {
                    onTap(false)
                }
        }
    }

    private func onTap(_ value: Bool) {
        thumbsOpacity = 0.0
        thanksOpacity = 1.0
        selected = selected == value ? nil : value
        onChange(selected)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            thanksOpacity = 0.0
        }
    }
}

#Preview {
    @Previewable @State var selected: Bool?

    VStack(spacing: HorizonUI.spaces.space16) {
        AssistFeedbackView {
            selected = $0
        }
    }
    .frame(maxWidth: .infinity)
    .frame(maxHeight: .infinity)
    .background(HorizonUI.colors.surface.igniteAIPrimaryGradient)
}
