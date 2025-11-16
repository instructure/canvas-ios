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

import Combine
import WebKit

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
    private var studioImprovementsFlagStore: ReactiveStore<GetFeatureFlagState>?
    private var storeSubscription: AnyCancellable?

    /// This is to persist a map of video URL vs Title for the currently loaded page
    /// of CoreWebView. Supposed to be updated (or emptied) on each page load.
    private(set) var videoFramesTitleMap: [String: String] = [:]

    var onScanFinished: (() -> Void)?

    init(webView: CoreWebView) {
        self.webView = webView
    }

    func resetFeatureFlagStore(context: Context?, env: AppEnvironment) {
        storeSubscription?.cancel()

        guard let context else {
            storeSubscription = nil
            studioImprovementsFlagStore = nil
            return
        }

        studioImprovementsFlagStore = ReactiveStore(
            useCase: GetFeatureFlagState(
                featureName: .studioEmbedImprovements,
                context: context
            ),
            environment: env
        )

        resetStoreSubscription()
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

    /// To be called in didFinishLoading delegate method of WKWebView, it scans through
    /// currently loaded page HTML content looking for video studio `iframe`s. It will extract
    /// `title` attribute value and keep a map of such values vs video src URL, to be used
    /// later to set immersive video player title. This mainly useful when triggering the player
    /// from a button that's internal to video-frame. (`Expand` button)
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

    public func refresh() {
        resetStoreSubscription(ignoreCache: true)
    }

    // MARK: Privates

    private func resetStoreSubscription(ignoreCache: Bool = false) {
        storeSubscription?.cancel()
        storeSubscription = studioImprovementsFlagStore?
            .getEntities(ignoreCache: ignoreCache, keepObservingDatabaseChanges: true)
            .replaceError(with: [])
            .map({ $0.first?.enabled ?? false })
            .sink(receiveValue: { [weak self] isEnabled in
                self?.updateStudioImprovementFeature(isEnabled: isEnabled)
            })
    }

    private func updateStudioImprovementFeature(isEnabled: Bool) {
        if isEnabled {
            webView.addFeature(.insertStudioOpenInDetailButtons)
        } else {
            webView.removeFeatures(ofType: InsertStudioOpenInDetailButtons.self)
        }
    }

    private func videoPlayerFrameTitle(matching url: URL) -> String? {
        let path = url.removingQueryAndFragment().absoluteString
        return videoFramesTitleMap.first(where: { path.hasPrefix($0.key) })?
            .value
    }
}

// MARK: - WKNavigationAction Extensions

extension WKNavigationAction {

    fileprivate var isStudioImmersiveViewLinkTap: Bool {
        guard let path = request.url?.path else { return false }

        let isExpandLink =
            navigationType == .other
            && path.contains("/media_attachments/") == true
            && path.hasSuffix("/immersive_view") == true
            && sourceFrame.isMainFrame == false

        let isDetailsLink =
            navigationType == .linkActivated
            && path.contains("/media_attachments/") == true
            && path.hasSuffix("/immersive_view") == true
            && (targetFrame?.isMainFrame ?? false) == false

        return isExpandLink || isDetailsLink
    }
}
