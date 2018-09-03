//
// Copyright (C) 2016-present Instructure, Inc.
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

class ImageLoaderTests: XCTestCase {
    let svgUrl = Bundle(for: ImageLoaderTests.self).url(forResource: "TestImage", withExtension: "svg")!
    let pngUrl = Bundle(for: ImageLoaderTests.self).url(forResource: "TestImage", withExtension: "png")!
    let gifUrl = Bundle(for: ImageLoaderTests.self).url(forResource: "TestImage", withExtension: "gif")!

    func testLoadPng() {
        let expectation = XCTestExpectation(description: "load callback runs")
        ImageLoader.load(url: pngUrl, frame: .zero) { image, error in
            XCTAssertNotNil(image)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testCachedLoadPng() {
        let expectation = XCTestExpectation(description: "load callback runs")
        ImageLoader.load(url: pngUrl, frame: .zero) { image, error in
            XCTAssertNotNil(image)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadSvg() {
        let expectation = XCTestExpectation(description: "load callback runs")
        ImageLoader.load(url: svgUrl, frame: CGRect(x: 0, y: 0, width: 82, height: 82)) { image, error in
            XCTAssertNotNil(image)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testDoubleLoadSvg() {
        let expectation1 = XCTestExpectation(description: "load callback runs")
        let expectation2 = XCTestExpectation(description: "load2 callback runs")
        ImageLoader.load(url: svgUrl, frame: CGRect(x: 0, y: 0, width: 82, height: 82)) { image, error in
            XCTAssertNotNil(image)
            XCTAssertNil(error)
            expectation1.fulfill()
        }
        ImageLoader.load(url: svgUrl, frame: CGRect(x: 0, y: 0, width: 82, height: 82)) { image, error in
            XCTAssertNotNil(image)
            XCTAssertNil(error)
            expectation2.fulfill()
        }
        wait(for: [expectation1, expectation2], timeout: 1.0)
    }

    func testLoadGif() {
        let expectation = XCTestExpectation(description: "load callback runs")
        ImageLoader.load(url: gifUrl, frame: .zero) { image, error in
            XCTAssertNotNil(image)
            XCTAssertEqual(image?.images?.count, 2)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadInvalid() {
        let expectation = XCTestExpectation(description: "load callback runs")
        ImageLoader.load(url: URL(string: "bad://url/path")!, frame: .zero) { image, error in
            XCTAssertNil(image)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testGreatestCommonFactor() {
        XCTAssertEqual(greatestCommonFactor(1, 7), 1)
        XCTAssertEqual(greatestCommonFactor(6, 9), 3)
        XCTAssertEqual(greatestCommonFactor(36, 24), 12)
    }
}
