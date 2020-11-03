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
    static let transaction = Transaction.exclusive(.spring(response: 0.5, dampingFraction: 0.7))
}

// Place after the main content in a ZStack(alignment: .bottom)
struct Drawer<Content: View>: View {
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
    @Binding var state: DrawerState
    @GestureState var translation: CGFloat = 0

    init(state: Binding<DrawerState>, minHeight: CGFloat, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self._state = state.transaction(DrawerState.transaction)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: buttonAction, label: { HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.borderMedium)
                    .frame(width: 36, height: 4)
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 8, trailing: 0))
                Spacer()
            } })
                .padding(.top, -16)
                .highPriorityGesture(DragGesture(coordinateSpace: .global)
                    .updating($translation) { value, state, transaction in
                        state = -value.translation.height
                        transaction = DrawerState.transaction
                    }
                    .onEnded { value in
                        let y = height - value.predictedEndTranslation.height - minHeight
                        let dy = maxHeight - minHeight
                        state = (y < dy * 0.25) ? .min : (y < dy * 0.75) ? .mid : .max
                    }
                )
                .accessibility(identifier: "SpeedGrader.drawerGripper")
                .accessibility(label: buttonA11yText)
            content
        }
            .background(DrawerBackground()
                .fill(Color.backgroundLightest)
                .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 0)
            )
            .frame(maxWidth: 800, maxHeight: max(minHeight, min(maxHeight, height + translation)))
    }

    func buttonAction() {
        switch state {
        case .min: state = .mid
        case .mid: state = .max
        case .max: state = .min
        }
    }

    var buttonA11yText: Text {
        switch state {
        case .min: return Text("Open Drawer half screen")
        case .mid: return Text("Open Drawer full screen")
        case .max: return Text("Close Drawer")
        }
    }

    struct DrawerBackground: Shape {
        func path(in rect: CGRect) -> Path {
            Path(UIBezierPath(roundedRect: rect, byRoundingCorners: [ .topLeft, .topRight ], cornerRadii: CGSize(width: 12, height: 12)).cgPath)
        }
    }
}
