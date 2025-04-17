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

import Core
import SwiftUI

struct RubricCircle<Content: View>: View {
    @Binding private var isOn: Bool
    @State private var showTooltip = false
    private let tooltip: String
    private let content: Content
    private let containerFrame: CGRect

    init(
        isOn: Binding<Bool>,
        tooltip: String = "",
        containerFrame: CGRect = .null,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self._isOn = isOn
        self.tooltip = tooltip
        self.containerFrame = containerFrame
    }

    var body: some View {
        content
            .font(.medium20)
            .foregroundColor(isOn ? Color(Brand.shared.buttonPrimaryText) : .textDark)
            .frame(minWidth: 48, minHeight: 48, maxHeight: 48)
            .background(isOn ?
                RoundedRectangle(cornerRadius: 24).fill(Color(Brand.shared.buttonPrimaryBackground)) :
                nil
            )
            .background(!isOn ?
                RoundedRectangle(cornerRadius: 24).stroke(Color.borderMedium) :
                nil
            )
            .accessibility(addTraits: isOn ? [.isButton, .isSelected] : .isButton)
            .onTapGesture { isOn.toggle() }
            // Minimumduration is infinity so the gesture never succeeds and completes but we detect that it's in progress.
            .onLongPressGesture(minimumDuration: .infinity, perform: {}, onPressingChanged: { isLongPressing in
                // The gesture recognition starts as soon the user touches down but we want the appear animation
                // to be delayed to have the long press effect. Also, this delay is enough to timeout the tap gesture
                // so it won't toggle the state while the tooltip is also visible.
                let animationStartDelay = isLongPressing ? 0.5 : 0
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(animationStartDelay)) {
                    showTooltip = isLongPressing
                }
            })
            .overlay(!showTooltip || tooltip.isEmpty ? nil :
                GeometryReader { geometry in
                    let bubbleToCircleOffset: CGFloat = 16
                    let padding: CGFloat = 16
                    // Don't go over 600 in width otherwise it will be one long line in portrait mode on iPad
                    let maxWidth = min(600, containerFrame.width - 2 * padding)
                    let maxHeight: CGFloat = 300

                    Text(tooltip)
                        .foregroundColor(.textLightest)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.backgroundDarkest))
                        .offset(x: geometry.size.width / 2) // start with align leading to circle's center
                        // Center the bubble on the circle and make sure it doesn't go out of the parent
                        .alignmentGuide(.leading) { size in
                            let circleCenter = geometry.frame(in: .global).midX
                            let offsetToCenterOnBubble = size.width / 2
                            let bubbleLeading = circleCenter - offsetToCenterOnBubble
                            let bubbleTrailing = circleCenter + offsetToCenterOnBubble
                            let containerLeading = containerFrame.minX + padding
                            let containerTrailing = containerFrame.maxX - padding

                            if bubbleLeading < containerLeading {
                                return offsetToCenterOnBubble - (containerLeading - bubbleLeading)
                            }

                            if bubbleTrailing > containerTrailing {
                                return offsetToCenterOnBubble + (bubbleTrailing - containerTrailing)
                            }

                            return offsetToCenterOnBubble
                        }
                        // This pushes the bubble on top of the circle
                        .alignmentGuide(.bottom) { size in size.height + maxHeight + bubbleToCircleOffset }
                        // Alignment must match the guides we use above otherwise they don't get called
                        .frame(width: maxWidth, height: maxHeight, alignment: .bottomLeading)
                }
                .transition(.scale.combined(with: .opacity)), alignment: .bottomLeading)
    }
}
