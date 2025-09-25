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
    struct WrappingHStack: Layout {
        private let alignment: VerticalAlignment
        private let spacing: CGFloat
        private let lineSpacing: CGFloat

        public init(
            alignment: VerticalAlignment = .center,
            spacing: CGFloat = 8,
            lineSpacing: CGFloat = 8
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.lineSpacing = lineSpacing
        }

        public func sizeThatFits(
            proposal: ProposedViewSize,
            subviews: Subviews,
            cache _: inout ()
        ) -> CGSize {
            let maxWidth = proposal.width ?? .infinity

            guard !subviews.isEmpty else {
                return CGSize(width: 0, height: 0)
            }

            let (lines, totalHeight) = calculateLayout(subviews: subviews, maxWidth: maxWidth)

            if lines.count == 1 && lines.first?.hasSpacers == true {
                return CGSize(width: maxWidth, height: totalHeight)
            } else if lines.count == 1 {
                return CGSize(width: lines.first?.contentWidth ?? 0, height: totalHeight)
            } else {
                let maxLineWidth = lines.map { $0.contentWidth }.max() ?? 0
                return CGSize(width: maxLineWidth, height: totalHeight)
            }
        }

        public func placeSubviews(
            in bounds: CGRect,
            proposal _: ProposedViewSize,
            subviews: Subviews,
            cache _: inout ()
        ) {
            guard !subviews.isEmpty else { return }

            let (lines, _) = calculateLayout(subviews: subviews, maxWidth: bounds.width)
            var currentY = bounds.minY

            for (index, line) in lines.enumerated() {
                if line.hasSpacers, lines.count == 1 {
                    placeSingleLineWithSpacers(line: line, bounds: bounds, currentY: currentY)
                } else {
                    placeRegularLine(line: line, bounds: bounds, currentY: currentY)
                }

                currentY += line.height
                if index < lines.count - 1 {
                    currentY += lineSpacing
                }
            }
        }

        private func calculateLayout(subviews: Subviews, maxWidth: CGFloat) -> ([Line], CGFloat) {
            var lines: [Line] = []
            var currentLineItems: [(LayoutSubview, CGSize, Bool)] = []
            var currentLineWidth: CGFloat = 0
            var currentLineHeight: CGFloat = 0

            let subviewSizes = subviews.map { subview in
                subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            }

            let regularItems = subviews.enumerated().compactMap { index, subview in
                isSpacer(subview) ? nil : (subview, subviewSizes[index])
            }
            let singleLineWidth = regularItems.reduce(0) { $0 + $1.1.width } +
                CGFloat(max(0, regularItems.count - 1)) * spacing
            let hasSpacers = subviews.contains { isSpacer($0) }

            if singleLineWidth <= maxWidth {
                // Single line
                let items = subviews.enumerated().map { index, subview in
                    (subview, subviewSizes[index], isSpacer(subview))
                }
                let lineHeight = subviewSizes.map(\.height).max() ?? 0
                let line = Line(
                    items: items,
                    height: lineHeight,
                    contentWidth: hasSpacers ? maxWidth : singleLineWidth,
                    hasSpacers: hasSpacers
                )
                return ([line], lineHeight)
            } else {
                // Multi-line wrapping
                for (index, subview) in subviews.enumerated() {
                    if isSpacer(subview) { continue }

                    let size = subviewSizes[index]
                    let spacingToAdd = currentLineWidth > 0 ? spacing : 0
                    let neededWidth = currentLineWidth + spacingToAdd + size.width

                    if neededWidth > maxWidth, currentLineWidth > 0 {
                        let line = Line(
                            items: currentLineItems,
                            height: currentLineHeight,
                            contentWidth: currentLineWidth,
                            hasSpacers: false
                        )
                        lines.append(line)

                        currentLineItems = []
                        currentLineWidth = 0
                        currentLineHeight = 0
                    }

                    currentLineItems.append((subview, size, false))
                    currentLineWidth += spacingToAdd + size.width
                    currentLineHeight = max(currentLineHeight, size.height)
                }

                if !currentLineItems.isEmpty {
                    let line = Line(
                        items: currentLineItems,
                        height: currentLineHeight,
                        contentWidth: currentLineWidth,
                        hasSpacers: false
                    )
                    lines.append(line)
                }

                let totalHeight = lines.enumerated().reduce(0) { total, item in
                    let (index, line) = item
                    return total + line.height + (index > 0 ? lineSpacing : 0)
                }

                return (lines, totalHeight)
            }
        }

        private func placeSingleLineWithSpacers(line: Line, bounds: CGRect, currentY: CGFloat) {
            let regularItems = line.items.filter { !$0.2 }
            let spacerCount = line.items.filter { $0.2 }.count

            guard spacerCount > 0, !regularItems.isEmpty else {
                placeRegularLine(line: line, bounds: bounds, currentY: currentY)
                return
            }

            let totalRegularWidth = regularItems.reduce(0) { $0 + $1.1.width }
            let availableSpacerWidth = bounds.width - totalRegularWidth
            let spacerWidth = availableSpacerWidth / CGFloat(spacerCount)

            var currentX = bounds.minX

            for (subview, size, isSpacer) in line.items {
                if isSpacer {
                    currentX += spacerWidth
                } else {
                    let yPosition = calculateYPosition(currentY: currentY, lineHeight: line.height, itemHeight: size.height)
                    subview.place(
                        at: CGPoint(x: currentX, y: yPosition),
                        proposal: ProposedViewSize(width: size.width, height: size.height)
                    )
                    currentX += size.width
                }
            }
        }

        private func placeRegularLine(line: Line, bounds: CGRect, currentY: CGFloat) {
            var currentX = bounds.minX
            var isFirst = true

            for (subview, size, isSpacer) in line.items {
                if isSpacer { continue }

                if !isFirst {
                    currentX += spacing
                }

                let yPosition = calculateYPosition(currentY: currentY, lineHeight: line.height, itemHeight: size.height)
                subview.place(
                    at: CGPoint(x: currentX, y: yPosition),
                    proposal: ProposedViewSize(width: size.width, height: size.height)
                )

                currentX += size.width
                isFirst = false
            }
        }

        private func calculateYPosition(currentY: CGFloat, lineHeight: CGFloat, itemHeight: CGFloat) -> CGFloat {
            switch alignment {
            case .top:
                return currentY
            case .bottom:
                return currentY + lineHeight - itemHeight
            case .center:
                return currentY + (lineHeight - itemHeight) / 2
            default:
                return currentY + (lineHeight - itemHeight) / 2
            }
        }

        private func isSpacer(_ subview: LayoutSubview) -> Bool {
            let flexibleWidth = subview.sizeThatFits(ProposedViewSize(width: 1000, height: nil)).width
            let constrainedWidth = subview.sizeThatFits(ProposedViewSize(width: 100, height: nil)).width
            return flexibleWidth > constrainedWidth * 2
        }

        private struct Line {
            let items: [(LayoutSubview, CGSize, Bool)] // (subview, size, isSpacer)
            let height: CGFloat
            let contentWidth: CGFloat
            let hasSpacers: Bool
        }
    }
}
