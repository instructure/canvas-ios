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
    private enum SwipeState {
        case idle
        case draggingBelowThreshold
        case draggingAboveThreshold
        case animatingOpen
        case open
        case animatingClose
        case ignoredGesture

        var allowsGesture: Bool {
            switch self {
            case .idle, .draggingBelowThreshold, .draggingAboveThreshold, .ignoredGesture:
                return true
            case .animatingOpen, .open, .animatingClose:
                return false
            }
        }
    }

    let backgroundColor: Color
    let completionBehavior: InstUI.SwipeCompletionBehavior
    @Binding var isSwiping: Bool
    let isEnabled: Bool
    let onSwipeCommitted: (() -> Void)?
    let onSwipe: () -> Void
    let label: () -> Label

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

    // MARK: - State Machine
    @State private var swipeState: SwipeState = .idle

    // MARK: - Animations
    private let animationDuration: TimeInterval = 0.3
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)

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
            isEnabled: isEnabled && swipeState.allowsGesture
        )
    }

    private var swipeBackground: some View {
        // Only show background when swipe has started to prevent it from being visible during cell fade-in animations
        (cellContentOffset != 0 ? backgroundColor : Color.clear)
            .overlay(alignment: .trailing) {
                label()
                    .onWidthChange { width in
                        actionViewWidth = width
                        actionViewOffset = width
                    }
                    .offset(x: actionViewOffset)
            }
            .animation(.easeOut(duration: animationDuration), value: actionViewOffset)
            .accessibilityHidden(true)
    }

    // MARK: - Drag In Progress

    private func handleDragChanged(_ value: DragGesture.Value) {
        switch swipeState {
        case .idle:
            if value.translation.isHorizontalSwipe && value.translation.isSwipingLeft {
                swipeState = .draggingBelowThreshold
                isSwiping = true
                hapticGenerator.prepare()
            } else {
                swipeState = .ignoredGesture
                return
            }

        case .draggingBelowThreshold:
            cellContentOffset = min(max(value.translation.width, -cellWidth), 0)

            if abs(cellContentOffset) >= actionThresholdInPoints {
                hapticGenerator.impactOccurred()
                swipeState = .draggingAboveThreshold
                actionViewOffset = cellContentOffset + actionViewWidth
            } else {
                updateActionViewPositionBelowThreshold()
            }

        case .draggingAboveThreshold:
            cellContentOffset = min(max(value.translation.width, -cellWidth), 0)
            actionViewOffset = cellContentOffset + actionViewWidth

            if abs(cellContentOffset) < actionThresholdInPoints {
                hapticGenerator.impactOccurred()
                swipeState = .draggingBelowThreshold
                actionViewOffset = 0
            }

        case .animatingOpen, .open, .animatingClose, .ignoredGesture:
            return
        }
    }

    private func updateActionViewPositionBelowThreshold() {
        let revealedWidth = abs(cellContentOffset)
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

    // MARK: - Drag Finish

    private func handleDragEnded(_: DragGesture.Value) {
        switch swipeState {
        case .draggingAboveThreshold:
            isSwiping = false
            onSwipeCommitted?()

            switch completionBehavior {
            case .stayOpen:
                swipeState = .animatingOpen
                withAnimation(.easeOut(duration: animationDuration)) {
                    cellContentOffset = -cellWidth
                    actionViewOffset = -cellWidth + actionViewWidth
                } completion: {
                    swipeState = .open
                    onSwipe()
                }

            case .reset:
                swipeState = .animatingClose
                withAnimation(.easeOut(duration: animationDuration)) {
                    cellContentOffset = 0
                    actionViewOffset = actionViewWidth
                } completion: {
                    swipeState = .idle
                    onSwipe()
                }
            }

        case .draggingBelowThreshold:
            isSwiping = false
            swipeState = .animatingClose
            withAnimation(.easeOut(duration: animationDuration)) {
                cellContentOffset = 0
                actionViewOffset = actionViewWidth
            } completion: {
                swipeState = .idle
            }

        case .ignoredGesture:
            swipeState = .idle

        default:
            break
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
