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

import SwiftUI
import Core

enum DrawerState {
    case min, mid, max
    static let transaction = Transaction.exclusive(.easeInOut)
}

// Place after the main content in a ZStack(alignment: .bottom)
struct DrawerContainer<Content: View>: View {
    let content: Content
    let minHeight: CGFloat
    let maxHeight: CGFloat

    var height: CGFloat {
        switch state {
        case .min: return minHeight
        case .mid: return (minHeight + maxHeight) / 2
        case .max: return maxHeight
        }
    }

    @Environment(\.viewController) var controller

    @Binding var state: DrawerState {
        didSet {
            if state == .min {
                controller.view.endEditing(true)
            }
        }
    }
    @State var translation: CGFloat = 0

    init(
        state: Binding<DrawerState>,
        minHeight: CGFloat,
        maxHeight: CGFloat,
        @ViewBuilder content: () -> Content,
    ) {
        self.content = content()
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self._state = state
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button(action: expandCollapseButtonAction) { expandCollapseButtonImage }
                .padding(.trailing, 8)
                .padding(.leading, 14)
                .accessibilityLabel(expandCollapseButtonAccessibilityText)
                .accessibilityShowsLargeContentViewer {
                    state != .max ? Image.fullScreenLine : Image.exitFullScreenLine
                    expandCollapseButtonAccessibilityText
                }

                Button(action: dragIndicatorAction) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.borderMedium)
                        .frame(width: 36, height: 4)
                        .padding(EdgeInsets(top: 24, leading: 0, bottom: 8, trailing: 0))
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, -16)
                .highPriorityGesture(DragGesture(coordinateSpace: .global)
                    .onChanged { value in translation = -value.translation.height }
                    .onEnded { value in
                        withTransaction(DrawerState.transaction) {
                            let y = height - value.predictedEndTranslation.height - minHeight
                            let dy = maxHeight - minHeight
                            state = (y < dy * 0.25) ? .min : (y < dy * 0.75) ? .mid : .max
                            translation = 0
                        }
                    }
                )
                .accessibility(identifier: "SpeedGrader.drawerGripper")
                .accessibilityLabel(buttonA11yText)

                Button(action: openCloseButtonAction) { openCloseButtonImage }
                .padding(.horizontal, 16)
                .accessibilityLabel(openCloseButtonAccessibilityText)
                .accessibilityShowsLargeContentViewer {
                    openCloseButtonImage
                    openCloseButtonAccessibilityText
                }
            }
            .padding(.top, 16)

            Spacer(minLength: 4)
            content
        }
        .frame(maxHeight: max(minHeight, min(maxHeight, height + translation)))
        .background(DrawerBackground()
            .fill(Color.backgroundLightest)
            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 0)
        )
    }

    private func snapDrawer(to state: DrawerState) {
        withTransaction(DrawerState.transaction) {
            self.state = state
        }
    }

    private func dragIndicatorAction() {
        switch state {
        case .min: snapDrawer(to: .mid)
        case .mid: snapDrawer(to: .max)
        case .max: snapDrawer(to: .min)
        }
    }

    private var buttonA11yText: Text {
        switch state {
        case .min: Text("Open Drawer half screen", bundle: .teacher)
        case .mid: Text("Open Drawer full screen", bundle: .teacher)
        case .max: Text("Close Drawer", bundle: .teacher)
        }
    }

    @ViewBuilder
    private var expandCollapseButtonImage: some View {
        state == .max ? Image.exitFullScreenLine : Image.fullScreenLine
    }

    private func expandCollapseButtonAction() {
        state == .mid ? snapDrawer(to: .max) : snapDrawer(to: .mid)
    }

    private var expandCollapseButtonAccessibilityText: Text {
        switch state {
        case .min: Text("Expand drawer half screen", bundle: .teacher)
        case .mid: Text("Expand drawer full screen", bundle: .teacher)
        case .max: Text("Collapse drawer half screen", bundle: .teacher)
        }
    }

    @ViewBuilder
    private var openCloseButtonImage: some View {
        Image.chevronDown
            .rotationEffect(state != .min ? .degrees(0) : .degrees(180))
    }

    private func openCloseButtonAction() {
        state == .min ? snapDrawer(to: .max) : snapDrawer(to: .min)
    }

    private var openCloseButtonAccessibilityText: Text {
        state == .min ?
        Text("Open drawer full screen", bundle: .teacher) :
        Text("Close drawer", bundle: .teacher)
    }

    struct DrawerBackground: Shape {
        func path(in rect: CGRect) -> Path {
            Path(UIBezierPath(roundedRect: rect, byRoundingCorners: [ .topLeft, .topRight ], cornerRadii: CGSize(width: 12, height: 12)).cgPath)
        }
    }
}

#if DEBUG

#Preview {
    @Previewable @State var state: DrawerState = .min

    DrawerContainer(
        state: $state,
        minHeight: 32,
        maxHeight: 512,
        content: { Color.red.frame(height: 128) }
    )
}

#endif
