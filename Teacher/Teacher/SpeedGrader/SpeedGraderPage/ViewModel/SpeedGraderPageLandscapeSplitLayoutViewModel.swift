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

import Foundation
import SwiftUI
import Combine

class SpeedGraderPageLandscapeSplitLayoutViewModel: ObservableObject {

    // MARK: - Output

    @Published private(set) var dragIconA11yValue: String = ""
    @Published private(set) var dragIconA11yHint: String = ""
    @Published private(set) var dragIconRotation: Angle = .degrees(0)
    @Published private(set) var isRightColumnHidden = false
    @Published private(set) var rightColumnWidth: CGFloat?
    @Published private(set) var leftColumnWidth: CGFloat?

    // MARK: - Private Properties

    private let moveAnimation = Animation.smooth(duration: 0.3)
    private var screenWidth: CGFloat = 0
    private var leftSideMinWidth: CGFloat = 0
    private var leftSideMaxWidth: CGFloat = 0
    private var leftColumnWidthBeforeFullScreen: CGFloat?

    private var dragStartLeftColumnWidth: CGFloat = 0
    private var isDraggingInProgress: Bool = false
    private var isFullScreen: Bool { leftColumnWidth == screenWidth }
    private var subscriptions = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                self?.handleDeviceOrientationChange()
            }
            .store(in: &subscriptions)
    }

    func updateScreenWidth(_ screenWidth: CGFloat) {
        guard self.screenWidth != screenWidth else { return }

        self.screenWidth = screenWidth
        leftSideMinWidth = screenWidth / 3
        leftSideMaxWidth = (2 * screenWidth) / 3
        leftColumnWidth = screenWidth - leftSideMinWidth
        rightColumnWidth = leftSideMinWidth
        leftColumnWidthBeforeFullScreen = nil
        didUpdateLeftColumnWidth()
    }

    // MARK: - User Actions

    func didTapDragIcon() {
        if isFullScreen {
            withAnimation(moveAnimation) {
                let leftColumnWidth = leftColumnWidthBeforeFullScreen ?? leftSideMaxWidth
                self.leftColumnWidth = leftColumnWidth
                rightColumnWidth = screenWidth - leftColumnWidth
                didUpdateLeftColumnWidth()
            }
            leftColumnWidthBeforeFullScreen = nil
        } else {
            leftColumnWidthBeforeFullScreen = leftColumnWidth
            withAnimation(moveAnimation) {
                leftColumnWidth = screenWidth
                rightColumnWidth = leftSideMinWidth
                didUpdateLeftColumnWidth()
            }
        }
    }

    func didEndDragGesture() {
        isDraggingInProgress = false
        leftColumnWidthBeforeFullScreen = nil

        guard let leftColumnWidth else {
            return
        }

        let snapThreshold = screenWidth - (leftSideMinWidth / 2)

        if leftColumnWidth > leftSideMaxWidth {
            withAnimation(moveAnimation) {
                if leftColumnWidth > snapThreshold {
                    self.leftColumnWidth = screenWidth
                } else {
                    self.leftColumnWidth = leftSideMaxWidth
                    self.rightColumnWidth = leftSideMinWidth
                }
                didUpdateLeftColumnWidth()
            }
        } else if leftColumnWidth < leftSideMinWidth {
            withAnimation(moveAnimation) {
                self.leftColumnWidth = leftSideMinWidth
                self.rightColumnWidth = screenWidth - leftSideMinWidth
                didUpdateLeftColumnWidth()
            }
        }
    }

    func didUpdateDragGesturePosition(horizontalTranslation: CGFloat) {
        if isDraggingInProgress == false {
            isDraggingInProgress = true
            dragStartLeftColumnWidth = leftColumnWidth ?? 0
        }

        let dragPosition = dragStartLeftColumnWidth + horizontalTranslation

        if dragPosition < leftSideMinWidth {
            let overDragTranslation = leftSideMinWidth - dragPosition
            let reducedTranslation = overDragTranslation / 8
            let leftColumnWidth = leftSideMinWidth - reducedTranslation
            self.leftColumnWidth = leftColumnWidth
            rightColumnWidth = screenWidth - leftColumnWidth
        } else if dragPosition > leftSideMaxWidth {
            rightColumnWidth = leftSideMinWidth
            leftColumnWidth = min(dragPosition, screenWidth)
        } else {
            leftColumnWidth = dragPosition
            rightColumnWidth = screenWidth - dragPosition
        }
        didUpdateLeftColumnWidth()
    }

    // MARK: - Private

    private func didUpdateLeftColumnWidth() {
        dragIconRotation = .degrees(isFullScreen ? -180 : 0)
        dragIconA11yValue = isFullScreen ? String(localized: "Closed", bundle: .teacher)
                                         : String(localized: "Open", bundle: .teacher)
        dragIconA11yHint = isFullScreen ? String(localized: "Double tap to open drawer", bundle: .teacher)
                                        : String(localized: "Double tap to close drawer", bundle: .teacher)
        isRightColumnHidden = isFullScreen
    }

    /// When the dvice orientation changes while a gesture is in progress its `onEnded` callback is not called
    /// so we have to manually stop the drag gesture.
    private func handleDeviceOrientationChange() {
        if isDraggingInProgress {
            didEndDragGesture()
        }
    }
}
