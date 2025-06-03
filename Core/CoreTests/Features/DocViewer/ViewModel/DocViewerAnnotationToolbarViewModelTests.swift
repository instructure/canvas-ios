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

import XCTest
@testable import Core

class DocViewerAnnotationToolbarViewModelTests: XCTestCase {

    var testee: DocViewerAnnotationToolbarViewModel!
    var mockAnnotationProvider: MockDocViewerAnnotationProvider!

    override func setUp() {
        super.setUp()
        AppEnvironment.shared.userDefaults?.isSpeedGraderAnnotationToolbarVisible = nil
        mockAnnotationProvider = MockDocViewerAnnotationProvider(isAnnotatingDisabledInApp: false, isAPIEnabledAnnotations: true)
        testee = DocViewerAnnotationToolbarViewModel()
        testee.annotationProvider = mockAnnotationProvider
    }

    override func tearDown() {
        testee = nil
        mockAnnotationProvider = nil
        super.tearDown()
    }

    func testInitWithDefaultState() {
        XCTAssertEqual(testee.saveState, .saved)
        XCTAssertEqual(testee.isOpen, true)
    }

    func testInitWithCustomState() {
        let testee = DocViewerAnnotationToolbarViewModel(state: .error)
        XCTAssertEqual(testee.saveState, .error)
    }

    func testAccessibilityProperties() {
        XCTAssertEqual(testee.a11yValue, "Open")
        XCTAssertEqual(testee.a11yHint, "Double tap to close toolbar")

        testee.didTapCloseToggle.send()

        XCTAssertEqual(testee.a11yValue, "Closed")
        XCTAssertEqual(testee.a11yHint, "Double tap to open toolbar")
    }

    func testToggleClosedState() {
        XCTAssertEqual(testee.isOpen, true)

        testee.didTapCloseToggle.send()
        XCTAssertEqual(testee.isOpen, false)

        testee.didTapCloseToggle.send()
        XCTAssertEqual(testee.isOpen, true)
    }

    func testStateProperties() {
        XCTAssertEqual(DocViewerAnnotationToolbarViewModel.State.saving.text, "Saving...")
        XCTAssertEqual(DocViewerAnnotationToolbarViewModel.State.saved.text, "All annotations saved.")
        XCTAssertEqual(DocViewerAnnotationToolbarViewModel.State.error.text, "Error Saving. Tap to retry.")

        XCTAssertEqual(DocViewerAnnotationToolbarViewModel.State.saving.foregroundColor, .textDarkest)
        XCTAssertEqual(DocViewerAnnotationToolbarViewModel.State.saved.foregroundColor, .textSuccess)
        XCTAssertEqual(DocViewerAnnotationToolbarViewModel.State.error.foregroundColor, .textDanger)

        XCTAssertEqual(DocViewerAnnotationToolbarViewModel.State.saving.icon, .circleArrowUpLine)
        XCTAssertEqual(DocViewerAnnotationToolbarViewModel.State.saved.icon, .checkSolid)
        XCTAssertEqual(DocViewerAnnotationToolbarViewModel.State.error.icon, .xSolid)

        XCTAssertFalse(DocViewerAnnotationToolbarViewModel.State.saving.isTapToRetryActionEnabled)
        XCTAssertFalse(DocViewerAnnotationToolbarViewModel.State.saved.isTapToRetryActionEnabled)
        XCTAssertTrue(DocViewerAnnotationToolbarViewModel.State.error.isTapToRetryActionEnabled)
    }

    func testRetryAnnotationUpload() {
        XCTAssertFalse(mockAnnotationProvider.retryFailedRequestCalled)

        testee.didTapRetry.send()

        XCTAssertTrue(mockAnnotationProvider.retryFailedRequestCalled)
    }
}
