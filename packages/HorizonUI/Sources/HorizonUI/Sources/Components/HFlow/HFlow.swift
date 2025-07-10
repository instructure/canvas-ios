//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
    struct HFlow: Layout {
        private let spacing: CGFloat
        private let lineSpacing: CGFloat

        public init(
            spacing: CGFloat = 8,
            lineSpacing: CGFloat = 8
        ) {
            self.spacing = spacing
            self.lineSpacing = lineSpacing
        }

        public func sizeThatFits(
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout ()
        ) -> CGSize {
            let maxWidth = (proposal.width ?? 0) - spacing
            var width: CGFloat = 0
            var height: CGFloat = 0
            var currentLineWidth: CGFloat = 0
            var currentLineHeight: CGFloat = 0

            for view in subviews {
                let size = view.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))

                if currentLineWidth + size.width > maxWidth {
                    width = max(width, currentLineWidth)
                    height += currentLineHeight + lineSpacing
                    currentLineWidth = 0
                    currentLineHeight = 0
                }

                currentLineWidth += size.width + spacing
                currentLineHeight = max(currentLineHeight, size.height)
            }

            width = max(width, currentLineWidth)
            height += currentLineHeight
            return CGSize(width: width, height: height)
        }

        public func placeSubviews(
            in bounds: CGRect,
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache: inout ()
        ) {
            var x: CGFloat = bounds.minX
            var y: CGFloat = bounds.minY
            var lineHeight: CGFloat = 0

            for view in subviews {
                let size = view.sizeThatFits(ProposedViewSize(width: bounds.width, height: nil))

                if x + size.width > bounds.maxX {
                    x = bounds.minX
                    y += lineHeight + lineSpacing
                    lineHeight = 0
                }

                view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: size.width, height: size.height))
                x += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }
    }
}
