//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class UIScrollViewExtensionsTests: XCTestCase {
    func testIsBottomReached() {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        scrollView.contentSize = CGSize(width: 100, height: 300)
        scrollView.contentOffset.y = 0
        XCTAssertFalse(scrollView.isBottomReached())

        scrollView.contentOffset.y = 50
        XCTAssertFalse(scrollView.isBottomReached())

        scrollView.contentOffset.y = 100
        XCTAssertFalse(scrollView.isBottomReached())

        scrollView.contentOffset.y = 140
        XCTAssertTrue(scrollView.isBottomReached())
        XCTAssertFalse(scrollView.isBottomReached(threshold: 0))

        scrollView.contentOffset.y = 200
        XCTAssertTrue(scrollView.isBottomReached())
        XCTAssertTrue(scrollView.isBottomReached(threshold: 0))
    }

    func testContentOffsetRatio() {
        let scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: 100, height: 100)
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        var ratio = scrollView.contentOffsetRatio
        XCTAssertEqual(ratio, CGPoint(x: 0, y: 0))

        scrollView.contentOffset = CGPoint(x: 50, y: 0)
        ratio = scrollView.contentOffsetRatio
        XCTAssertEqual(ratio, CGPoint(x: 0.5, y: 0))
    }

    func testScrollToView() {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        scrollView.contentSize = CGSize(width: 100, height: 300)
        scrollView.contentOffset.y = 0

        let tf = UITextField()
        scrollView.addSubview(tf)
        tf.frame = CGRect(x: 0, y: 270, width: 100, height: 21)

        let keyboardRect = CGRect(x: 0, y: 200, width: 100, height: 75)
        scrollView.scrollToView(view: tf, keyboardRect: keyboardRect)

        XCTAssertEqual(scrollView.contentOffset.y, 266)
    }
}
