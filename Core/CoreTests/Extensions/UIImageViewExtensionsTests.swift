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

class UIImageViewExtensionsTests: XCTestCase {
    let svgUrl = Bundle(for: UIImageViewExtensionsTests.self).url(forResource: "TestImage", withExtension: "svg")!
    let pngUrl = Bundle(for: UIImageViewExtensionsTests.self).url(forResource: "TestImage", withExtension: "png")!
    let gifUrl = Bundle(for: UIImageViewExtensionsTests.self).url(forResource: "TestImage", withExtension: "gif")!

    class MockImageView: ImageLoadingView {
        var loader: ImageLoader?

        let frame: CGRect
        var callback: (URL, LoadedImage?, Error?) -> Void

        init(frame: CGRect = CGRect(x: 0, y: 0, width: 82, height: 82), callback: @escaping (URL, LoadedImage?, Error?) -> Void) {
            self.frame = frame
            self.callback = callback
        }

        @discardableResult
        func load(url: URL?) -> URLSessionTask? {
            guard let url = url else { return nil }
            loader = ImageLoader(url: url, view: self)
            return loader?.load()
        }

        func load(url: URL, didCompleteWith loaded: LoadedImage?, error: Error? = nil) {
            callback(url, loaded, error)
        }
    }

    override func setUp() {
        super.setUp()
        URLSessionAPI.defaultURLSession = URLSession.shared
    }

    func testLoadPng() {
        let expectation = XCTestExpectation(description: "load callback runs")
        let view = MockImageView { _, loaded, error in
            XCTAssertNotNil(loaded)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        view.load(url: pngUrl)
        wait(for: [expectation], timeout: 1.0)
    }

    func testCachedLoadPng() {
        let expectation = XCTestExpectation(description: "load callback runs")
        let view = MockImageView { _, loaded, error in
            XCTAssertNotNil(loaded)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        view.load(url: pngUrl)
        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadSvg() {
        let expectation = XCTestExpectation(description: "load callback runs")
        let view = MockImageView { _, loaded, error in
            XCTAssertNotNil(loaded)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        view.load(url: svgUrl)
        wait(for: [expectation], timeout: 3.0)
    }

    func testDoubleLoadSvg() {
        let expectation1 = XCTestExpectation(description: "load callback runs")
        let expectation2 = XCTestExpectation(description: "load2 callback runs")
        let view1 = MockImageView { _, loaded, error in
            XCTAssertNotNil(loaded)
            XCTAssertNil(error)
            expectation1.fulfill()
        }
        let view2 = MockImageView { _, loaded, error in
            XCTAssertNotNil(loaded)
            XCTAssertNil(error)
            expectation2.fulfill()
        }
        view1.load(url: svgUrl)
        view2.load(url: svgUrl)
        wait(for: [expectation1, expectation2], timeout: 5.0)
    }

    func testLoadGif() {
        let expectation = XCTestExpectation(description: "load callback runs")
        let view = MockImageView { _, loaded, error in
            XCTAssertNotNil(loaded)
            XCTAssertEqual(loaded?.image.images?.count, 2)
            XCTAssertEqual(loaded?.repeatCount, 0)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        view.load(url: gifUrl)
        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadInvalid() {
        let expectation = XCTestExpectation(description: "load callback runs")
        let view = MockImageView { _, loaded, error in
            XCTAssertNil(loaded)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        view.load(url: URL(string: "bad://url/path")!)
        wait(for: [expectation], timeout: 1.0)
    }

    func testCancel() {
        let view = MockImageView(frame: .zero) { _, _, _ in
            XCTFail("callback should not be called")
        }
        let task = view.load(url: svgUrl)
        view.loader?.cancel()
        XCTAssertNotEqual(task, view.loader?.task)
        XCTAssertNil(view.loader?.task)
    }

    func testGreatestCommonFactor() {
        XCTAssertEqual(greatestCommonFactor(1, 7), 1)
        XCTAssertEqual(greatestCommonFactor(6, 9), 3)
        XCTAssertEqual(greatestCommonFactor(36, 24), 12)
    }

    func testLoadUrl() {
        let view = UIImageView()
        view.load(url: pngUrl)
        view.load(url: pngUrl) // same url, no-op
        XCTAssertEqual(view.url, pngUrl)
    }

    func testLoadUrlDidCompleteWith() {
        let view = UIImageView()
        let image = UIImage.animatedImage(with: [
            UIImage(data: Data(base64Encoded: "R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")!)!,
        ], duration: 3)!
        view.load(url: pngUrl, didCompleteWith: LoadedImage(image: image, repeatCount: 2), error: nil)
        XCTAssertNil(view.loader)
        XCTAssertNil(view.animationImages)
        view.url = pngUrl // requires url to match for load to complete
        view.load(url: pngUrl, didCompleteWith: LoadedImage(image: image, repeatCount: 2), error: nil)
        XCTAssertEqual(view.animationImages?.count, 1)
        XCTAssertEqual(view.animationRepeatCount, 2)
        XCTAssertEqual(view.animationDuration, 3)
    }
}
