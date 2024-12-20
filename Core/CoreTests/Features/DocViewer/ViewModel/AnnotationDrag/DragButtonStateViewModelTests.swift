//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

@testable import Core
import PSPDFKitUI
import XCTest

class DragButtonStateViewModelTests: XCTestCase {
    var dragButton: ToolbarSelectableButton!
    var annotationStateManager: MockAnnotationStateManager!
    var testee: DragButtonStateViewModel!

    override func setUp() {
        super.setUp()
        dragButton = ToolbarSelectableButton()
        annotationStateManager = MockAnnotationStateManager()
        testee = DragButtonStateViewModel(dragButton: dragButton, annotationStateManager: annotationStateManager)
    }

    func testSubscribesToStateManagerChanges() {
        XCTAssertTrue(annotationStateManager.lastDelegate === testee)
    }

    func testDragButtonSelectionDisablesOtherAnnotationButtons() {
        let stateUpdateExpectation = expectation(description: "State update received")
        let subscription = testee.isButtonSelected.dropFirst().sink { isButtonSelected in
            stateUpdateExpectation.fulfill()
            XCTAssertTrue(isButtonSelected)
        }
        XCTAssertNotNil(annotationStateManager.lastState)
        XCTAssertNotNil(annotationStateManager.lastVariant)
        XCTAssertFalse(dragButton.isSelected)

        dragButton.actionBlock(dragButton)

        XCTAssertNil(annotationStateManager.lastState)
        XCTAssertNil(annotationStateManager.lastVariant)
        XCTAssertTrue(dragButton.isSelected)
        waitForExpectations(timeout: 0.1)

        subscription.cancel()
    }

    func testAnnotationButtonsDisableDragButton() {
        dragButton.setSelected(true, animated: false)
        annotationStateManager.lastState = nil
        annotationStateManager.lastVariant = nil
        let stateUpdateExpectation = expectation(description: "State update received")
        let subscription = testee.isButtonSelected.dropFirst().sink { isButtonSelected in
            stateUpdateExpectation.fulfill()
            XCTAssertFalse(isButtonSelected)
        }

        testee.anotherAnnotationButtonSelected()

        XCTAssertFalse(dragButton.isSelected)
        waitForExpectations(timeout: 0.1)

        subscription.cancel()
    }

    class MockAnnotationStateManager: AnnotationStateUpdater {
        var lastState: Annotation.Tool? = .init(rawValue: "state")
        var lastVariant: Annotation.Variant? = .init(rawValue: "variant")
        var lastDelegate: AnnotationStateManagerDelegate?

        func add(_ delegate: AnnotationStateManagerDelegate) {
            self.lastDelegate = delegate
        }

        func setState(_ state: Annotation.Tool?, variant: Annotation.Variant?) {
            self.lastState = state
            self.lastVariant = variant
        }
    }
}
