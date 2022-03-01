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

public struct GradesPanda: PandaScene {
    public var name: String { "grades" }
    public var offset: (background: CGSize, foreground: CGSize) {(
        background: CGSize(width: 0, height: -50),
        foreground: CGSize(width: -25, height: 50)
    )}
    public var background: AnyView { AnyView(Board(imageName: backgroundFileName)) }
}

private struct Board: View {
    @State private var rotation: Double = 0
    private let image: Image
    private let feedback = UIImpactFeedbackGenerator(style: .heavy)

    public init(imageName: String) {
        self.image = Image(imageName, bundle: .core)
    }

    @ViewBuilder
    public var body: some View {
        image
            .rotationEffect(Angle(degrees: rotation))
            .onTapGesture {
                feedback.impactOccurred()
                let range: ClosedRange<Double> = (rotation > 0 ? -10...0 : 0...10)
                rotation = Double.random(in: range)
            }
    }
}

struct Board_Previews: PreviewProvider {
    static var previews: some View {
        Board(imageName: GradesPanda().backgroundFileName)
    }
}
