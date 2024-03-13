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

public struct IndeterminateBarProgressViewStyle: ProgressViewStyle {
    // MARK: - Dependencies

    private let foregroundColor: Color
    private let backgroundColor: Color

    // MARK: - Private properties

    @State private var offset: Float = -2
    private let barHeight: CGFloat = 4
    private let barWidthPercentage: CGFloat = 0.4
    private let maxOffset: Float = 1 / 0.4

    // MARK: - Init

    public init(
        foregroundColor: Color,
        backgroundColor: Color
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }

    public func makeBody(configuration _: Configuration) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(backgroundColor)
                Rectangle()
                    .foregroundColor(foregroundColor)
                    .frame(width: proxy.size.width * barWidthPercentage, height: barHeight)
                    .offset(x: proxy.size.width * barWidthPercentage * CGFloat(offset))
            }
            .clipped()
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    self.offset = maxOffset
                }
            }
        }
        .frame(height: barHeight, alignment: .leading)
        .cornerRadius(barHeight / 2)
    }
}

extension ProgressViewStyle where Self == IndeterminateBarProgressViewStyle {
    static func indeterminateBar(color: Color = .accentColor) -> IndeterminateBarProgressViewStyle {
        .init(
            foregroundColor: color,
            backgroundColor: color.opacity(ProgressViewStyleConstants.backgroundOpacity)
        )
    }

    static func indeterminateBar(foregroundColor: Color, backgroundColor: Color) -> IndeterminateBarProgressViewStyle {
        IndeterminateBarProgressViewStyle(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor
        )
    }
}

struct IndeterminateBarProgressViewStyle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .progressViewStyle(.indeterminateBar())
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressView()
            .progressViewStyle(.indeterminateBar(foregroundColor: .red, backgroundColor: .green))
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressView()
            .progressViewStyle(.indeterminateBar())
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)

        ProgressView()
            .progressViewStyle(.indeterminateBar(foregroundColor: .red, backgroundColor: .green))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
