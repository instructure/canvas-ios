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

struct DeterminateCircleProgressViewStyle: ProgressViewStyle {
    // MARK: - Dependencies

    private let size: CGFloat
    private let lineWidth: CGFloat
    private let color: Color

    // MARK: - Init

    init(
        size: CGFloat,
        lineWidth: CGFloat,
        color: Color = .accentColor
    ) {
        self.size = size
        self.lineWidth = lineWidth
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0
        return ZStack {
            Circle()
                .stroke(
                    color,
                    lineWidth: lineWidth
                )
                .opacity(0.2)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .transition(.scale)
        }
        .frame(width: size, height: size)
    }
}

extension ProgressViewStyle where Self == DeterminateCircleProgressViewStyle {
    static func determinateCircle(
        size: CGFloat = 32,
        lineWidth: CGFloat = 3,
        color: Color = .accentColor
    ) -> DeterminateCircleProgressViewStyle {
        DeterminateCircleProgressViewStyle(
            size: size,
            lineWidth: lineWidth,
            color: color
        )
    }
}

struct DeterminateCircularProgressViewStyle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(value: 0.25)
            .progressViewStyle(.determinateCircle())
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.75)
            .progressViewStyle(.determinateCircle())
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.75)
            .progressViewStyle(
                .determinateCircle(
                    size: 20,
                    lineWidth: 2
                )
            )
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.25)
            .progressViewStyle(.determinateCircle())
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.75)
            .progressViewStyle(.determinateCircle())
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.75)
            .progressViewStyle(
                .determinateCircle(
                    size: 20,
                    lineWidth: 2
                )
            )
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
