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

public enum PandaScene: String, CaseIterable {
    case grades

    public var backgroundFileName: String { "panda-\(rawValue)-background" }
    public var foregroundFileName: String { "panda-\(rawValue)-foreground" }
    public var offset: (background: CGSize, foreground: CGSize) {
        switch(self) {
        case .grades:
            return (background: CGSize(width: 0, height: -50),
                    foreground: CGSize(width: -25, height: 50))
        }
    }
}


public struct InteractivePanda: View {
    @State private var scale = 1.0
    @State private var dragOffset: CGSize = .zero
    @State private var shouldTriggerDragStartFeedback = true
    private let scene: PandaScene
    private let feedback = UIImpactFeedbackGenerator(style: .light)

    public init(scene: PandaScene) {
        self.scene = scene
    }

    @ViewBuilder
    public var body: some View {
        MotionScene { detector in
            let offset = scene.offset
            Image(scene.backgroundFileName, bundle: .core)
                .motion(detector, horizontalMultiplier: -40, verticalMultiplier: -10)
                .offset(offset.background)
            Image(scene.foregroundFileName, bundle: .core)
                .motion(detector, horizontalMultiplier: 40, verticalMultiplier: 10)
                .scaleEffect(x: scale, y: scale)
                .gesture(pushGesture.simultaneously(with: dragGesture))
                .offset(offset.foreground)
                .offset(dragOffset)
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
                let animation = Animation.interpolatingSpring(stiffness: 1000, damping: 10, initialVelocity: 1)
                withAnimation(animation) {
                    scale = 1.0
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .global)
            .onChanged { value in
                var t = value.translation
                t.width *= 0.5
                t.height *= 0.5
                dragOffset = t

                if shouldTriggerDragStartFeedback {
                    shouldTriggerDragStartFeedback = false
                    feedback.impactOccurred()
                }
            }
            .onEnded { _ in
                shouldTriggerDragStartFeedback = true
                feedback.impactOccurred()
                let animation = Animation.interpolatingSpring(stiffness: 1000, damping: 10, initialVelocity: 1)
                withAnimation(animation) {
                    dragOffset = .zero
                }
            }
    }
}

struct InteractivePanda_Previews: PreviewProvider {
    static var previews: some View {
        InteractivePanda(scene: .grades)
    }
}
