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

        /// - Parameters:
        ///    - progress : The percentage value, must be from 0 to 1.
        ///    - progressColor : The color for progress bar
        ///    - size: Select from two values [small or medium]
        ///    - numberPosition: The progress text position select from three values [inside, outside or hidden]
        ///    - textColor: The color for the progress bar text
        ///
        /// - Example:
        /// HorizonUI.ProgressBar(
        ///     progress: 0.5,
        ///     progressColor:  .huiColors.surface.institution,
        ///     size: .medium,
        ///     numberPosition: .outside,
        ///     textColor: .huiColors.primitives.white10
        ///  )
        public init(
            progress: Double,
            progressColor: Color = .huiColors.surface.institution,
            size: Size,
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
                .huiCornerRadius(level: .level28)
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
        Rectangle()
            .fill(size.backgroundColor)
            .huiCornerRadius(level: .level28)
            .huiBorder(
                level: .level2,
                color: size == .small ? .clear : progressColor,
                radius: size.height
            )
    }

    private func progressFillView(width: CGFloat) -> some View {
        Rectangle()
            .fill(progressColor)
            .huiCornerRadius(level: .level28)
            .frame(width: width)
    }
}
