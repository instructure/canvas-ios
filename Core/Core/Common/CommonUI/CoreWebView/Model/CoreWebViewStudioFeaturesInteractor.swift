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

public class CoreWebViewStudioFeaturesInteractor {

    private static let scanFramesScript = """
        function scanVideoFramesForTitles() {
            var result = []

            let mediaFrames = document.querySelectorAll("iframe[data-media-id]");
            mediaFrames.forEach(elm => {

                var frameLink =  elm.getAttribute("src");
                frameLink = frameLink.replace("media_attachments_iframe", "media_attachments");

                const videoTitle = elm.getAttribute("title");
                const ariaTitle = elm.getAttribute("aria-title");
                const title = videoTitle ?? ariaTitle;

                result.push({ token: frameLink, title: title});
            });

            let ltiFrames = document.querySelectorAll("iframe[class='lti-embed']");
            ltiFrames.forEach(elm => {

                let frameSource = elm.getAttribute("src");
                if(!frameSource) { return }

                let frameURL = new URL(frameSource);
                let playerSource = frameURL.searchParams.get("url");
                if(!playerSource) { return }

                let playerURL = new URL(playerSource);
                let mediaID = playerURL.searchParams.get("custom_arc_media_id");
                if(!mediaID) { return }

                const videoTitle = elm.getAttribute("title");
                const ariaTitle = elm.getAttribute("aria-title");
                const title = videoTitle ?? ariaTitle;

                result.push({ token: mediaID, title: title });
            });

            return result;
        }

        scanVideoFramesForTitles();
    """

    var onScanFinished: (() -> Void)?
    var onFeatureUpdate: (() -> Void)?

    private(set) weak var webView: CoreWebView?
    private var environment: AppEnvironment?
    private var context: Context?
    private var studioImprovementsFlagStore: ReactiveStore<GetFeatureFlagState>?
    private var storeSubscription: AnyCancellable?

    /// This is to persist a map of video URL vs Title for the currently loaded page
    /// of CoreWebView. Supposed to be updated (or emptied) on each page load.
    private(set) var videoFramesTitleMap: [String: String] = [:]

    init(webView: CoreWebView) {
        self.webView = webView
    }

    func resetFeatureFlagStore(context: Context?, env: AppEnvironment) {
        guard let context else {
            storeSubscription?.cancel()
            storeSubscription = nil
            studioImprovementsFlagStore = nil
            self.context = nil
            self.environment = nil
            return
        }

        self.context = context
        self.environment = env

        studioImprovementsFlagStore = ReactiveStore(
            useCase: GetFeatureFlagState(
                featureName: .studioEmbedImprovements,
                context: context
            ),
            environment: env
        )

        resetStoreSubscription()
    }

    func urlForStudioImmersiveView(ofMediaPath mediaPath: String) -> StudioPage? {
        guard
            let environment,
            let context,
            var urlComps = URLComponents(string: environment.api.baseURL.absoluteString)
        else { return nil }

        urlComps.path = "/\(context.pathComponent)/external_tools/retrieve"
        urlComps.percentEncodedQueryItems = [
            URLQueryItem(name: "display", value: "full_width"),
            URLQueryItem(name: "embedded", value: "true"),
            URLQueryItem(
                name: "url",
                value: mediaPath
                    .addingPercentEncoding(
                        withAllowedCharacters: .urlHostAllowed
                            .union(.urlPathAllowed)
                            .union(.urlQueryAllowed)
                            .union(CharacterSet(charactersIn: "?"))
                            .subtracting(CharacterSet(charactersIn: "&="))
                    )
            )
        ]

        guard let url = urlComps.url else { return nil }

        if let mediaURL = URL(string: mediaPath) {
            return StudioPage(
                title: videoPlayerFrameTitle(forStudioMediaURL: mediaURL),
                url: url
            )
        }

        return StudioPage(url: url)
    }

    func urlForStudioImmersiveView(ofNavAction action: NavigationActionRepresentable) -> StudioPage? {
        guard action.isStudioImmersiveViewLinkTap, var url = action.request.url else {
            return nil
        }

        var title: String?
        if url.containsQueryItem(named: "title") == false {
            title = videoPlayerFrameTitle(forCanvasMediaURL: url)
        }

        if url.containsQueryItem(named: "embedded") == false {
            url = url.appendingQueryItems(.init(name: "embedded", value: "true"))
        }

        return StudioPage(title: title, url: url)
    }

    /// To be called in didFinishLoading delegate method of WKWebView, it scans through
    /// currently loaded page HTML content looking for video studio `iframe`s. It will extract
    /// `title` attribute value and keep a map of such values vs video src URL, to be used
    /// later to set immersive video player title. This mainly useful when triggering the player
    /// from a button that's internal to video-frame. (`Expand` button)
    func scanVideoFrames() {
        guard let webView else { return }

        videoFramesTitleMap.removeAll()
        webView.evaluateJavaScript(Self.scanFramesScript) { [weak self] result, error in

            if let error {
                RemoteLogger.shared.logError(
                    name: "Error scanning video iframes elements",
                    reason: error.localizedDescription
                )
            }

            var mapped: [String: String] = [:]

            (result as? [[String: String]] ?? [])
                .forEach({ pair in
                    guard
                        let token = pair["token"],
                        let title = pair["title"]
                    else { return }

                    mapped[token] = title
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
        guard let webView else { return }

        if isEnabled {
            webView.addFeature(.insertStudioOpenInDetailButtons)
        } else {
            webView.removeFeatures(ofType: InsertStudioOpenInDetailButtons.self)
        }

        onFeatureUpdate?()
    }

    private func videoPlayerFrameTitle(forCanvasMediaURL url: URL) -> String? {
        let path = url.removingQueryAndFragment().absoluteString
        return videoFramesTitleMap.first(where: { path.hasPrefix($0.key) })?.value
    }

    private func videoPlayerFrameTitle(forStudioMediaURL mediaURL: URL) -> String? {
        if let mediaID = mediaURL.queryValue(for: "custom_arc_media_id") {
            return videoFramesTitleMap.first(where: { $0.key == mediaID })?.value
        }
        return nil
    }
}

// MARK: - WKNavigationAction Extensions

extension NavigationActionRepresentable {

    fileprivate var isStudioImmersiveViewLinkTap: Bool {
        guard let path = request.url?.path else { return false }

        let isExpandLink =
        navigationType == .other
        && path.contains("/media_attachments/")
        && path.hasSuffix("/immersive_view")
        && sourceInfoFrame.isMainFrame == false

        let isCanvasUploadDetailsLink =
        navigationType == .linkActivated
        && path.contains("/media_attachments/")
        && path.hasSuffix("/immersive_view")
        && (targetInfoFrame?.isMainFrame ?? false) == false

        let query = request.url?.query()?.removingPercentEncoding ?? ""
        let isStudioEmbedDetailsLink =
        navigationType == .linkActivated
        && path.hasSuffix("/external_tools/retrieve")
        && query.contains("custom_arc_launch_type=immersive_view")
        && (targetInfoFrame?.isMainFrame ?? false) == false

        return isExpandLink || isCanvasUploadDetailsLink || isStudioEmbedDetailsLink
    }
}
