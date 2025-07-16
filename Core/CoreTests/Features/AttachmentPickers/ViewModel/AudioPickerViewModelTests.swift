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

    private let interactor = AudioPickerInteractorPreview()

    override func setUp() {
        super.setUp()
        testee = AudioPickerViewModel(env: environment, interactor: interactor)
    }

    func testInitialisationState() {
        XCTAssertEqual(testee.defaultDurationString, "00:00:00")
        XCTAssertFalse(testee.isReplay)
        XCTAssertFalse(testee.isRecording)
        XCTAssertFalse(testee.isPlaying)
    }

    func testNormalizePower() {
        XCTAssertEqual(testee.normalizeMeteringValue(rawValue: -100, maxHeight: 100), 3)
        XCTAssertEqual(testee.normalizeMeteringValue(rawValue: 0, maxHeight: 100), 100)
    }

    func testRecording() {
        testee.recordAudioButtonDidTap.accept(())

        XCTAssertTrue(testee.isRecording)
    }

    func testPlayback() {
        testee.recordAudioButtonDidTap.accept(())

        XCTAssertTrue(testee.isRecording)
        sleep(10)
        testee.stopRecordAudioButtonDidTap.accept(())

        XCTAssertFalse(testee.isRecording)
        XCTAssertTrue(testee.isReplay)
        XCTAssertFalse(testee.isPlaying)

        testee.playAudioButtonDidTap.accept(())
        XCTAssertTrue(testee.isPlaying)

        testee.pauseAudioButtonDidTap.accept(())
        XCTAssertFalse(testee.isPlaying)
    }

    func testRetakeAudio() {
        testee.recordAudioButtonDidTap.accept(())

        XCTAssertTrue(testee.isRecording)
        sleep(10)
        testee.stopRecordAudioButtonDidTap.accept(())

        XCTAssertFalse(testee.isRecording)
        XCTAssertTrue(testee.isReplay)
        XCTAssertFalse(testee.isPlaying)

        testee.retakeButtonDidTap.accept(())
        XCTAssertFalse(testee.isReplay)
    }

    func testSeekinAudio() {
        testee.seekInAudio(-10)
        XCTAssertTrue(interactor.seekInAudioCalled)
    }

    func testRecorderError() {
        interactor.throwRecorderError()

        wait(for: [router.showExpectation], timeout: 1)
        let dialog = router.presented as? UIAlertController
        XCTAssertNotNil(dialog)
    }

    func testPlayerError() {
        interactor.throwPlayerError()

        wait(for: [router.showExpectation], timeout: 1)
        let dialog = router.presented as? UIAlertController
        XCTAssertNotNil(dialog)
    }

}
