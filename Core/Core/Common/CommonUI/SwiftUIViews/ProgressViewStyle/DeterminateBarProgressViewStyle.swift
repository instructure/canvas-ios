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

public struct DeterminateBarProgressViewStyle: ProgressViewStyle {
    // MARK: - Dependencies

    private let foregroundColor: Color
    private let backgroundColor: Color

    // MARK: - Private properties

    private let barHeight: CGFloat = 4

    // MARK: - Init

    public init(
        foregroundColor: Color,
        backgroundColor: Color
    ) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0
        return GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(backgroundColor)
                Rectangle()
                    .foregroundColor(foregroundColor)
                    .frame(width: proxy.size.width * CGFloat(progress), alignment: .leading)
                    .animation(.easeInOut, value: 0.7)
            }
            .clipped()
        }
        .frame(height: barHeight, alignment: .leading)
        .cornerRadius(barHeight / 2)
    }
}

extension ProgressViewStyle where Self == DeterminateBarProgressViewStyle {
    static func determinateBar(color: Color = .accentColor) -> DeterminateBarProgressViewStyle {
        .init(
            foregroundColor: color,
            backgroundColor: color.opacity(ProgressViewStyleConstants.backgroundOpacity)
        )
    }

    static func determinateBar(foregroundColor: Color, backgroundColor: Color) -> DeterminateBarProgressViewStyle {
        DeterminateBarProgressViewStyle(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor
        )
    }
}

struct DeterminateBarProgressViewStyle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(value: 0.25)
            .progressViewStyle(.determinateBar())
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.75)
            .progressViewStyle(.determinateBar(color: .red))
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.75)
            .progressViewStyle(
                .determinateBar(
                    foregroundColor: .red,
                    backgroundColor: .green
                )
            )
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.25)
            .progressViewStyle(.determinateBar())
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.75)
            .progressViewStyle(.determinateBar())
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.75)
            .progressViewStyle(
                .determinateBar(
                    foregroundColor: .red,
                    backgroundColor: .green
                )
            )
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
