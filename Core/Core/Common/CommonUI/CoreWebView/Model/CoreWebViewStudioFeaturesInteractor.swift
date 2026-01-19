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
    static let fullWindowLaunchEventName: String = "fullWindowLaunch"

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

    private(set) weak var webView: CoreWebView?
    private var env: AppEnvironment
    private var context: Context?

    /// This is to persist a map of video URL vs Title for the currently loaded page
    /// of CoreWebView. Supposed to be updated (or emptied) on each page load.
    private(set) var videoFramesTitleMap: [String: String] = [:]

    init(webView: CoreWebView, env: AppEnvironment = .shared) {
        self.webView = webView
        self.env = env
    }

    func reset(context: Context?, env: AppEnvironment) {
        self.env = env
        self.context = context
    }

    func handleFullWindowLaunchMessage(_ message: WKScriptMessage) {
        scanVideoFramesForTitlesIfNeeded()

        if let dict = message.body as? [String: Any],
           let data = dict["data"] as? [String: Any],
           let mediaPath = data["url"] as? String,
           let url = urlForStudioImmersiveView(ofMediaPath: mediaPath) {
            attemptStudioImmersiveViewLaunch(url)
        }
    }

    func handleNavigationAction(_ action: NavigationActionRepresentable) -> Bool {
        scanVideoFramesForTitlesIfNeeded()

        if let immersiveURL = urlForStudioImmersiveView(ofNavAction: action) {
            return attemptStudioImmersiveViewLaunch(immersiveURL)
        }
        return false
    }

    /// To be called in didFinishLoading delegate method of WKWebView, it scans through
    /// currently loaded page HTML content looking for video studio `iframe`s. It will extract
    /// `title` attribute value and keep a map of such values vs video src URL, to be used
    /// later to set immersive video player title. This mainly useful when triggering the player
    /// from a button that's internal to video-frame. (`Expand` button)
    func scanVideoFramesForTitles() {
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

    /// This would be effective when loading a page that has another loading stage
    /// to load the HTML content of video frames. Discussion topics as an example.
    private func scanVideoFramesForTitlesIfNeeded() {
        if videoFramesTitleMap.isEmpty {
            scanVideoFramesForTitles()
        }
    }

    // MARK: URL Resolving

    func urlForStudioImmersiveView(ofMediaPath mediaPath: String) -> URL? {
        guard
            let context,
            var urlComps = URLComponents(string: env.api.baseURL.absoluteString)
        else { return nil }

        var encodedQueryItems: [URLQueryItem] = [
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

        if let mediaURL = URL(string: mediaPath),
           let title = videoPlayerFrameTitle(forStudioMediaURL: mediaURL) {
            encodedQueryItems.append(
                URLQueryItem(
                    name: "title",
                    value: title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                )
            )
        }

        urlComps.path = "/\(context.pathComponent)/external_tools/retrieve"
        urlComps.percentEncodedQueryItems = encodedQueryItems

        return urlComps.url
    }

    func urlForStudioImmersiveView(ofNavAction action: NavigationActionRepresentable) -> URL? {
        guard action.isStudioImmersiveViewLinkTap, var url = action.request.url else {
            return nil
        }

        if url.containsQueryItem(named: "title") == false,
           let title = videoPlayerFrameTitle(forCanvasMediaURL: url) {
            url = url.appendingQueryItems(.init(name: "title", value: title))
        }

        if url.containsQueryItem(named: "embedded") == false {
            url = url.appendingQueryItems(.init(name: "embedded", value: "true"))
        }

        return url
    }

    func isImmersiveViewURLHandledDifferently(ofNavAction action: NavigationActionRepresentable) -> Bool {
        guard let url = action.request.url else { return false }
        return action.navigationType == .other
            && (action.targetInfoFrame?.isMainFrame ?? false) == true
            && url.immersiveViewType == .studio
            && context != nil
    }

    // MARK: Show Immersive View

    @discardableResult
    private func attemptStudioImmersiveViewLaunch(_ url: URL) -> Bool {
        guard let webView else { return false }

        if let controller = webView.linkDelegate?.routeLinksFrom {
            controller.pauseWebViewPlayback()
            env.router.show(
                StudioViewController(url: url),
                from: controller,
                options: .modal(.overFullScreen)
            )
            return true
        }
        return false
    }

    // MARK: Video Frame Title

    private func videoPlayerFrameTitle(forCanvasMediaURL url: URL) -> String? {
        let path = url.removingQueryAndFragment().absoluteString
        return videoFramesTitleMap.first(where: { path.hasPrefix($0.key) })?.value
    }

    private func videoPlayerFrameTitle(forStudioMediaURL mediaURL: URL) -> String? {
        if let mediaID = mediaURL.queryValue(for: "custom_arc_media_id"),
           let title = videoFramesTitleMap.first(where: { $0.key == mediaID })?.value {
            return title
        }

        if mediaURL.queryValue(for: "custom_arc_source_view_type") == "quiz_embed" {
            return String(localized: "Quiz", bundle: .core)
        }

        return nil
    }
}

// MARK: - WKNavigationAction Extensions

private extension NavigationActionRepresentable {

    var isStudioImmersiveViewLinkTap: Bool {
        guard let url = request.url else { return false }

        let isExpandTap = navigationType == .other
            && url.immersiveViewType == .canvasUpload
            && sourceInfoFrame.isMainFrame == false

        let isCanvasUploadDetailsLink = navigationType == .linkActivated
            && url.immersiveViewType == .canvasUpload
            && (targetInfoFrame?.isMainFrame ?? false) == false

        let isStudioEmbedDetailsLink = navigationType == .linkActivated
            && url.immersiveViewType == .studio
            && (targetInfoFrame?.isMainFrame ?? false) == false

        return isExpandTap || isCanvasUploadDetailsLink || isStudioEmbedDetailsLink
    }
}

// MARK: - URL Extensions

enum ImmersiveViewType {
    case canvasUpload
    case studio
}

private extension URL {

    var isImmersiveViewURL: Bool { immersiveViewType != nil }

    var immersiveViewType: ImmersiveViewType? {

        if path.contains("/media_attachments/") && path.hasSuffix("/immersive_view") {
            return .canvasUpload
        }

        let query = query()?.removingPercentEncoding ?? ""
        if path.hasSuffix("/external_tools/retrieve")
            && query.contains("custom_arc_launch_type=immersive_view") {
            return .studio
        }

        return nil
    }
}
