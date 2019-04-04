//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import XCTest
import Core

class DispatchExtensionsTests: XCTestCase {
    func testPerformUIUpdateExecutesImmediately() {
        var result = false
        performUIUpdate {
            result = true
        }
        XCTAssertTrue(result)
    }

    func testPerformUIUpdateDispatchesToMainQueue() {
        let expectation = self.expectation(description: "on main thread")
        DispatchQueue.global().async {
            performUIUpdate {
                if Thread.isMainThread {
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 0.1)
    }
}
