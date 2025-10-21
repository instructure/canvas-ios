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
    func swipeToRemove<ActionView: View>(
        backgroundColor: Color,
        onSwipe: @escaping () -> Void,
        @ViewBuilder actionView: @escaping () -> ActionView
    ) -> some View {
        modifier(SwipeToRemoveModifier(
            backgroundColor: backgroundColor,
            onSwipe: onSwipe,
            actionView: actionView
        ))
    }
}

private struct SwipeToRemoveModifier<ActionView: View>: ViewModifier {
    let backgroundColor: Color
    let onSwipe: () -> Void
    let actionView: () -> ActionView

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
            actionThreshold = cellWidth * 0.8
        }
        .contentShape(Rectangle())
        // If this is a simple gesture and the cell is a button then swiping won't work
        .simultaneousGesture(
            DragGesture()
                .onChanged(handleDragChanged)
                .onEnded(handleDragEnded)
        )
    }

    private var swipeBackground: some View {
        backgroundColor
            .overlay(alignment: .trailing) {
                actionView()
                    .onWidthChange { width in
                        actionViewWidth = width
                        actionViewOffset = width
                    }
                    .offset(x: actionViewOffset)
            }
            .animation(.smooth, value: actionViewOffset)
    }

    // MARK: - Drag In Progress

    private func handleDragChanged(_ value: DragGesture.Value) {
        if isActionInvoked { return }

        let translation = value.translation.width

        // We are only interested in swipes to the left
        guard translation < 0 else { return }

        hapticGenerator.prepare()
        cellContentOffset = max(translation, -cellWidth)

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
        if isActionInvoked { return }

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
