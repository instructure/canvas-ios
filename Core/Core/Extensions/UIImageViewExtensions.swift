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

public struct LoadedImage {
    let image: UIImage
    let repeatCount: Int
}

private var urlHandle: UInt8 = 0
private var loaderHandle: UInt8 = 0

public protocol ImageLoadingView: class {
    var frame: CGRect { get }
    func load(url: URL, didCompleteWith: LoadedImage?, error: Error?)
}

extension UIImageView: ImageLoadingView {
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
    public func load(url: URL?) -> URLSessionTask? {
        guard self.url != url else { return nil }
        self.url = url
        loader = nil
        image = nil
        if let url = url {
            loader = ImageLoader(url: url, view: self)
        }
        return loader?.load()
    }

    public func load(url: URL, didCompleteWith loaded: LoadedImage?, error: Error?) {
        guard self.url == url else { return }
        if let cached = loaded {
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
    let frame: CGRect
    let key: String
    var task: URLSessionTask?
    let url: URL
    weak var view: ImageLoadingView?
    var webView: WKWebView?

    private static var rendered: [String: LoadedImage] = [:]
    private static var loading: [String: [ImageLoader]] = [:]

    static func reset() {
        rendered = [:]
        loading = [:]
    }

    init(url: URL, view: ImageLoadingView) {
        self.frame = view.frame
        self.key = url.pathExtension == "svg"
            ? "\(url.absoluteString)@\(view.frame.width)x\(view.frame.height)"
            : url.absoluteString
        self.url = url
        self.view = view
    }

    func cancel() {
        task?.cancel()
        task = nil
    }

    @discardableResult
    func load() -> URLSessionTask? {
        if let loaded = ImageLoader.rendered[key] {
            view?.load(url: url, didCompleteWith: loaded, error: nil)
            return nil
        } else if ImageLoader.loading[key] != nil {
            ImageLoader.loading[key]?.append(self)
            return nil
        }
        ImageLoader.loading[key] = []
        ImageLoader.loading[key]?.append(self)

        task = URLSessionAPI.defaultURLSession.dataTask(with: URLRequest(url: url)) { data, response, error in
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
        } else if type == "image/gif" || url.pathExtension.lowercased() == "gif" {
            gifFrom(data: data)
        } else {
            handle(UIImage(data: data)?.normalize())
        }
    }

    func handle(_ image: UIImage?, _ repeatCount: Int = 0, _ error: Error? = nil) {
        performUIUpdate { self.notify(image, repeatCount, error) }
    }

    func notify(_ image: UIImage?, _ repeatCount: Int, _ error: Error? = nil) {
        var loaded: LoadedImage?
        if let image = image {
            loaded = LoadedImage(image: image, repeatCount: repeatCount)
            if !url.isFileURL { ImageLoader.rendered[key] = loaded }
        }
        for loader in ImageLoader.loading[key] ?? [] {
            loader.view?.load(url: url, didCompleteWith: loaded, error: error)
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
/// Assumes both numbers are greater than zero.
///
/// - Parameter a: An `Int` greater than zero.
/// - Parameter b: An `Int` greater than zero.
/// - Returns: Greatest common `Int` factor of `a` and `b`.
public func greatestCommonFactor(_ a: Int, _ b: Int) -> Int {
    var a = a
    var b = b
    while a != b {
        if a < b {
            b -= a
        } else {
            a -= b
        }
    }
    return a
}
