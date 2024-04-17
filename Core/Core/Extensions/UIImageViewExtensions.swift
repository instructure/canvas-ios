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

import UIKit
import WebKit
import Combine

public struct LoadedImage {
    public enum Error: Swift.Error {
        case animatedGifFound
    }

    let image: UIImage
    let repeatCount: Int
}

private var urlHandle: UInt8 = 0
private var loaderHandle: UInt8 = 0

extension UIImageView {
    public var url: URL? {
        get {
            return objc_getAssociatedObject(self, &urlHandle) as? URL
        }
        set {
            objc_setAssociatedObject(self, &urlHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var loader: ImageLoader? {
        get {
            return objc_getAssociatedObject(self, &loaderHandle) as? ImageLoader
        }
        set {
            objc_setAssociatedObject(self, &loaderHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Load an image from `url` to display in this `UIImageView`.
    ///
    /// If `url` points to an SVG image, it will be snapshotted by `WKWebView` first.
    /// If `url` points to an animated GIF, it will be converted to animatedImages.
    /// If `nil` is passed, any previous loading will be cancelled.
    /// - Parameter url: The `URL` pointing to an image file.
    /// - Returns: If this needs to reach out to the network, the associated `URLSessionTask` is returned.
    @discardableResult
    public func load(url: URL?) -> APITask? {
        guard self.url != url else { return nil }
        self.url = url
        loader = nil
        image = nil
        if let url = url {
            loader = ImageLoader(url: url, frame: self.frame) { [weak self] result in
                self?.load(url: url, result: result)
            }
        }
        return loader?.load()
    }

    private func load(url: URL, result: Result<LoadedImage, Error>) {
        guard self.url == url else { return }
        if case .success(let cached) = result {
            image = cached.image
            if let images = cached.image.images {
                image = images.last
                if !UIAccessibility.isReduceMotionEnabled {
                    animationDuration = cached.image.duration
                    animationImages = images
                    animationRepeatCount = cached.repeatCount
                    startAnimating()
                }
            }
        }
        loader = nil
    }
}

public class ImageLoader {
    let callback: (Result<LoadedImage, Error>) -> Void
    let frame: CGRect
    let key: String
    var task: APITask?
    let url: URL
    var webView: WKWebView?

    private let shouldFailForAnimatedGif: Bool

    private static var rendered: [String: LoadedImage] = [:]
    private static var loading: [String: [ImageLoader]] = [:]

    static func reset() {
        rendered = [:]
        loading = [:]
    }

    init(url: URL, frame: CGRect, shouldFailForAnimatedGif: Bool = false, callback: @escaping (Result<LoadedImage, Error>) -> Void) {
        self.callback = callback
        self.frame = frame
        let keyBase = url.absoluteStringWithoutTokenQuery
        self.key = url.pathExtension == "svg"
            ? "\(keyBase)@\(frame.width)x\(frame.height)"
            : keyBase
        self.url = url
        self.shouldFailForAnimatedGif = shouldFailForAnimatedGif
    }

    func cancel() {
        task?.cancel()
        task = nil
    }

    @discardableResult
    func load() -> APITask? {
        if let loaded = ImageLoader.rendered[key] {
            callback(.success(loaded))
            return nil
        } else if ImageLoader.loading[key] != nil {
            ImageLoader.loading[key]?.append(self)
            return nil
        }
        ImageLoader.loading[key] = []
        ImageLoader.loading[key]?.append(self)

        task = API().makeRequest(url) { data, response, error in
            self.task = nil
            if let data = data, error == nil {
                self.imageFrom(data: data, response: response as? HTTPURLResponse)
            } else {
                self.handle(nil, 0, error)
            }
        }
        task?.resume()
        return task
    }

    func imageFrom(data: Data, response: HTTPURLResponse? = nil) {
        let type = response?.mimeType
        if type?.hasPrefix("image/svg") == true || url.pathExtension.lowercased() == "svg" {
            performUIUpdate { self.svgFrom(data: data) }
        } else if shouldFailForAnimatedGif
                    && (type == "image/gif" || url.pathExtension.lowercased() == "gif")
                    && isAnimatedGif(data: data) {
            handle(nil, 0, LoadedImage.Error.animatedGifFound)
        } else {
            handle(UIImage(data: data)?.normalize())
        }
    }

    func handle(_ image: UIImage?, _ repeatCount: Int = 0, _ error: Error? = nil) {
        performUIUpdate { self.notify(image, repeatCount, error) }
    }

    func notify(_ image: UIImage?, _ repeatCount: Int, _ error: Error? = nil) {
        let result: Result<LoadedImage, Error>
        if let image = image {
            let loaded = LoadedImage(image: image, repeatCount: repeatCount)
            if !url.isFileURL { ImageLoader.rendered[key] = loaded }
            result = .success(loaded)
        } else {
            result = .failure(error ?? NSError.internalError())
        }
        for loader in ImageLoader.loading[key] ?? [] {
            loader.callback(result)
        }
        ImageLoader.loading[key] = nil
    }

    // MARK: - SVG snapshot

    func svgFrom(data: Data) {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        let view = WKWebView(frame: frame, configuration: config)
        view.backgroundColor = .clear
        view.isOpaque = false
        webView = view

        let dataUri = "data:image/svg+xml;base64,\(data.base64EncodedString())"
        let html = """
            <!doctype html>
            <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no">
            <style>*{margin:0;padding:0;height:100%;width:100%;}</style>
            <img src="\(dataUri)" style="object-position:center;object-fit:contain;"
                onload="setTimeout(()=>webkit.messageHandlers.svg.postMessage(''),17)"
            />
        """
        view.handle("svg") { [weak self] _ in
            self?.webView?.takeSnapshot(with: nil) { snapshot, error in
                self?.webView = nil
                self?.handle(snapshot, 0, error)
            }
        }
        view.loadHTMLString(html, baseURL: url)
    }

    // MARK: - GIF to UIImage.animatedImage

    func isAnimatedGif(data: Data) -> Bool {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return false }
        let count = CGImageSourceGetCount(source)
        return count > 1
    }

    func gifFrom(data: Data) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return handle(UIImage(data: data)) }
        let count = CGImageSourceGetCount(source)
        guard count > 1 else { return handle(UIImage(data: data)) }
        var delays: [Int] = [] // in centiseconds
        var commonFactor: Int?
        for index in 0..<count {
            let delay = Int(round(gifDelayAt(index, source: source) * 100.0))
            delays.append(delay)
            commonFactor = greatestCommonFactor(delay, commonFactor ?? delay)
        }
        var images: [UIImage] = []
        var duration = 0
        for index in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil), let factor = commonFactor {
                let image = UIImage(cgImage: cgImage)
                duration += delays[index]
                for _ in 0..<(delays[index] / factor) {
                    images.append(image)
                }
            }
        }
        handle(UIImage.animatedImage(with: images, duration: Double(duration) / 100.0), gifLoopCount(source: source))
    }

    func gifDelayAt(_ index: Int, source: CGImageSource) -> TimeInterval {
        if let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil),
            let gif = (properties as NSDictionary)[kCGImagePropertyGIFDictionary] as? NSDictionary,
            let delay = gif[kCGImagePropertyGIFDelayTime] as? TimeInterval {
            return max(delay, 0.02)
        }
        return 0.1
    }

    func gifLoopCount(source: CGImageSource) -> Int {
        if let properties = CGImageSourceCopyProperties(source, nil),
            let gif = (properties as NSDictionary)[kCGImagePropertyGIFDictionary] as? NSDictionary,
            let count = gif[kCGImagePropertyGIFLoopCount] as? Int {
            return count
        }
        return 1
    }
}

/// Use Euclid's method to find the largest factor in common between two `Int`s.
/// 
/// - Returns: Greatest common `Int` factor of `a` and `b`.
public func greatestCommonFactor(_ a: Int, _ b: Int) -> Int {
    var a = a
    var b = b
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return a
}

private extension URL {
    var absoluteStringWithoutTokenQuery: String {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let tokenIndex = components.queryItems?.firstIndex(where: { $0.name == "token" })
        else {
            return absoluteString
        }

        components.queryItems?.remove(at: tokenIndex)

        return components.url?.absoluteString ?? absoluteString
    }
}
