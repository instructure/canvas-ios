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
        let url = URL(string: "/")!
        api.mock(url: url).suspend()
        let view = UIImageView()

        // first load should work
        XCTAssertNotNil(view.load(url: url))
        XCTAssertEqual(view.url, url)
        XCTAssertNotNil(view.loader?.task)

        // second load should be ignored
        XCTAssertNil(view.load(url: url))
    }

    func testLoadUrlWithResult() {
        let url = URL(string: "/")!
        let view = UIImageView()
        let image = UIImage.animatedImage(with: [
            UIImage(data: Data(base64Encoded: "R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")!)!
        ], duration: 3)!
        let imageLoader = ImageLoader(url: url, frame: .zero) { _ in }

        // load with matching URL
        view.url = url
        view.image = nil
        view.loader = imageLoader
        view.load(url: url, result: .success(image))
        XCTAssertEqual(view.image, image)
        XCTAssertEqual(view.animationImages, nil) // animated images are not supported
        XCTAssertNil(view.loader)

        // load without matching URL
        view.url = URL(string: "/another")!
        view.image = nil
        view.loader = imageLoader
        view.load(url: url, result: .success(image))
        XCTAssertEqual(view.image, nil)
        XCTAssertEqual(view.loader === imageLoader, true)

        // load with failure
        view.url = url
        view.image = nil
        view.loader = imageLoader
        view.load(url: url, result: .failure(NSError.instructureError("")))
        XCTAssertEqual(view.image, nil)
        XCTAssertNil(view.loader)
    }
}

class ImageLoaderTests: CoreTestCase {
    private lazy var gifURL = Bundle(for: Self.self).url(forResource: "TestImage", withExtension: "gif")!
    private lazy var pngURL = Bundle(for: Self.self).url(forResource: "TestImage", withExtension: "png")!
    private lazy var svgURL = Bundle(for: Self.self).url(forResource: "TestImage", withExtension: "svg")!

    private let frame = CGRect(x: 0, y: 0, width: 100, height: 100)

    private var result: Result<UIImage, Error>?
    private var loadedCount = 0

    @objc private var loadedImage: UIImage? { result?.value }

    private lazy var callback: (Result<UIImage, Error>) -> Void = { [weak self] result in
        self?.result = result
        self?.loadedCount += 1
    }

    func testLoadPng() throws {
        api.mock(url: pngURL, data: try Data(contentsOf: pngURL))

        let loader = ImageLoader(url: pngURL, frame: frame, callback: callback)
        loader.load()
        XCTAssertEqual(result?.isSuccess, true)
    }

    func testLoadAnimatedGifWhenFailIsEnabled() throws {
        api.mock(url: gifURL, data: try Data(contentsOf: gifURL))

        let loader = ImageLoader(url: gifURL, frame: frame, shouldFailForAnimatedGif: true, callback: callback)
        loader.load()

        XCTAssertEqual(result?.error as? ImageLoaderError, .animatedGifFound)
    }

    func testLoadAnimatedGifWhenFailIsDisabled() throws {
        api.mock(url: gifURL, data: try Data(contentsOf: gifURL))

        let loader = ImageLoader(url: gifURL, frame: frame, callback: callback)
        loader.load()

        // should return a non-animated image
        XCTAssertEqual(result?.value != nil, true)
        XCTAssertEqual(result?.value?.duration, 0)
        XCTAssertEqual(result?.value?.images, nil)
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

        let loader = ImageLoader(url: plainURL, frame: frame, shouldFailForAnimatedGif: true, callback: callback)
        loader.load()
        XCTAssertEqual(result?.error as? ImageLoaderError, .animatedGifFound)

        api.mock(url: plainURL, data: data)
        ImageLoader.reset()
        loader.load()
        XCTAssertEqual(result?.value != nil, true)
        XCTAssertEqual(result?.value?.duration, 0)
        XCTAssertEqual(result?.value?.images, nil)
    }

    func testLoadSvg() throws {
        api.mock(url: svgURL, data: try Data(contentsOf: svgURL))
        let loaded = expectation(for: NSPredicate(format: "%K != nil", #keyPath(loadedImage)), evaluatedWith: self)

        let loader = ImageLoader(url: svgURL, frame: frame, callback: callback)
        loader.load()
        XCTAssertNotNil(loader.webView)

        wait(for: [ loaded ], timeout: 9)
        XCTAssertEqual(result?.isSuccess, true)
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

        XCTAssertEqual(result?.isSuccess, true)
        XCTAssertEqual(loadedCount, 2)
    }

    func testLoadInvalid() throws {
        api.mock(URLRequest(url: pngURL), error: NSError.internalError())

        let loader = ImageLoader(url: pngURL, frame: frame, callback: callback)
        loader.load()
        XCTAssertEqual(result?.isFailure, true)
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
}
