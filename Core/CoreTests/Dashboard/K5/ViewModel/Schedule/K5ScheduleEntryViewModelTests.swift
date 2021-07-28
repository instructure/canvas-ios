//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class K5ScheduleEntryViewModelTests: CoreTestCase {

    func testInvokesActionOnTap() {
        let actionInvokedExpectation = expectation(description: "Action invoked")
        let testee = K5ScheduleEntryViewModel(leading: .warning, icon: .addAudioLine, title: "", subtitle: .init(text: "", color: .black, font: .bold11), labels: [.init(text: "", color: .black)], score: nil, dueText: "", checkboxChanged: nil) {
            actionInvokedExpectation.fulfill()
        }

        testee.actionTriggered()

        wait(for: [actionInvokedExpectation], timeout: 0.1)
    }

    func testInvokesCheckboxCheckedCallback() {
        let checkboxChangedExpectation = expectation(description: "Checkbox changed callback")
        let testee = K5ScheduleEntryViewModel(leading: .checkbox(isChecked: false), icon: .addAudioLine, title: "", subtitle: nil, labels: [], score: nil, dueText: "", checkboxChanged: { isChecked in
            XCTAssertTrue(isChecked)
            checkboxChangedExpectation.fulfill()
        }) {}

        testee.checkboxTapped()

        wait(for: [checkboxChangedExpectation], timeout: 0.1)
    }

    func testLeadingSetterTriggersChangeEvent() {
        let refreshTriggeredExpectation = expectation(description: "Refresh expectation")
        let testee = K5ScheduleEntryViewModel(leading: .checkbox(isChecked: false), icon: .addAudioLine, title: "", subtitle: nil, labels: [], score: nil, dueText: "", checkboxChanged: nil) {}
        let subscription = testee.objectWillChange.sink {
            refreshTriggeredExpectation.fulfill()
        }

        testee.leading = .checkbox(isChecked: true)

        wait(for: [refreshTriggeredExpectation], timeout: 0.1)
        subscription.cancel()
    }
}
