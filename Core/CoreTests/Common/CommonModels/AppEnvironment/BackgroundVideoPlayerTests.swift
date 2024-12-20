//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import XCTest
import AVKit
@testable import Core
import TestsFoundation

class BackgroundVideoPlayerTests: XCTestCase {
    var player: BackgroundVideoPlayer!

    override func setUp() {
        super.setUp()
        player = BackgroundVideoPlayer.shared
    }

    override func tearDown() {
        player = nil
        super.tearDown()
    }

    func testBackgroundReconnect() {
        XCTAssertNil(player.viewController)
        XCTAssertNil(player.player)
        let controller = AVPlayerViewController()
        controller.player = AVPlayer()
        player.connect(controller)
        XCTAssertNotNil(player.viewController)
        player.background()
        XCTAssertNil(controller.player)
        XCTAssertNotNil(player.player)
        player.reconnect()
        XCTAssertNotNil(controller.player)
        XCTAssertNil(player.viewController)
        XCTAssertNil(player.player)
    }

    func testDisconnect() {
        XCTAssertNil(player.viewController)
        XCTAssertNil(player.player)
        if true { // create scope block the controller lives in
            let controller = AVPlayerViewController()
            // Assigning a player here will make the system keep alive the player view controller
            // even when we have no strong references to it. We want to test the weak reference
            // of `player.viewController` so we should have no player assigned otherwise the test will fail.
            //  controller.player = AVPlayer()
            player.connect(controller)
            XCTAssertNotNil(player.viewController)
        }

        XCTAssertNil(player.viewController)
    }
}
