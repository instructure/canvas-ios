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
@testable import Core
import SwiftUI
import Combine

class AvoidKeyboardAreaTests: CoreTestCase {
    var received: [CGFloat] = []
    lazy var keyboardCancel = AvoidKeyboardArea<Text>.keyboardHeight.sink(receiveValue: { [weak self] in
        self?.received.append($0)
    })

    override func setUp() {
        super.setUp()
        _ = keyboardCancel
    }

    func testPublisher() {
        NotificationCenter.default.post(name: UIApplication.keyboardWillShowNotification, object: nil, userInfo: [
            UIResponder.keyboardFrameEndUserInfoKey: CGRect(x: 0, y: 0, width: 0, height: 100)
        ])
        XCTAssertEqual(received, [100])
        NotificationCenter.default.post(name: UIApplication.keyboardWillHideNotification, object: nil, userInfo: [:])
        XCTAssertEqual(received, [100, 0])
        NotificationCenter.default.post(name: UIApplication.keyboardWillChangeFrameNotification, object: nil, userInfo: [
            UIResponder.keyboardFrameEndUserInfoKey: CGRect(x: 0, y: 0, width: 0, height: 150)
        ])
        XCTAssertEqual(received, [100, 0, 150])
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil, userInfo: [:])
        XCTAssertEqual(received, [100, 0, 150, 0])
        NotificationCenter.default.post(name: UIApplication.keyboardWillShowNotification, object: nil, userInfo: [:])
        XCTAssertEqual(received, [100, 0, 150, 0, 0])
        NotificationCenter.default.post(name: UIApplication.keyboardWillChangeFrameNotification, object: nil, userInfo: [:])
        XCTAssertEqual(received, [100, 0, 150, 0, 0, 0])
    }

    func testBody() {
        // Mostly just for coverage, until we figure out a good UI testing strategy
        XCTAssertNoThrow(hostSwiftUI(SwiftUI.Text(verbatim: "SwiftUI!").avoidKeyboardArea()))
        NotificationCenter.default.post(name: UIApplication.keyboardWillShowNotification, object: nil, userInfo: [
            UIResponder.keyboardFrameEndUserInfoKey: CGRect(x: 0, y: 0, width: 0, height: 100)
        ])
    }
}
