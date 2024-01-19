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

import Foundation
import Combine
@testable import Core
import CoreData
import XCTest

class AudioPickerViewModelTests: CoreTestCase {
    var testee: AudioPickerViewModel!

    override func setUp() {
        super.setUp()
        testee = AudioPickerViewModel(router: environment.router)
    }

    func testInitialisationState() {
        XCTAssertEqual(testee.defaultDurationString, "00:00:00")
        XCTAssertFalse(testee.isReplay)
        XCTAssertFalse(testee.isRecording)
        XCTAssertFalse(testee.isPlaying)
    }

    func testReplay() {
        testee.startRecording()
        sleep(10)
        testee.stopRecording()

        XCTAssertTrue(testee.isReplay)

        testee.startPlaying()
        XCTAssertTrue(testee.isPlaying)

        testee.pausePlaying()
        XCTAssertFalse(testee.isPlaying)

    }

    func testRetake() {
        testee.startRecording()
        sleep(10)
        testee.stopRecording()

        testee.retakeButtonDidTap.accept(WeakViewController(UIViewController()))

        XCTAssertFalse(testee.isReplay)
    }

    func testNormalizePower() {
        XCTAssertEqual(testee.normalizeMeteringValue(rawValue: -100, maxHeight: 100), 3)
        XCTAssertEqual(testee.normalizeMeteringValue(rawValue: 0, maxHeight: 100), 100)
    }

}
