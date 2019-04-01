//
// Copyright (C) 2019-present Instructure, Inc.
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
}
