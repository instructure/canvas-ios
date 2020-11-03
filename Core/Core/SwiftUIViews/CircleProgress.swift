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

public struct CircleProgress: View {
    public let color: Color
    public let progress: CGFloat?
    public let size: CGFloat
    public let thickness: CGFloat

    let ease = Animation.timingCurve(0.25, 0.1, 0.25, 1.0, duration: 0.875)
    let timer = Timer.publish(every: 0.875, on: .main, in: .common).autoconnect()
    @State var fillWidth: CGFloat = 0.1
    @State var fillRotate: Angle = .zero
    @State var rotate: Angle = .zero

    public init(
        color: Color = Color(Brand.shared.primary),
        progress: CGFloat? = nil,
        size: CGFloat = 40,
        thickness: CGFloat = 3
    ) {
        self.color = color
        self.progress = progress
        self.size = size
        self.thickness = thickness
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color.borderLight, lineWidth: thickness)
            if progress != nil {
                Circle()
                    .trim(from: 0, to: progress!)
                    .stroke(Color.accentColor, lineWidth: thickness)
                    .rotationEffect(Angle(radians: -0.5 * .pi))
            } else {
                Circle()
                    .trim(from: 0, to: fillWidth)
                    .stroke(Color.accentColor, lineWidth: thickness)
                    .rotationEffect(fillRotate)
                    .onReceive(timer) { _ in withAnimation(ease) {
                        fillRotate += Angle(radians: fillWidth == 0.1 ? 0.5 * .pi : 1.5 * .pi)
                        fillWidth = fillWidth == 0.1 ? 0.725 : 0.1
                    } }

                    .rotationEffect(rotate)
                    .onAppear { withAnimation(Animation.linear(duration: 2.25).repeatForever(autoreverses: false)) {
                        rotate = Angle(radians: 2 * .pi)
                    } }
            }
        }
            .padding(thickness / 2)
            .accentColor(color)
            .frame(width: size, height: size)
    }
}

#if DEBUG
struct CircleProgress_Previews: PreviewProvider {
    @ViewBuilder
    static var previews: some View {
        CircleProgress(progress: nil)
        CircleProgress(progress: 0.25)
        CircleProgress(progress: 0.5)
        CircleProgress(progress: 0.9)
    }
}
#endif
