//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import UIKit
@testable import Core

class UIViewExtensionsTests: XCTestCase {
    func testLoadFromXib() {
        XCTAssertNoThrow(TitleSubtitleView.loadFromXib())
    }

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

    func testAddConstraintsWithVFL() {
        let a = UIView()
        let b = UIView()
        a.addSubview(b)
        b.addConstraintsWithVFL("V:|-(pad)-[view]", metrics: ["pad": 15])
        XCTAssertEqual(a.constraints.count, 1)
        XCTAssertEqual(a.constraints.first?.constant, 15)
        XCTAssertNil(a.addConstraintsWithVFL("V:|-(pad)-[view]", metrics: ["pad": 15]))
    }

    func testRestrictFrame() {
        let superview = UIView()
        superview.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let testee = UIView()
        superview.addSubview(testee)

        // top left corner is outside of superview
        testee.frame = CGRect(x: -10, y: -10, width: 20, height: 20)
        testee.restrictFrameInsideSuperview()
        XCTAssertEqual(testee.frame, CGRect(x: 0, y: 0, width: 20, height: 20))

        // bottom right corner is outside of superview
        testee.frame = CGRect(x: 90, y: 90, width: 20, height: 20)
        testee.restrictFrameInsideSuperview()
        XCTAssertEqual(testee.frame, CGRect(x: 80, y: 80, width: 20, height: 20))
    }

    func test_findAllSubviews() {
        let label1 = UILabel()
        let nestedLabel = UILabel()
        let containerView = UIView()
        containerView.addSubview(label1)
        containerView.addSubview(nestedLabel)

        let label2 = UILabel()
        let button = UIButton()
        let parentView = UIView()
        parentView.addSubview(label2)
        parentView.addSubview(button)
        parentView.addSubview(containerView)

        // WHEN
        let foundLabels = parentView.findAllSubviews(ofType: UILabel.self)

        // THEN
        XCTAssertEqual(foundLabels, Set([label1, label2, nestedLabel]))
    }
}
