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

class AudioPickerInteractorLiveTests: CoreTestCase {
    var testee: AudioPickerInteractorLive!

    override func setUp() {
        super.setUp()
        testee = AudioPickerInteractorLive()
    }

    func testStartRecording() {
        testee.startRecording()

        XCTAssertNotNil(testee.url)

        XCTAssertNotNil(testee.audioRecorder)
        XCTAssertTrue(testee.audioRecorder!.isMeteringEnabled)
    }

    func testStopRecording() {
        testee.startRecording()
        testee.stopRecording()

        XCTAssertNotNil(testee.url)
        XCTAssertNotNil(testee.audioPlayer)
    }

    func testPlayPauseAudio() {
        testee.startRecording()
        testee.stopRecording()

        testee.playAudio()
        XCTAssertNotNil(testee.audioPlayer)
        XCTAssertTrue(testee.audioPlayer!.isPlaying)

        testee.pauseAudio()
        XCTAssertFalse(testee.audioPlayer!.isPlaying)
    }

    func testCancel() {
        testee.startRecording()
        testee.stopRecording()

        testee.playAudio()

        testee.cancel()

        XCTAssertNotNil(testee.audioPlayer)
        XCTAssertFalse(testee.audioPlayer!.isPlaying)
    }

    func testSeekInAudio() {
        testee.startRecording()
        testee.stopRecording()

        XCTAssertNotNil(testee.audioPlayer)
        XCTAssertEqual(testee.audioPlayer!.currentTime, 0)

        testee.seekInAudio(newValue: 1)

        XCTAssertEqual(testee.audioPlayer!.currentTime, 0)
    }

}
