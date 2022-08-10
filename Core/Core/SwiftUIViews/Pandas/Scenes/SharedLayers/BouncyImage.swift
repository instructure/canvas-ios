//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

struct BouncyImage: View {
    @State private var scale = 1.0
    @State private var shouldTriggerDragStartFeedback = true
    @GestureState private var dragOffset = CGSize.zero
    private let imageFileName: String
    private let feedback = UIImpactFeedbackGenerator(style: .light)
    private let springAnimation = Animation.interpolatingSpring(stiffness: 1000, damping: 10, initialVelocity: 1)

    public init(imageFileName: String) {
        self.imageFileName = imageFileName
    }

    @ViewBuilder
    public var body: some View {
        Image(imageFileName, bundle: .core)
            .scaleEffect(x: scale, y: scale)
            .gesture(pushGesture.simultaneously(with: dragGesture))
            .offset(dragOffset)
            .animation(springAnimation, value: dragOffset)
            .onChange(of: dragOffset) { dragOffset in
                if shouldTriggerDragStartFeedback {
                    shouldTriggerDragStartFeedback = false
                    feedback.impactOccurred()
                }

                if dragOffset == .zero {
                    shouldTriggerDragStartFeedback = true
                }
            }
    }

    private var pushGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { _ in
                withAnimation {
                    scale = 0.90
                }
            }
            .onEnded { _ in
                feedback.impactOccurred()
                withAnimation(springAnimation) {
                    scale = 1.0
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .global)
            .updating($dragOffset) { value, state, _ in
                var t = value.translation
                t.width *= 0.5
                t.height *= 0.5
                state = t
            }
    }
}
