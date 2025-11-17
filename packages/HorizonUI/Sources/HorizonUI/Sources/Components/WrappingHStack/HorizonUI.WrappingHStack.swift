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

            let finalWidth: CGFloat
            if lines.count == 1 && lines.first?.hasSpacers == true {
                finalWidth = maxWidth.isFinite ? maxWidth : (lines.first?.contentWidth ?? 0)
            } else if lines.count == 1 {
                finalWidth = lines.first?.contentWidth ?? 0
            } else {
                finalWidth = lines.map { $0.contentWidth }.max() ?? 0
            }

            return CGSize(
                width: finalWidth.isFinite ? finalWidth : 0,
                height: totalHeight.isFinite ? totalHeight : 0
            )
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

            let effectiveMaxWidth = maxWidth.isFinite ? maxWidth : 10000
            let subviewSizes = subviews.map { subview in
                let size = subview.sizeThatFits(ProposedViewSize(width: effectiveMaxWidth, height: nil))
                return CGSize(
                    width: size.width.isFinite ? size.width : 0,
                    height: size.height.isFinite ? size.height : 0
                )
            }

            let regularItems = subviews.enumerated().compactMap { index, subview in
                isSpacer(subview) ? nil : (subview, subviewSizes[index])
            }
            // Calculate width based on actual items that will be placed (non-spacers)
            let singleLineWidth = regularItems.reduce(0) { $0 + $1.1.width } +
                CGFloat(max(0, regularItems.count - 1)) * spacing
            let hasSpacers = subviews.contains { isSpacer($0) }

            if singleLineWidth <= effectiveMaxWidth {
                // Single line
                let items = subviews.enumerated().map { index, subview in
                    (subview, subviewSizes[index], isSpacer(subview))
                }
                let lineHeight = subviewSizes.map(\.height).max() ?? 0
                let line = Line(
                    items: items,
                    height: lineHeight,
                    contentWidth: hasSpacers ? effectiveMaxWidth : singleLineWidth,
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

                    if neededWidth > effectiveMaxWidth, currentLineWidth > 0 {
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

            guard spacerCount > 0, !regularItems.isEmpty, bounds.width.isFinite, bounds.width > 0 else {
                placeRegularLine(line: line, bounds: bounds, currentY: currentY)
                return
            }

            let totalRegularWidth = regularItems.reduce(0) { $0 + $1.1.width }
            // Account for specified spacing between regular items
            let regularSpacingCount = max(0, regularItems.count - 1)
            let totalSpacingWidth = CGFloat(regularSpacingCount) * spacing
            let availableSpacerWidth = bounds.width - totalRegularWidth - totalSpacingWidth

            guard availableSpacerWidth.isFinite else {
                placeRegularLine(line: line, bounds: bounds, currentY: currentY)
                return
            }
            let spacerWidth = max(0, availableSpacerWidth / CGFloat(spacerCount))

            var currentX = bounds.minX
            var placedAnyRegularItem = false

            for (subview, size, isSpacer) in line.items {
                if isSpacer {
                    currentX += spacerWidth
                } else {
                    // Add spacing before regular items (except the first one)
                    if placedAnyRegularItem {
                        currentX += spacing
                    }

                    guard currentX.isFinite, size.width.isFinite, size.height.isFinite else { continue }
                    let yPosition = calculateYPosition(currentY: currentY, lineHeight: line.height, itemHeight: size.height)
                    guard yPosition.isFinite else { continue }
                    subview.place(
                        at: CGPoint(x: currentX, y: yPosition),
                        proposal: ProposedViewSize(width: size.width, height: size.height)
                    )
                    currentX += size.width
                    placedAnyRegularItem = true
                }
            }
        }

        private func placeRegularLine(line: Line, bounds: CGRect, currentY: CGFloat) {
            guard bounds.width.isFinite, bounds.width > 0 else { return }

            var currentX = bounds.minX
            var placedAnyItem = false

            for (subview, size, isSpacer) in line.items {
                if isSpacer { continue }

                // Add spacing before items (except the first placed item)
                if placedAnyItem {
                    currentX += spacing
                }

                guard currentX.isFinite, size.width.isFinite, size.height.isFinite else { continue }
                let yPosition = calculateYPosition(currentY: currentY, lineHeight: line.height, itemHeight: size.height)
                guard yPosition.isFinite else { continue }
                subview.place(
                    at: CGPoint(x: currentX, y: yPosition),
                    proposal: ProposedViewSize(width: size.width, height: size.height)
                )

                currentX += size.width
                placedAnyItem = true
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
            // More strict spacer detection - require significant difference and minimum flexible width
            return flexibleWidth > constrainedWidth * 3 && flexibleWidth > 50
        }

        private struct Line {
            let items: [(LayoutSubview, CGSize, Bool)] // (subview, size, isSpacer)
            let height: CGFloat
            let contentWidth: CGFloat
            let hasSpacers: Bool
        }
    }
}
