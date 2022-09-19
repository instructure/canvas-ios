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

struct ProgressBar: View {
    private var progress: Float?
    private let foregroundColor: Color
    private let backgroundColor: Color

    @State private var offset: Float = -2

    private let barHeight: CGFloat = 4
    private let barWidthPercentage: CGFloat = 0.4
    private let maxOffset: Float = 1 / 0.4

    /**
     - parameters:
        - progress: Initializing with `nil` means that the `ProgressBar` will animate indefinitely, otherwise it will show the given progress.
        - foregroundColor: Foreground color
        - backgroundColor: Background color
     */
    init(
        progress: Float? = nil,
        foregroundColor: Color = .accentColor,
        backgroundColor: Color = .accentColor.opacity(0.2)
    ) {
        self.progress = progress
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(backgroundColor)
                if let progress = progress {
                    determinateProgressBar(proxy: proxy, progress: progress)
                } else {
                    indeterminateProgressBar(proxy: proxy)
                }
            }
            .clipped()
            .onAppear {
                if progress == nil {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                        self.offset = maxOffset
                    }
                }
            }
        }
        .frame(height: barHeight, alignment: .leading)
        .cornerRadius(barHeight / 2)
    }

    @ViewBuilder private func indeterminateProgressBar(proxy: GeometryProxy) -> some View {
        Rectangle()
            .foregroundColor(foregroundColor)
            .frame(width: proxy.size.width * barWidthPercentage, height: barHeight)
            .offset(x: proxy.size.width * barWidthPercentage * CGFloat(offset))
    }

    @ViewBuilder private func determinateProgressBar(proxy: GeometryProxy, progress: Float) -> some View {
        Rectangle()
            .foregroundColor(foregroundColor)
            .frame(width: proxy.size.width * CGFloat(progress), alignment: .leading)
            .animation(.easeInOut, value: 0.7)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar()
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressBar()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)

        ProgressBar(
            progress: 0.4,
            foregroundColor: .red,
            backgroundColor: .black
        )
        .preferredColorScheme(.light)
        .previewLayout(.sizeThatFits)

        ProgressBar(
            progress: 0.4,
            foregroundColor: .red,
            backgroundColor: .black
        )
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
