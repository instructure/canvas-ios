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

extension InstUI {

    public enum SwipeCompletionBehavior: Equatable {
        /// Swipe action remains fully revealed after swipe completion. Gesture is disabled after action is triggered.
        case stayOpen
        /// Swipe action immediately resets to closed position after swipe completion. Gesture remains enabled for repeated use.
        case reset
    }
}

extension View {

    /// Adds a swipe action gesture that reveals an action view when swiping left.
    ///
    /// The gesture requires swiping past a threshold to trigger the action.
    /// Visual and haptic feedback is provided when the threshold is crossed.
    ///
    /// - Parameters:
    ///   - backgroundColor: The background color revealed behind the content during the swipe.
    ///   - completionBehavior: Determines what happens after the swipe action completes. Defaults to `.stayOpen`.
    ///   - isSwiping: Binding that tracks whether a swipe gesture is currently active.
    ///                Use this to disable scrolling or other gestures while swiping.
    ///   - isEnabled: Whether the swipe gesture is enabled. Defaults to `true`.
    ///   - onSwipeCommitted: Optional closure called immediately when the swipe action is committed
    ///                       (user releases after reaching threshold) but before animations finish.
    ///   - onSwipe: Closure called when the swipe action is completed animations included.
    ///              For `.reset` behavior, this is called after the close animation finishes.
    ///              For `.stayOpen` behavior, this is called while the open animation is running.
    ///   - label: The view displayed in the revealed area during the swipe.
    public func swipeAction<Label: View>(
        backgroundColor: Color,
        completionBehavior: InstUI.SwipeCompletionBehavior = .stayOpen,
        isSwiping: Binding<Bool> = .constant(false),
        isEnabled: Bool = true,
        onSwipeCommitted: (() -> Void)? = nil,
        onSwipe: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) -> some View {
        modifier(SwipeActionModifier(
            backgroundColor: backgroundColor,
            completionBehavior: completionBehavior,
            isSwiping: isSwiping,
            isEnabled: isEnabled,
            onSwipeCommitted: onSwipeCommitted,
            onSwipe: onSwipe,
            label: label
        ))
    }
}

private struct SwipeActionModifier<Label: View>: ViewModifier {
    let backgroundColor: Color
    let completionBehavior: InstUI.SwipeCompletionBehavior
    @Binding var isSwiping: Bool
    let isEnabled: Bool
    let onSwipeCommitted: (() -> Void)?
    let onSwipe: () -> Void
    let label: () -> Label

    init(
        backgroundColor: Color,
        completionBehavior: InstUI.SwipeCompletionBehavior,
        isSwiping: Binding<Bool>,
        isEnabled: Bool,
        onSwipeCommitted: (() -> Void)?,
        onSwipe: @escaping () -> Void,
        label: @escaping () -> Label
    ) {
        self.backgroundColor = backgroundColor
        self.completionBehavior = completionBehavior
        self._isSwiping = isSwiping
        self.isEnabled = isEnabled
        self.onSwipeCommitted = onSwipeCommitted
        self.onSwipe = onSwipe
        self.label = label
    }

    // MARK: - Gesture Properties
    private let actionThresholdInPoints: CGFloat = {
        let thresholdInCentimeters: CGFloat = 2.5
        let centimetersPerInch: CGFloat = 2.54
        let inches = thresholdInCentimeters / centimetersPerInch
        let pointsPerInch = UIScreen.main.pointsPerInch
        return inches * pointsPerInch
    }()

    // MARK: - Layout & Sizing
    @State private var cellContentOffset: CGFloat = 0
    @State private var cellWidth: CGFloat = 0
    @State private var actionViewWidth: CGFloat = 0
    @State private var actionViewOffset: CGFloat = 0

    // MARK: - Internal Logic States
    /// Becomes true, if dragging goes beyond `actionThresholdInPoints`. If drag is ended while this is true the swipe action will be performed.
    @State private var isActionThresholdReached = false
    /// Becomes true after the action has been invoked to disable further drag gestures
    @State private var isActionInvoked = false
    /// Set on first gesture update to determine if we should process this gesture
    @State private var isStartedAsHorizontalGesture: Bool?

    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            swipeBackground
            content.offset(x: cellContentOffset).clipped()
        }
        .onWidthChange { width in
            cellWidth = width
        }
        .contentShape(Rectangle())
        // If this is a simple gesture and the cell is a button then swiping won't work
        .simultaneousGesture(
            // Values lower than 20 will prevent parent gesture recognizers from working. (Parent scrollview cannot be scrolled when tapped on an element having this swipe modifier.)
            DragGesture(minimumDistance: 20)
                .onChanged(handleDragChanged)
                .onEnded(handleDragEnded),
            isEnabled: isEnabled && !isActionInvoked
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
        if isStartedAsHorizontalGesture == nil {
            isStartedAsHorizontalGesture = value.translation.isHorizontalSwipe
        }

        guard isStartedAsHorizontalGesture == true,
              value.translation.isSwipingLeft
        else { return }

        isSwiping = true

        hapticGenerator.prepare()
        cellContentOffset = max(value.translation.width, -cellWidth)

        handleActionThresholdCrossing()
        updateActionViewPosition()
    }

    private func handleActionThresholdCrossing() {
        let newIsActionThresholdReached = abs(cellContentOffset) >= actionThresholdInPoints

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
        defer { isStartedAsHorizontalGesture = nil }
        guard isStartedAsHorizontalGesture == true else { return }

        isSwiping = false

        if isActionThresholdReached {
            onSwipeCommitted?()

            switch completionBehavior {
            case .stayOpen:
                animateToOpenedState()
                isActionInvoked = true
                onSwipe()
            case .reset:
                animateToClosedState()
                Task { @MainActor in
                    // Wait for close animation to complete before invoking callback.
                    // This prevents visual state changes during the animation
                    // Note: await suspends the Task but does NOT block the main thread
                    try? await Task.sleep(nanoseconds: 430_000_000)
                    onSwipe()
                }
            }
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

#if DEBUG

#Preview {
    ScrollView {
        VStack(spacing: 0) {
            ForEach(0..<5) { index in
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: "Todo Item \(index + 1)")
                        .font(.headline)
                    Text(verbatim: "Swipe left to mark as done")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.backgroundLightest)
                .swipeAction(
                    backgroundColor: .backgroundSuccess,
                    completionBehavior: .reset,
                    onSwipe: {},
                    label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.textLightest)
                            .paddingStyle(.horizontal, .standard)
                    }
                )
            }
        }
    }
}

#endif
