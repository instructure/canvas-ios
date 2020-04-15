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

class UIImageViewExtensionsTests: CoreTestCase {
    func testLoad() {
        let url = URL(string: "/")
        api.mock(URLRequest(url: url!)).paused = true
        let view = UIImageView()
        XCTAssertNotNil(view.load(url: url))
        XCTAssertEqual(view.url, url)
        XCTAssertNotNil(view.loader?.task)
        XCTAssertNil(view.load(url: url))
    }

    func testLoadUrlDidCompleteWith() {
        let url = URL(string: "/")!
        let view = UIImageView()
        let image = UIImage.animatedImage(with: [
            UIImage(data: Data(base64Encoded: "R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")!)!,
        ], duration: 3)!
        view.load(url: url, didCompleteWith: LoadedImage(image: image, repeatCount: 2), error: nil)
        XCTAssertNil(view.loader)
        XCTAssertNil(view.animationImages)
        view.url = url // requires url to match for load to complete
        view.load(url: url, didCompleteWith: LoadedImage(image: image, repeatCount: 2), error: nil)
        XCTAssertEqual(view.animationImages?.count, 1)
        XCTAssertEqual(view.animationRepeatCount, 2)
        XCTAssertEqual(view.animationDuration, 3)
    }
}

class ImageLoaderTests: CoreTestCase, ImageLoadingView {
    lazy var gifURL = Bundle(for: Self.self).url(forResource: "TestImage", withExtension: "gif")!
    lazy var pngURL = Bundle(for: Self.self).url(forResource: "TestImage", withExtension: "png")!
    lazy var svgURL = Bundle(for: Self.self).url(forResource: "TestImage", withExtension: "svg")!

    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)

    @objc var loadedURL: URL?
    var loadedImage: LoadedImage?
    var loadedError: Error?
    var loadedCount = 0
    func load(url: URL, didCompleteWith image: LoadedImage?, error: Error?) {
        loadedURL = url
        loadedImage = image
        loadedError = error
        loadedCount += 1
    }

    func testLoadPng() throws {
        api.mock(URLRequest(url: pngURL), data: try Data(contentsOf: pngURL))

        let loader = ImageLoader(url: pngURL, view: self)
        loader.load()
        XCTAssertEqual(loadedURL, pngURL)
        XCTAssertNotNil(loadedImage?.image)
        XCTAssertNil(loadedError)
    }

    func testLoadGif() throws {
        api.mock(URLRequest(url: gifURL), data: try Data(contentsOf: gifURL))

        let loader = ImageLoader(url: gifURL, view: self)
        loader.load()
        XCTAssertEqual(loadedURL, gifURL)
        XCTAssertEqual(loadedImage?.image.duration, 0.24)
        XCTAssertEqual(loadedImage?.image.images?.count, 2)
        XCTAssertEqual(loadedImage?.repeatCount, 0)
        XCTAssertNil(loadedError)
    }

    func testLoadGifWithoutExtension() throws {
        let plainURL = URL(string: "https://no.valid/extension")!
        let data = try Data(contentsOf: gifURL)
        api.mock(URLRequest(url: plainURL), data: data, response: HTTPURLResponse(
            url: plainURL,
            statusCode: 200,
            httpVersion: "1.1",
            headerFields: [ "Content-Type": "image/gif" ]
        ))

        let loader = ImageLoader(url: plainURL, view: self)
        loader.load()
        XCTAssertEqual(loadedImage?.image.duration, 0.24)
        XCTAssertEqual(loadedImage?.image.images?.count, 2)
        XCTAssertEqual(loadedImage?.repeatCount, 0)

        api.mock(URLRequest(url: plainURL), data: data)
        ImageLoader.reset()
        loader.load()
        XCTAssertEqual(loadedImage?.image.duration, 0)
        XCTAssertEqual(loadedImage?.image.images, nil)
        XCTAssertEqual(loadedImage?.repeatCount, 0)
    }

    func testLoadSvg() throws {
        api.mock(URLRequest(url: svgURL), data: try Data(contentsOf: svgURL))
        let loaded = expectation(for: NSPredicate(format: "%K != nil", #keyPath(loadedURL)), evaluatedWith: self)

        let loader = ImageLoader(url: svgURL, view: self)
        loader.load()
        XCTAssertNotNil(loader.webView)

        wait(for: [ loaded ], timeout: 9)
        XCTAssertEqual(loadedURL, svgURL)
        XCTAssertNotNil(loadedImage?.image)
        XCTAssertNil(loadedError)
    }

    func testDoubleLoad() throws {
        ImageLoader.reset()
        let task = api.mock(URLRequest(url: pngURL), data: try Data(contentsOf: pngURL))
        task.paused = true

        let loader = ImageLoader(url: pngURL, view: self)
        loader.load()
        let dupe = ImageLoader(url: pngURL, view: self)
        dupe.load()
        task.paused = false

        XCTAssertEqual(loadedURL, pngURL)
        XCTAssertNotNil(loadedImage?.image)
        XCTAssertNil(loadedError)
        XCTAssertEqual(loadedCount, 2)
    }

    func testLoadInvalid() throws {
        api.mock(URLRequest(url: pngURL), error: NSError.internalError())

        let loader = ImageLoader(url: pngURL, view: self)
        loader.load()
        XCTAssertEqual(loadedURL, pngURL)
        XCTAssertNil(loadedImage)
        XCTAssertNotNil(loadedError)
    }

    func testCancel() {
        ImageLoader.reset()
        let task = api.mock(URLRequest(url: pngURL))
        task.paused = true

        let loader = ImageLoader(url: pngURL, view: self)
        XCTAssertNotNil(loader.load())
        loader.cancel()
        XCTAssertEqual(task.canceled, true)
    }

    func testGreatestCommonFactor() {
        XCTAssertEqual(greatestCommonFactor(1, 7), 1)
        XCTAssertEqual(greatestCommonFactor(6, 9), 3)
        XCTAssertEqual(greatestCommonFactor(36, 24), 12)
    }
}
