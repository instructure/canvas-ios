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

import XCTest
@testable import Core
import TestsFoundation

class CircleProgressViewTests: CoreTestCase {
    let pi = CGFloat(Double.pi)

    func testUpdates() {
        let view = CircleProgressView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        XCTAssertEqual(view.track.path, UIBezierPath(
            arcCenter: CGPoint(x: 100, y: 50),
            radius: 97.0 / 2,
            startAngle: pi * -0.5,
            endAngle: pi * 1.5,
            clockwise: true
        ).cgPath)
        view.bounds = CGRect(x: 0, y: 0, width: 64, height: 64)
        view.layoutSubviews()
        XCTAssertEqual(view.track.path, UIBezierPath(
            arcCenter: CGPoint(x: 32, y: 32),
            radius: 61.0 / 2,
            startAngle: pi * -0.5,
            endAngle: pi * 1.5,
            clockwise: true
        ).cgPath)

        view.color = .red
        XCTAssertEqual(view.fill.strokeColor, UIColor.red.cgColor)
        view.color = nil
        view.tintColor = UIColor.orange
        XCTAssertEqual(view.fill.strokeColor, UIColor.orange.cgColor)

        XCTAssertNotNil(view.layer.animation(forKey: view.rotateKey))
        XCTAssertNotNil(view.fill.animation(forKey: view.morphKey))
        view.progress = 0.0
        XCTAssertNil(view.layer.animation(forKey: view.rotateKey))
        XCTAssertNil(view.fill.animation(forKey: view.morphKey))
        XCTAssertEqual(view.fill.strokeEnd, 0)
        view.progress = 0.5
        XCTAssertEqual(view.fill.strokeEnd, 0.5)
        view.progress = 1
        XCTAssertEqual(view.fill.strokeEnd, 1)

        view.thickness = 6
        XCTAssertEqual(view.fill.lineWidth, 6)
        XCTAssertEqual(view.track.lineWidth, 6)
        XCTAssertEqual(view.track.path, UIBezierPath(
            arcCenter: CGPoint(x: 32, y: 32),
            radius: 58.0 / 2,
            startAngle: pi * -0.5,
            endAngle: pi * 1.5,
            clockwise: true
        ).cgPath)

        view.progress = nil
        view.layer.removeAllAnimations()
        view.fill.removeAllAnimations()
        view.didMoveToWindow()
        XCTAssertNil(view.layer.animation(forKey: view.rotateKey))
        XCTAssertNil(view.fill.animation(forKey: view.morphKey))
    }
}
