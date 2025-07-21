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

    var isClosed: Bool { self == .min }
    var isOpen: Bool { self != .min }
    var isHalfOpen: Bool { self == .mid }
    var isFullyOpen: Bool { self == .max }
}

// Place after the main content in a ZStack(alignment: .bottom)
struct DrawerContainer<Content: View>: View {

    @Environment(\.viewController) var controller

    private let content: Content
    private let minHeight: CGFloat
    private let maxHeight: CGFloat

    private var height: CGFloat {
        switch state {
        case .min: return minHeight
        case .mid: return (minHeight + maxHeight) / 2
        case .max: return maxHeight
        }
    }

    @Binding private var state: DrawerState {
        didSet {
            if state.isClosed {
                controller.view.endEditing(true)
            }
        }
    }
    @State private var translation: CGFloat = 0

    private let openHalfScreenText = Text("Open drawer half screen", bundle: .teacher)
    private let openFullScreenText = Text("Open drawer full screen", bundle: .teacher)
    private let collapseHalfScreenText = Text("Collapse drawer half screen", bundle: .teacher)
    private let closeDrawerText = Text("Close drawer", bundle: .teacher)

    init(
        state: Binding<DrawerState>,
        minHeight: CGFloat,
        maxHeight: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self._state = state
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                expandCollapseButton

                dragIndicator
                    .frame(maxWidth: .infinity)

                openCloseButton
            }
            .paddingStyle(.horizontal, .standard)
            .padding(.vertical, 8)

            content
        }
        .frame(maxHeight: max(minHeight, min(maxHeight, height + translation)))
        .background(DrawerBackground()
            .fill(Color.backgroundLightest)
            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 0)
        )
    }

    // MARK: - Expand/Collapse Button

    private var expandCollapseButton: some View {
        Button(action: expandCollapseButtonAction) {
            expandCollapseButtonImage
        }
        .accessibilityLabel(expandCollapseButtonAccessibilityText)
        .accessibilityShowsLargeContentViewer {
            expandCollapseButtonImage
            expandCollapseButtonAccessibilityText
        }
    }

    private func expandCollapseButtonAction() {
        switch state {
        case .min, .mid: snapDrawer(to: .max)
        case .max: snapDrawer(to: .mid)
        }
    }

    private var expandCollapseButtonImage: Image {
        switch state {
        case .min, .mid: .fullScreenLine
        case .max: .exitFullScreenLine
        }
    }

    private var expandCollapseButtonAccessibilityText: Text {
        switch state {
        case .min, .mid: openFullScreenText
        case .max: collapseHalfScreenText
        }
    }

    // MARK: - Drag Indicator

    private var dragIndicator: some View {
        Button(action: dragIndicatorAction) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.borderMedium)
                .frame(width: 36, height: 4)
                .frame(height: Image.defaultIconSize)
        }
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
        .accessibilityLabel(dragIndicatorAccessibilityText)
    }

    private func dragIndicatorAction() {
        switch state {
        case .min: snapDrawer(to: .mid)
        case .mid: snapDrawer(to: .max)
        case .max: snapDrawer(to: .min)
        }
    }

    private var dragIndicatorAccessibilityText: Text {
        switch state {
        case .min: openHalfScreenText
        case .mid: openFullScreenText
        case .max: closeDrawerText
        }
    }

    // MARK: - Open/Close Button

    private var openCloseButton: some View {
        Button(action: openCloseButtonAction) {
            openCloseButtonImage
        }
        .accessibilityLabel(openCloseButtonAccessibilityText)
        .accessibilityShowsLargeContentViewer {
            openCloseButtonImage
            openCloseButtonAccessibilityText
        }
    }

    private func openCloseButtonAction() {
        switch state {
        case .min: snapDrawer(to: .mid)
        case .mid, .max: snapDrawer(to: .min)
        }
    }

    private var openCloseButtonImage: some View {
        let isOpenAction = switch state {
        case .min: true
        case .mid, .max: false
        }
        return Image.chevronDown
            .rotationEffect(isOpenAction ? .degrees(180) : .degrees(0))
    }

    private var openCloseButtonAccessibilityText: Text {
        switch state {
        case .min: openHalfScreenText
        case .mid, .max: closeDrawerText
        }
    }

    // MARK: - Drawer Management

    private func snapDrawer(to state: DrawerState) {
        withTransaction(DrawerState.transaction) {
            self.state = state
        }
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

    ZStack(alignment: .bottom) {
        Color.gray.opacity(0.2)

        DrawerContainer(
            state: $state,
            minHeight: 128,
            maxHeight: 512,
            content: { Color.red.frame(maxHeight: .infinity) }
        )
    }
}

#endif
