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

public extension View {

    /// Adds a swipe-to-remove gesture that reveals an action view when swiping left.
    ///
    /// The gesture requires swiping past a threshold to trigger the action.
    /// Visual and haptic feedback is provided when the threshold is crossed.
    /// Once the action is triggered, the view remains in the fully revealed position
    /// and it's the caller's responsibility to remove the cell from the view hierarcy.
    ///
    /// - Parameters:
    ///   - backgroundColor: The background color revealed behind the content during the swipe.
    ///   - isSwiping: Optional binding that tracks whether a swipe gesture is currently active. Use this to disable scrolling or other gestures while swiping.
    ///   - onSwipe: Closure called when the swipe action is completed.
    ///   - label: The view displayed in the revealed area during the swipe.
    func swipeToRemove<Label: View>(
        backgroundColor: Color,
        isSwiping: Binding<Bool>? = nil,
        onSwipe: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) -> some View {
        modifier(SwipeToRemoveModifier(
            backgroundColor: backgroundColor,
            isSwiping: isSwiping,
            onSwipe: onSwipe,
            label: label
        ))
    }
}

private struct SwipeToRemoveModifier<Label: View>: ViewModifier {
    let backgroundColor: Color
    let isSwiping: Binding<Bool>?
    let onSwipe: () -> Void
    let label: () -> Label

    // MARK: - Gesture Properties
    private let minimumDragDistance: CGFloat = 10
    /// The ratio of cell width that must be swiped to trigger the action (0.8 = 80% of cell width).
    private let actionThresholdRatio: CGFloat = 0.8

    // MARK: - Layout & Sizing
    @State private var cellContentOffset: CGFloat = 0
    @State private var cellWidth: CGFloat = 0
    @State private var actionViewWidth: CGFloat = 0
    /// The point based horizontal offset that must be reached by the drag gesture to trigger the action.
    @State private var actionThreshold: CGFloat = 0
    @State private var actionViewOffset: CGFloat = 0

    // MARK: - Internal Logic States
    /// Becomes true, if dragging goes beyond `actionThreshold`. If grad is ended while this is true the swipe action will be performed.
    @State private var isActionThresholdReached = false
    /// Becomes true after the action has been invoked to disable further drag gestures
    @State private var isActionInvoked = false

    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            swipeBackground
            content.offset(x: cellContentOffset).clipped()
        }
        .onWidthChange { width in
            cellWidth = width
            actionThreshold = cellWidth * actionThresholdRatio
        }
        .contentShape(Rectangle())
        // If this is a simple gesture and the cell is a button then swiping won't work
        .simultaneousGesture(
            DragGesture(minimumDistance: minimumDragDistance)
                .onChanged(handleDragChanged)
                .onEnded(handleDragEnded),
            isEnabled: !isActionInvoked
        )
    }

    private var swipeBackground: some View {
        backgroundColor
            .overlay(alignment: .trailing) {
                label()
                    .onWidthChange { width in
                        actionViewWidth = width
                        actionViewOffset = width
                    }
                    .offset(x: actionViewOffset)
            }
            .animation(.smooth, value: actionViewOffset)
            .accessibilityHidden(true)
    }

    // MARK: - Drag In Progress

    private func handleDragChanged(_ value: DragGesture.Value) {
        let horizontalTranslation = value.translation.width

        guard value.translation.isHorizontalSwipe else { return }

        guard value.translation.isSwipingLeft else {
            animateToClosedState()
            return
        }

        isSwiping?.wrappedValue = true

        hapticGenerator.prepare()
        cellContentOffset = max(horizontalTranslation, -cellWidth)

        handleActionThresholdCrossing()
        updateActionViewPosition()
    }

    private func handleActionThresholdCrossing() {
        let newIsActionThresholdReached = abs(cellContentOffset) >= actionThreshold

        if newIsActionThresholdReached && !isActionThresholdReached {
            hapticGenerator.impactOccurred()
            isActionThresholdReached = true
            actionViewOffset = cellContentOffset + actionViewWidth
        } else if !newIsActionThresholdReached && isActionThresholdReached {
            hapticGenerator.impactOccurred()
            isActionThresholdReached = false
            actionViewOffset = 0
        }
    }

    private func updateActionViewPosition() {
        let revealedWidth = abs(cellContentOffset)

        if isActionThresholdReached {
            actionViewOffset = cellContentOffset + actionViewWidth
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                if revealedWidth < actionViewWidth {
                    actionViewOffset = actionViewWidth + cellContentOffset
                } else {
                    actionViewOffset = 0
                }
            }
        }
    }

    // MARK: - Drag Finish

    private func handleDragEnded(_: DragGesture.Value) {
        isSwiping?.wrappedValue = false

        if isActionThresholdReached {
            animateToOpenedState()
            isActionInvoked = true
            onSwipe()
        } else {
            animateToClosedState()
        }
    }

    private func animateToOpenedState() {
        withAnimation(.smooth) {
            cellContentOffset = -cellWidth
            actionViewOffset = -cellWidth + actionViewWidth
        }
    }

    private func animateToClosedState() {
        isActionThresholdReached = false
        withAnimation(.smooth) {
            cellContentOffset = 0
            actionViewOffset = actionViewWidth
        }
    }
}
