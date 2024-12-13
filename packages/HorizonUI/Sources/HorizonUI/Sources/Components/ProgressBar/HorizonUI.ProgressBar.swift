//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public extension HorizonUI {
    struct ProgressBar: View {
        // MARK: - Dependancies

        private let progress: Double
        private let size: Size
        private let progressColor: Color
        private let numberPosition: NumberPosition
        private let textColor: Color

        // MARK: - Init

        public init(
            progress: Double,
            size: Size,
            progressColor: Color = .huiColors.surface.institution,
            numberPosition: NumberPosition = .inside,
            textColor: Color = .huiColors.surface.institution
        ) {
            self.progress = progress
            self.size = size
            self.progressColor = progressColor
            self.numberPosition = numberPosition
            self.textColor = textColor
        }

        public var body: some View {
            HStack(spacing: .huiSpaces.primitives.xSmall) {
                GeometryReader { geometry in
                    progressContentView(width: geometry.size.width * progress)
                }

                if numberPosition == .outside {
                    progressText
                }
            }
            .frame(height: size.height)
        }
    }
}

// MARK: - Components

extension HorizonUI.ProgressBar {
    private func progressContentView(width: CGFloat) -> some View {
        backgroundView
            .overlay(alignment: .leading) {
                ZStack(alignment: .leading) {
                    progressFillView(width: width)

                    if numberPosition == .inside {
                        progressText
                            .frame(minWidth: width, alignment: .trailing)
                    }
                }
                .clipShape(Capsule())
            }
    }

    @ViewBuilder
    private var progressText: some View {
        if numberPosition != .hidden {
            let percentageRound = round(progress * 10000) / 100.0
            Group {
                Text(percentageRound, format: .number) + Text("%")
            }
            .padding(.horizontal, .huiSpaces.primitives.xSmall)
            .foregroundStyle(textColor)
            .font(.huiFonts.figtreeSemibolt14)
        }
    }

    private var backgroundView: some View {
        Capsule()
            .fill(size.backgroundColor)
            .overlay {
                Capsule()
                    .stroke(size == .small ? .clear : progressColor, lineWidth: 2)
            }
    }

    private func progressFillView(width: CGFloat) -> some View {
        Capsule()
            .fill(progressColor)
            .frame(width: width)
    }
}
