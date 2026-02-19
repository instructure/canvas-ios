//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

public struct DeterminateBorderedBarProgressViewStyle: ProgressViewStyle {
    private let foregroundColor: Color
    private let borderColor: Color
    private let backgroundColor: Color

    private let barHeight: CGFloat = 4
    private let borderWidth: CGFloat = 0.5

    public init(
        foregroundColor: Color,
        borderColor: Color,
        backgroundColor: Color
    ) {
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.backgroundColor = backgroundColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        GeometryReader { proxy in
            HStack(spacing: 0) {
                Rectangle()
                    .foregroundStyle(foregroundColor)
                    .frame(width: proxy.size.width * fractionCompleted)

                Rectangle()
                    .foregroundStyle(backgroundColor)
                    .frame(width: proxy.size.width * (1 - fractionCompleted))
            }
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(borderColor, lineWidth: borderWidth)
            }
            .animation(.default, value: fractionCompleted)
        }
        .frame(height: barHeight)
    }
}

public extension ProgressViewStyle where Self == DeterminateBorderedBarProgressViewStyle {
    static func determinateBorderedBar(
        color: Color = .accentColor,
        backgroundColor: Color = .clear
    ) -> DeterminateBorderedBarProgressViewStyle {
        DeterminateBorderedBarProgressViewStyle(
            foregroundColor: color,
            borderColor: color,
            backgroundColor: .clear
        )
    }

    static func determinateBorderedBar(
        foregroundColor: Color,
        borderColor: Color,
        backgroundColor: Color = .clear
    ) -> DeterminateBorderedBarProgressViewStyle {
        DeterminateBorderedBarProgressViewStyle(
            foregroundColor: foregroundColor,
            borderColor: borderColor,
            backgroundColor: backgroundColor
        )
    }
}

#Preview("Stepper") {
    @Previewable @State var value = 0.5

    VStack {
        Button("Random") {
            value = .random(in: 0...1)
        }

        ProgressView(value: value)
            .progressViewStyle(.determinateBorderedBar())
    }
    .padding()
}

#Preview("Variants") {
    VStack {
        ProgressView(value: 0.25)
            .progressViewStyle(.determinateBorderedBar())

        ProgressView(value: 0.75)
            .progressViewStyle(.determinateBorderedBar(color: .red))

        ProgressView(value: 0.75)
            .progressViewStyle(
                .determinateBorderedBar(
                    color: .red,
                    backgroundColor: .green
                )
            )

        ProgressView(value: 0.25)
            .progressViewStyle(.determinateBorderedBar())

        ProgressView(value: 0.75)
            .progressViewStyle(.determinateBorderedBar())

        ProgressView(value: 0.75)
            .progressViewStyle(
                .determinateBorderedBar(
                    foregroundColor: .red,
                    borderColor: .blue,
                    backgroundColor: .green
                )
            )
    }
    .padding(.horizontal, 32)
    .frame(maxHeight: .infinity)
    .background(.backgroundDarkest)
}
