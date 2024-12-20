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

    func load(url: URL, result: Result<UIImage, Error>) {
        guard self.url == url else { return }

        if let image = result.value {
            self.image = image
        }

        loader = nil
    }
}

public enum ImageLoaderError: Swift.Error {
    case animatedGifFound
}

public class ImageLoader {

    let callback: (Result<UIImage, Error>) -> Void
    let frame: CGRect
    let key: String
    var task: APITask?
    let url: URL
    var webView: WKWebView?

    private let shouldFailForAnimatedGif: Bool

    private static var rendered: [String: UIImage] = [:]
    private static var isAnimated: [String: Bool] = [:]
    private static var loading: [String: [ImageLoader]] = [:]

    static func reset() {
        rendered = [:]
        isAnimated = [:]
        loading = [:]
    }

    init(url: URL, frame: CGRect, shouldFailForAnimatedGif: Bool = false, callback: @escaping (Result<UIImage, Error>) -> Void) {
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
        if shouldFailForAnimatedGif && ImageLoader.isAnimated[key] == true {
            callback(.failure(ImageLoaderError.animatedGifFound))
            return nil
        }

        if let loaded = ImageLoader.rendered[key] {
            callback(.success(loaded))
            return nil
        }

        if ImageLoader.loading[key] != nil {
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
                self.handle(nil, error)
            }
        }
        task?.resume()
        return task
    }

    private func imageFrom(data: Data, response: HTTPURLResponse? = nil) {
        let type = response?.mimeType
        if type?.hasPrefix("image/svg") == true || url.pathExtension.lowercased() == "svg" {
            performUIUpdate { self.svgFrom(data: data) }
        } else if (type == "image/gif" || url.pathExtension.lowercased() == "gif")
                    && isAnimatedGif(data: data) {
            ImageLoader.isAnimated[key] = true

            if shouldFailForAnimatedGif {
                handle(nil, ImageLoaderError.animatedGifFound)
            } else {
                handle(UIImage(data: data))
            }
        } else {
            ImageLoader.isAnimated[key] = false
            handle(UIImage(data: data)?.normalize())
        }
    }

    private func handle(_ image: UIImage?, _ error: Error? = nil) {
        performUIUpdate { self.notify(image, error) }
    }

    private func notify(_ image: UIImage?, _ error: Error? = nil) {
        let result: Result<UIImage, Error>
        if let image {
            if !url.isFileURL { ImageLoader.rendered[key] = image }
            result = .success(image)
        } else {
            result = .failure(error ?? NSError.internalError())
        }

        let activeLoaders = ImageLoader.loading[key] ?? []
        ImageLoader.loading[key] = nil

        for loader in activeLoaders {
            loader.callback(result)
        }
    }

    // MARK: - SVG snapshot

    private func svgFrom(data: Data) {
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
                self?.handle(snapshot, error)
            }
        }
        view.loadHTMLString(html, baseURL: url)
    }

    // MARK: - GIF

    private func isAnimatedGif(data: Data) -> Bool {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return false }
        let count = CGImageSourceGetCount(source)
        return count > 1
    }
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
