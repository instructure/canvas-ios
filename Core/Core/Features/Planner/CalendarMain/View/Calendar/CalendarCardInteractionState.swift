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

struct CalendarCardInteractionState {

    enum DragMode {
        case stable
        case draggingHorizontal
        case completionNext
        case completionPrev
        case draggingVertical
        case collapsing
        case expanding
    }

    var isCollapsed: Bool = true
    var expansionRatio: CGFloat?

    var dragMode: DragMode = .stable
    var dragTranslation: CGSize = .zero

    // MARK: Drag Change

    mutating func dragChanged(with value: DragGesture.Value, in card: CalendarCardView) {
        dragTranslation = value.translation

        if case .stable = dragMode {
            let velocity = value.velocity
            dragMode = abs(velocity.height) > abs(velocity.width) ? .draggingVertical : .draggingHorizontal
        }

        if case .draggingVertical = dragMode {
            let cardSizes = card.periodSizes
            let base = isCollapsed ? cardSizes.collapsed.height : cardSizes.current.height
            let maxHeight = base + dragTranslation.height
            let dh = (maxHeight - cardSizes.collapsed.height) / (cardSizes.current.height - cardSizes.collapsed.height)
            expansionRatio = min(max(dh, 0), 1)
        } else {
            expansionRatio = nil
        }
    }

    // MARK: Drag End

    func dragEnded(with value: DragGesture.Value, in card: CalendarCardView) {
        switch dragMode {
        case .draggingHorizontal:
            dragHorizontallyEnded(with: value, in: card)
        case .draggingVertical:
            dragVerticallyEnded(with: value, in: card)
        default: break
        }
    }

    private func dragHorizontallyEnded(with value: DragGesture.Value, in card: CalendarCardView) {
        let cardSizes = card.periodSizes
        var shouldSwitch = abs(dragTranslation.width) / cardSizes.current.width > 0.4
                        || abs(value.velocity.width) > 30

        if value.velocity.width.sign != dragTranslation.width.sign {
            shouldSwitch = false
        }

        let increment: DragMode = isTranslationForward(in: card) ? .completionNext : .completionPrev

        var otherDay: CalendarDay?
        if case .completionNext = increment {
            otherDay = nextDay(to: card.selectedDay)
        } else if case .completionPrev = increment {
            otherDay = prevDay(to: card.selectedDay)
        }

        card.finishInteraction(
            selecting: otherDay,
            endingWith: { state in
                state.dragMode = shouldSwitch ? increment : .stable
            },
            endCompletion: { state in
                guard shouldSwitch else { return false }

                state.dragMode = .stable
                state.dragTranslation = .zero
                state.expansionRatio = nil

                return true
            },
            animated: true
        )
    }

    private func dragVerticallyEnded(with value: DragGesture.Value, in card: CalendarCardView) {
        let cardSizes = card.periodSizes
        var shouldCollapse = abs(dragTranslation.height) / cardSizes.current.height > 0.4 || abs(value.velocity.height) > 30

        if value.velocity.height.sign != dragTranslation.height.sign {
            shouldCollapse = false
        }

        let increment: DragMode = dragTranslation.height < 0 ? .collapsing : .expanding

        card.finishInteraction(
            endingWith: { state in
                state.dragMode = shouldCollapse ? increment : .stable
                state.expansionRatio = shouldCollapse ? (increment == .collapsing ? 0 : 1) : nil
            },
            endCompletion: { state in
                guard shouldCollapse else { return false }

                state.isCollapsed = increment == .collapsing ? true : false
                state.dragMode = .stable
                state.dragTranslation = .zero
                state.expansionRatio = nil

                return true
            },
            animated: false
        )
    }

    // MARK: Card Calculation

    func offset(for card: CalendarCardView, given g: GeometryProxy) -> CGFloat {
        switch dragMode {
        case .completionNext:
            return -2 * g.size.width
        case .completionPrev:
            return 0
        case .draggingHorizontal:
            return card.layoutDirection == .rightToLeft
            ? -1 * dragTranslation.width - g.size.width
            : dragTranslation.width - g.size.width
        default:
            return -1 * g.size.width
        }
    }

    func maxHeight(for card: CalendarCardView) -> CGFloat {
        let cardSizes = card.periodSizes

        switch dragMode {
        case .collapsing:
            return cardSizes.collapsed.height
        case .expanding:
            return cardSizes.current.height
        case .draggingVertical:
            let base = isCollapsed ? cardSizes.collapsed.height : cardSizes.current.height
            return max(cardSizes.collapsed.height, min(base + dragTranslation.height, cardSizes.current.height))
        case .draggingHorizontal where isCollapsed == false:
            let targetHeight = (isTranslationForward(in: card) ? cardSizes.next : cardSizes.prev).height
            return max(targetHeight, cardSizes.current.height)
        case .completionNext where isCollapsed == false:
            return cardSizes.next.height
        case .completionPrev where isCollapsed == false:
            return cardSizes.prev.height
        default:
            return isCollapsed ? cardSizes.collapsed.height : cardSizes.current.height
        }
    }

    // MARK: Helpers

    private func isTranslationForward(in card: CalendarCardView) -> Bool {
        return dragTranslation.isForward(card.layoutDirection)
    }

    func nextDay(to day: CalendarDay) -> CalendarDay {
        return isCollapsed ? day.sameDayNextWeek() : day.sameDayNextMonth()
    }

    func prevDay(to day: CalendarDay) -> CalendarDay {
        return isCollapsed ? day.sameDayPrevWeek() : day.sameDayPrevMonth()
    }
}

// MARK: - Utils

private extension CalendarCardView {

    func finishInteraction(
        selecting newDay: CalendarDay? = nil,
        endingWith: (inout CalendarCardInteractionState) -> Void,
        endCompletion: @escaping (inout CalendarCardInteractionState) -> Bool,
        animated: Bool
    ) {
        withAnimation(duration: 0.4) {
            var newInteraction = interaction
            endingWith(&newInteraction)
            interaction = newInteraction
        } completion: {
            var newInteraction = interaction
            guard endCompletion(&newInteraction) else { return }

            func applyValues() {
                if let newDay {
                    selectedDay = newDay
                }
                interaction = newInteraction
            }

            if animated {
                withAnimation { applyValues() }
            } else {
                applyValues()
            }
        }
    }
}
