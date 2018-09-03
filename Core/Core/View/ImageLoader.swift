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

// private image cache
private var rendered: [String: UIImage] = [:]
private var loading: [String: [ImageLoader]] = [:]

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

public class ImageLoader {
    public enum Size: String {
        case contain, cover
    }

    let url: URL
    let frame: CGRect
    let size: Size
    let callback: (UIImage?, Error?) -> Void
    let key: String
    var observation: NSKeyValueObservation?
    var webView: WKWebView?

    init(url: URL, frame: CGRect, size: Size, callback: @escaping (UIImage?, Error?) -> Void) {
        self.url = url
        self.frame = frame
        self.size = size
        self.callback = callback
        self.key = "\(url.absoluteString)@\(frame.width)x\(frame.height):\(size)"
    }

    @discardableResult
    public static func load(url: URL, frame: CGRect, size: Size = .contain, callback: @escaping (UIImage?, Error?) -> Void) -> URLSessionTask? {
        let loader = ImageLoader(url: url, frame: frame, size: size, callback: callback)
        return loader.load()
    }

    @discardableResult
    func load() -> URLSessionTask? {
        if let image = rendered[key] {
            DispatchQueue.main.async { self.callback(image, nil) }
            return nil
        } else if loading[key] != nil {
            loading[key]?.append(self)
            return nil
        }
        loading[key] = []
        loading[key]?.append(self)

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                self.imageFrom(data: data, response: response as? HTTPURLResponse)
            } else {
                self.handle(nil, error)
            }
        }
        task.resume()
        return task
    }

    func imageFrom(data: Data, response: HTTPURLResponse? = nil) {
        let type = response?.allHeaderFields["Content-Type"] as? String
        if type == "image/svg+xml" || url.pathExtension == "svg", #available(iOS 11.0, *) {
            DispatchQueue.main.async { self.svgFrom(data: data) }
        } else if type == "image/gif" || url.pathExtension == "gif", let gif = gifAnimationFrom(data: data) {
            handle(gif)
        } else {
            handle(UIImage(data: data))
        }
    }

    func handle(_ image: UIImage?, _ error: Error? = nil) {
        DispatchQueue.main.async { self.notify(image, error) }
    }

    func notify(_ image: UIImage?, _ error: Error? = nil) {
        rendered[key] = image
        if let queue = loading[key] {
            for view in queue {
                view.callback(image, error)
            }
        }
        loading[key] = nil
        observation = nil
        webView = nil
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
                self.handle(snapshot, error)
            }
        }

        let dataUri = "data:image/svg+xml;base64,\(data.base64EncodedString())"
        let html = """
            <!doctype html>
            <meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no">
            <style>html{height:100%;background:no-repeat center/\(size) url(\(dataUri))}</style>
            <script>window.onload=()=>{document.title="SVG"}</script>
        """
        view.loadHTMLString(html, baseURL: url)
    }

    // MARK: - GIF to UIImage.animatedImage

    func gifAnimationFrom(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        guard count > 1 else { return nil }
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
        return UIImage.animatedImage(with: images, duration: Double(duration) / 100.0)
    }

    func gifDelayAt(_ index: Int, source: CGImageSource) -> TimeInterval {
        if let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil),
            let gif = (properties as NSDictionary)[kCGImagePropertyGIFDictionary] as? NSDictionary,
            let delay = gif[kCGImagePropertyGIFDelayTime] as? TimeInterval {
            return max(delay, 0.02)
        }
        return 0.1
    }
}
