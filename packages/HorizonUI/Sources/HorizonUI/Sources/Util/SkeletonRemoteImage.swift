//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import SwiftUI

public struct SkeletonRemoteImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let topLeading: CGFloat
    let topTrailing: CGFloat
    let bottomLeading: CGFloat
    let bottomTrailing: CGFloat
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var loadedImage: Image?
    @State private var didFail: Bool = false
    @State private var isLoading: Bool = true

    public init(
        url: URL?,
        topLeading: CGFloat = 6,
        topTrailing: CGFloat = 6,
        bottomLeading: CGFloat = 6,
        bottomTrailing: CGFloat = 6,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.topLeading = topLeading
        self.topTrailing = topTrailing
        self.bottomLeading = bottomLeading
        self.bottomTrailing = bottomTrailing
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            if let loadedImage {
                content(loadedImage)
            } else if didFail {
                placeholder()
            } else if isLoading {
                skeletonView
            } else {
                placeholder()
            }
        }
        .task(id: url?.absoluteString) {
            await loadImage()
        }
    }

    private var skeletonView: some View {
        GeometryReader { proxy in
            UnevenRoundedRectangle(
                topLeadingRadius: topLeading,
                bottomLeadingRadius: bottomLeading,
                bottomTrailingRadius: bottomTrailing,
                topTrailingRadius: topTrailing
            )
            .fill(.tertiary)
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .modifier(Shimmer())
        .accessibilityHidden(true)
    }

    private func loadImage() async {
        guard let url else {
            isLoading = false
            didFail = true
            return
        }

        isLoading = true
        didFail = false

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            if isSVGData(data) {
                if let uiImage = await convertSVGToUIImage(data: data) {
                    loadedImage = Image(uiImage: uiImage)
                    isLoading = false
                } else {
                    didFail = true
                    isLoading = false
                }
            } else {
                if let uiImage = UIImage(data: data) {
                    loadedImage = Image(uiImage: uiImage)
                    isLoading = false
                } else {
                    didFail = true
                    isLoading = false
                }
            }
        } catch {
            didFail = true
            isLoading = false
        }
    }

    private func isSVGData(_ data: Data) -> Bool {
        guard let string = String(data: data.prefix(1000), encoding: .utf8) else {
            return false
        }
        return string.contains("<svg") || string.contains("<?xml")
    }

    private func convertSVGToUIImage(data: Data) async -> UIImage? {
        guard let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        let size = extractSVGSize(from: string) ?? CGSize(width: 300, height: 300)

        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let configuration = WKWebViewConfiguration()
                configuration.defaultWebpagePreferences.allowsContentJavaScript = false
                let webView = WKWebView(frame: CGRect(origin: .zero, size: size), configuration: configuration)
                webView.isOpaque = false
                webView.backgroundColor = .clear
                webView.scrollView.backgroundColor = .clear

                let html = """
                <!DOCTYPE html>
                <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
                    <style>
                        * { margin: 0; padding: 0; }
                        html, body { width: 100%; height: 100%; background: transparent; }
                        svg { display: block; width: 100%; height: 100%; }
                    </style>
                </head>
                <body>
                    \(string)
                </body>
                </html>
                """

                webView.loadHTMLString(html, baseURL: nil)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let snapshotConfig = WKSnapshotConfiguration()
                    snapshotConfig.rect = CGRect(origin: .zero, size: size)

                    webView.takeSnapshot(with: snapshotConfig) { image, error in
                        if error != nil {
                            continuation.resume(returning: nil)
                        } else {
                            continuation.resume(returning: image)
                        }
                    }
                }

                objc_setAssociatedObject(webView, "retainWebView", webView, .OBJC_ASSOCIATION_RETAIN)
            }
        }
    }

    private func extractSVGSize(from svgString: String) -> CGSize? {
        let widthPattern = #"width\s*=\s*["']?(\d+)"#
        let heightPattern = #"height\s*=\s*["']?(\d+)"#

        let widthRegex = try? NSRegularExpression(pattern: widthPattern)
        let heightRegex = try? NSRegularExpression(pattern: heightPattern)

        let nsString = svgString as NSString
        let range = NSRange(location: 0, length: nsString.length)

        var width: CGFloat = 300
        var height: CGFloat = 300

        if let widthMatch = widthRegex?.firstMatch(in: svgString, range: range),
           widthMatch.numberOfRanges > 1 {
            let widthRange = widthMatch.range(at: 1)
            if let widthValue = Double(nsString.substring(with: widthRange)) {
                width = CGFloat(widthValue)
            }
        }

        if let heightMatch = heightRegex?.firstMatch(in: svgString, range: range),
           heightMatch.numberOfRanges > 1 {
            let heightRange = heightMatch.range(at: 1)
            if let heightValue = Double(nsString.substring(with: heightRange)) {
                height = CGFloat(heightValue)
            }
        }

        return CGSize(width: width, height: height)
    }
}

import WebKit
