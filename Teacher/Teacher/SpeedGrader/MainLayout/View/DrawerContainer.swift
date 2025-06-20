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
struct DrawerContainer<Content: View, Leading: View, Trailing: View>: View {
    let content: Content
    let leadingContent: Leading
    let trailingContent: Trailing
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
        @ViewBuilder leadingContent: () -> Leading,
        @ViewBuilder trailingContent: () -> Trailing
    ) {
        self.content = content()
        self.leadingContent = leadingContent()
        self.trailingContent = trailingContent()
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self._state = state
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                leadingContent
                    .padding(.trailing, 8)
                    .padding(.leading, 14)

                Button(action: buttonAction) {
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
                .accessibility(label: buttonA11yText)

                trailingContent
                    .padding(.horizontal, 16)
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

    func buttonAction() { withTransaction(DrawerState.transaction) {
        switch state {
        case .min: state = .mid
        case .mid: state = .max
        case .max: state = .min
        }
    } }

    var buttonA11yText: Text {
        switch state {
        case .min: return Text("Open Drawer half screen", bundle: .teacher)
        case .mid: return Text("Open Drawer full screen", bundle: .teacher)
        case .max: return Text("Close Drawer", bundle: .teacher)
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

    DrawerContainer(
        state: $state,
        minHeight: 32,
        maxHeight: 512,
        content: { Color.red.frame(height: 128) },
        leadingContent: { Image(systemName: "chevron.left") },
        trailingContent: { Image(systemName: "chevron.right") }
    )
}

#endif
