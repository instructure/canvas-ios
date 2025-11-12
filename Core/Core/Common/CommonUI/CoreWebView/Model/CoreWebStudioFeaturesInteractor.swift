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

import WebKit
import UIKit
import Combine

public class CoreWebStudioFeaturesInteractor {
    private static let scanFramesScript = """
        function scanVideoFramesForTitles() {
            const frameElements = document.querySelectorAll('iframe[data-media-id]');
            var result = []

            frameElements.forEach(elm => {

                var frameLink =  elm.getAttribute("src");
                frameLink = frameLink.replace("media_attachments_iframe", "media_attachments");

                const videoTitle = elm.getAttribute("title");
                const ariaTitle = elm.getAttribute("aria-title");
                const title = videoTitle ?? ariaTitle;

                result.push({url: frameLink, title: title});
            });

            return result;
        }

        scanVideoFramesForTitles();
    """

    unowned let webView: CoreWebView
    private var studioImprovementsFlag: Store<GetFeatureFlagState>?
    private(set) var videoFramesTitleMap: [String: String] = [:]

    var onScanFinished: (() -> Void)?

    init(webView: CoreWebView) {
        self.webView = webView
    }

    func setupFeatureFlagStore(context: Context?, env: AppEnvironment) {
        guard let context else {
            studioImprovementsFlag = nil
            return
        }

        studioImprovementsFlag = env.subscribe(
            GetFeatureFlagState(featureName: .studioEmbedImprovements, context: context)
        ) { [weak self] in
            self?.updateStudioFeatures()
        }

        studioImprovementsFlag?.refresh()
    }

    public func refresh() {
        studioImprovementsFlag?.refresh(force: true)
    }

    private func updateStudioFeatures() {
        guard let studioImprovementsFlag else { return }

        let isStudioImprovementsEnabled = studioImprovementsFlag.first?.enabled ?? false
        if isStudioImprovementsEnabled {
            webView.addFeature(.insertStudioOpenInDetailButtons)
        } else {
            webView.removeFeatures(ofType: InsertStudioOpenInDetailButtons.self)
        }
    }

    func urlForStudioImmersiveView(of action: WKNavigationAction) -> URL? {
        guard action.isStudioImmersiveViewLinkTap, var url = action.request.url else {
            return nil
        }

        if url.containsQueryItem(named: "title") == false,
            let title = videoPlayerFrameTitle(matching: url) {
            url.append(queryItems: [.init(name: "title", value: title)])
        }

        if url.containsQueryItem(named: "embedded") == false {
            url.append(queryItems: [.init(name: "embedded", value: "true")])
        }

        return url
    }

    func scanVideoFrames() {

        videoFramesTitleMap.removeAll()
        webView.evaluateJavaScript(Self.scanFramesScript) { [weak self] result, _ in

            var mapped: [String: String] = [:]

            (result as? [[String: String]] ?? [])
                .forEach({ pair in
                    guard
                        let urlString = pair["url"],
                        let urlCleanPath = URL(string: urlString)?
                            .removingQueryAndFragment()
                            .absoluteString,
                        let title = pair["title"]
                    else { return }

                    mapped[urlCleanPath] = title
                        .replacingOccurrences(of: "Video player for ", with: "")
                        .replacingOccurrences(of: ".mp4", with: "")
                })

            self?.videoFramesTitleMap = mapped
            self?.onScanFinished?()
        }
    }

    private func videoPlayerFrameTitle(matching url: URL) -> String? {
        let path = url.removingQueryAndFragment().absoluteString
        return videoFramesTitleMap.first(where: { path.hasPrefix($0.key) })?.value
    }
}

// MARK: - WKNavigationAction Extensions

private extension WKNavigationAction {

    var isStudioImmersiveViewLinkTap: Bool {
        let isExpandLink = navigationType == .other &&
        request.url?.path.contains("/media_attachments/") == true &&
        request.url?.path.hasSuffix("/immersive_view") == true &&
        sourceFrame.isMainFrame == false

        let isDetailsLink = navigationType == .linkActivated &&
        request.url?.path.contains("/media_attachments/") == true &&
        request.url?.path.hasSuffix("/immersive_view") == true &&
        (targetFrame?.isMainFrame ?? false) == false

        return isExpandLink || isDetailsLink
    }
}
