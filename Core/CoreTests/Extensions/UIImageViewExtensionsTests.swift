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
        api.mock(url: url!).suspend()
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
        view.load(url: url, result: .success(LoadedImage(image: image, repeatCount: 2)))
        XCTAssertNil(view.loader)
        XCTAssertNil(view.animationImages)
        view.url = url // requires url to match for load to complete
        view.load(url: url, result: .success(LoadedImage(image: image, repeatCount: 2)))
        XCTAssertEqual(view.animationImages?.count, 1)
        XCTAssertEqual(view.animationRepeatCount, 2)
        XCTAssertEqual(view.animationDuration, 3)
    }
}

class ImageLoaderTests: CoreTestCase {
    lazy var gifURL = Bundle(for: Self.self).url(forResource: "TestImage", withExtension: "gif")!
    lazy var pngURL = Bundle(for: Self.self).url(forResource: "TestImage", withExtension: "png")!
    lazy var svgURL = Bundle(for: Self.self).url(forResource: "TestImage", withExtension: "svg")!

    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)

    @objc var loadedImage: UIImage?
    var loadedRepeatCount: Int?
    var loadedError: Error?
    var loadedCount = 0
    func callback(result: Result<LoadedImage, Error>) {
        switch result {
        case .success(let loaded):
            loadedImage = loaded.image
            loadedRepeatCount = loaded.repeatCount
            loadedError = nil
        case .failure(let error):
            loadedImage = nil
            loadedRepeatCount = nil
            loadedError = error
        }
        loadedCount += 1
    }

    func testLoadPng() throws {
        api.mock(url: pngURL, data: try Data(contentsOf: pngURL))

        let loader = ImageLoader(url: pngURL, frame: frame, callback: callback)
        loader.load()
        XCTAssertNotNil(loadedImage)
        XCTAssertNil(loadedError)
    }

    func testLoadGif() throws {
        api.mock(url: gifURL, data: try Data(contentsOf: gifURL))

        let loader = ImageLoader(url: gifURL, frame: frame, callback: callback)
        loader.load()
        XCTAssertEqual(loadedImage?.duration, 0.24)
        XCTAssertEqual(loadedImage?.images?.count, 2)
        XCTAssertEqual(loadedRepeatCount, 0)
        XCTAssertNil(loadedError)
    }

    func testLoadGifWithoutExtension() throws {
        let plainURL = URL(string: "https://no.valid/extension")!
        let data = try Data(contentsOf: gifURL)
        api.mock(url: plainURL, data: data, response: HTTPURLResponse(
            url: plainURL,
            statusCode: 200,
            httpVersion: "1.1",
            headerFields: [ "Content-Type": "image/gif" ]
        ))

        let loader = ImageLoader(url: plainURL, frame: frame, callback: callback)
        loader.load()
        XCTAssertEqual(loadedImage?.duration, 0.24)
        XCTAssertEqual(loadedImage?.images?.count, 2)
        XCTAssertEqual(loadedRepeatCount, 0)

        api.mock(url: plainURL, data: data)
        ImageLoader.reset()
        loader.load()
        XCTAssertEqual(loadedImage?.duration, 0)
        XCTAssertEqual(loadedImage?.images, nil)
        XCTAssertEqual(loadedRepeatCount, 0)
    }

    func testLoadSvg() throws {
        api.mock(url: svgURL, data: try Data(contentsOf: svgURL))
        let loaded = expectation(for: NSPredicate(format: "%K != nil", #keyPath(loadedImage)), evaluatedWith: self)

        let loader = ImageLoader(url: svgURL, frame: frame, callback: callback)
        loader.load()
        XCTAssertNotNil(loader.webView)

        wait(for: [ loaded ], timeout: 9)
        XCTAssertNotNil(loadedImage)
        XCTAssertNil(loadedError)
    }

    func testDoubleLoad() throws {
        ImageLoader.reset()
        let task = api.mock(url: pngURL, data: try Data(contentsOf: pngURL))
        task.suspend()

        let loader = ImageLoader(url: pngURL, frame: frame, callback: callback)
        loader.load()
        let dupe = ImageLoader(url: pngURL, frame: frame, callback: callback)
        dupe.load()
        task.resume()

        XCTAssertNotNil(loadedImage)
        XCTAssertNil(loadedError)
        XCTAssertEqual(loadedCount, 2)
    }

    func testLoadInvalid() throws {
        api.mock(URLRequest(url: pngURL), error: NSError.internalError())

        let loader = ImageLoader(url: pngURL, frame: frame, callback: callback)
        loader.load()
        XCTAssertNil(loadedImage)
        XCTAssertNotNil(loadedError)
    }

    func testCancel() {
        ImageLoader.reset()
        let task = api.mock(URLRequest(url: pngURL))
        task.suspend()

        let loader = ImageLoader(url: pngURL, frame: frame, callback: callback)
        XCTAssertNotNil(loader.load())
        loader.cancel()
        XCTAssertNil(loader.task)
    }

    func testGreatestCommonFactor() {
        XCTAssertEqual(greatestCommonFactor(1, 7), 1)
        XCTAssertEqual(greatestCommonFactor(6, 9), 3)
        XCTAssertEqual(greatestCommonFactor(36, 24), 12)
    }
}
