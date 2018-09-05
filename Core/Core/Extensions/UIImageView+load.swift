//
// Copyright (C) 2018-present Instructure, Inc.
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

import UIKit
import WebKit

public struct LoadedImage {
    let image: UIImage
    let repeatCount: Int
}
private var loading: [String: [ImageLoader]] = [:]

private var urlHandle: UInt8 = 0
private var loaderHandle: UInt8 = 0

public protocol ImageLoadingView: class {
    var loader: ImageLoader? { get }
    func load(url: URL?) -> URLSessionTask?
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
        loader?.cancel()
        loader = nil
        image = nil
        if let url = url {
            loader = ImageLoader(url: url, frame: frame, contentMode: contentMode, view: self)
        }
        return loader?.load()
    }

    public func load(url: URL, didCompleteWith loaded: LoadedImage?, error: Error?) {
        if let cached = loaded {
            image = cached.image
            if let images = cached.image.images {
                image = images.last
                animationDuration = cached.image.duration
                animationImages = images
                animationRepeatCount = cached.repeatCount
                startAnimating()
            }
        }
        loader = nil
    }
}

public class ImageLoader {
    let url: URL
    let frame: CGRect
    let contentMode: UIViewContentMode
    let key: String

    weak var view: ImageLoadingView?

    var task: URLSessionTask?
    var observation: NSKeyValueObservation?
    var webView: WKWebView?

    init(url: URL, frame: CGRect, contentMode: UIViewContentMode, view: ImageLoadingView) {
        self.url = url
        self.frame = frame
        self.contentMode = contentMode
        self.view = view
        self.key = "\(url.absoluteString)@\(frame.width)x\(frame.height):\(contentMode)"
    }

    func cancel() {
        if let index = loading[key]?.index(where: { loader in loader === self }) {
            loading[key]?.remove(at: index)
            if loading[key]?.isEmpty ?? true {
                loading[key] = nil
            }
        }
        // if no one else is listening, clean up
        if loading[key] == nil {
            task?.cancel()
            task = nil
        }
    }

    @discardableResult
    func load() -> URLSessionTask? {
        if loading[key] != nil {
            loading[key]?.append(self)
            return nil
        }
        loading[key] = []
        loading[key]?.append(self)

        task = URLSession.shared.dataTask(with: url) { data, response, error in
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
        let type = response?.allHeaderFields["Content-Type"] as? String
        if type == "image/svg+xml" || url.pathExtension == "svg", #available(iOS 11.0, *) {
            DispatchQueue.main.async { self.svgFrom(data: data) }
        } else if type == "image/gif" || url.pathExtension == "gif" {
            gifFrom(data: data)
        } else {
            handle(UIImage(data: data))
        }
    }

    func handle(_ image: UIImage?, _ repeatCount: Int = 0, _ error: Error? = nil) {
        DispatchQueue.main.async { self.notify(image, repeatCount, error) }
    }

    func notify(_ image: UIImage?, _ repeatCount: Int, _ error: Error? = nil) {
        var loaded: LoadedImage?
        if let image = image {
            loaded = LoadedImage(image: image, repeatCount: repeatCount)
        }
        if let queue = loading[key] {
            for loader in queue {
                loader.view?.load(url: url, didCompleteWith: loaded, error: error)
            }
        }
        loading[key] = nil
    }

    // MARK: - SVG snapshot

    @available(iOS 11.0, *)
    func svgFrom(data: Data) {
        let view = WKWebView(frame: frame, configuration: WKWebViewConfiguration())
        view.isOpaque = false
        view.backgroundColor = .clear
        view.scrollView.backgroundColor = .clear
        webView = view

        observation = view.observe(\.title, options: .new) { webView, _ in
            guard webView.title == "SVG" else { return }
            webView.takeSnapshot(with: nil) { snapshot, error in
                self.webView = nil
                self.observation = nil
                self.handle(snapshot, 0, error)
            }
        }

        let dataUri = "data:image/svg+xml;base64,\(data.base64EncodedString())"
        let html = """
            <!doctype html>
            <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no">
            <style>html{height:100%;background:no-repeat \(cssFromContentMode(contentMode)) url(\(dataUri))}</style>
            <script>window.onload=()=>{document.title="SVG"}</script>
        """
        view.loadHTMLString(html, baseURL: url)
    }

    // swiftlint:disable cyclomatic_complexity
    func cssFromContentMode(_ contentMode: UIViewContentMode) -> String {
        switch contentMode {
        case .bottom: return "bottom"
        case .bottomLeft: return "bottom left"
        case .bottomRight: return "bottom right"
        case .center: return "center"
        case .left: return "left"
        case .redraw: return "center/100% 100%"
        case .right: return "right"
        case .scaleAspectFill: return "center/cover"
        case .scaleAspectFit: return "center/contain"
        case .scaleToFill: return "center/100% 100%"
        case .top: return "top"
        case .topLeft: return "top left"
        case .topRight: return "top right"
        }
    }
    // swiftlint:enable cyclomatic_complexity

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
