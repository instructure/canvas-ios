//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import UIKit
@testable import Core

class UIViewExtensionsTests: XCTestCase {
    func testRoundCorners() {
        let a = UIView(frame: .zero)
        XCTAssertNil(a.layer.mask)
        a.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        XCTAssertNotNil(a.layer.mask)
    }

    func testPin() {
        let a = UIView(frame: .zero)
        let b = UIView(frame: .zero)
        b.addSubview(a)
        a.pin(inside: b)
        XCTAssertFalse(a.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(b.constraints.count, 4)
    }

    func testPinNone() {
        let a = UIView(frame: .zero)
        let b = UIView(frame: .zero)
        b.addSubview(a)
        a.pin(inside: b, leading: nil, trailing: nil, top: nil, bottom: nil)
        XCTAssertFalse(a.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(b.constraints.count, 0)
    }

    func testPinValues() {
        let a = UIView(frame: .zero)
        let b = UIView(frame: .zero)
        b.addSubview(a)
        a.pin(inside: b, leading: 1, trailing: 2, top: 3, bottom: 4)
        XCTAssertFalse(a.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(b.constraints[0].constant, 1)
        XCTAssertEqual(b.constraints[1].constant, 2)
        XCTAssertEqual(b.constraints[2].constant, 3)
        XCTAssertEqual(b.constraints[3].constant, 4)
    }

    func testPinToLeftAndRightOfSuperview() {
        let a = UIView(frame: .zero)
        let b = UIView(frame: .zero)
        b.addSubview(a)
        a.pinToLeftAndRightOfSuperview()
        XCTAssertFalse(a.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(b.constraints.count, 2)
    }

    func testPinToTopAndBottomOfSuperview() {
        let a = UIView(frame: .zero)
        let b = UIView(frame: .zero)
        b.addSubview(a)
        a.pinToTopAndBottomOfSuperview()
        XCTAssertFalse(a.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(b.constraints.count, 2)
    }
}
