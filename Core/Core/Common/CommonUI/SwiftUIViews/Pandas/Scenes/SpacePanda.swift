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

public struct SpacePanda: PandaScene {
    public var name: String { "space" }
    public var offset: (background: CGSize, foreground: CGSize) {(
        background: CGSize(width: 0, height: 0),
        foreground: CGSize(width: -56, height: 5))
    }
    public var height: CGFloat { 180 }
    public var foreground: AnyView { AnyView(AstronautPanda(imageName: foregroundFileName)) }
    public var background: AnyView { AnyView(Stars(imageName: backgroundFileName)) }

    public init() {}
}

private struct Stars: View {
    @State private var isDragging = false
    @State private var rotation: Double = 0
    @State private var initialRotation: Double = 0
    private let image: Image

    public init(imageName: String) {
        self.image = Image(imageName, bundle: .core)
    }

    @ViewBuilder
    public var body: some View {
        let gesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                if !isDragging {
                    initialRotation = rotation
                    isDragging = true
                }
                rotation = initialRotation + value.translation.height
            }
            .onEnded { _ in
                isDragging = false
            }
        image
            .rotationEffect(.degrees(rotation))
            .gesture(gesture)
    }
}

private struct AstronautPanda: View {
    @State private var rotation: Double = 0
    private let imageName: String

    public init(imageName: String) {
        self.imageName = imageName
    }

    @ViewBuilder
    public var body: some View {
        Image(imageName, bundle: .core)
            .offset(x: 30, y: 0)
            .rotationEffect(.degrees(rotation))
            .allowsHitTesting(false)
            .animation(.easeOut(duration: 360), value: rotation)
            .onAppear {
                rotation = 3600
            }
    }
}

struct SpacePanda_Previews: PreviewProvider {
    static var previews: some View {
        InteractivePanda(scene: SpacePanda())
    }
}
