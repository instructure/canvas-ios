//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Foundation
@preconcurrency import mobile_offline_downloader_ios
import SwiftSoup
import Reachability

extension ModuleItem: OfflineDownloadTypeProtocol {
    public static func canDownload(entry: OfflineDownloaderEntry) -> Bool {
        guard let item = try? fromOfflineModel(entry.dataModel) else { return false }
        if case .externalTool = item.type {
            return true
        }
        if case .page = item.type {
            return true
        }
        if case .file = item.type {
            return true
        }
        return false
    }

    public static func getItem(with dataModel: OfflineStorageDataModel) async throws -> ModuleItem {
        try await withCheckedThrowingContinuation({ continuation in
            DispatchQueue.main.async {
                do {
                    let item = try fromOfflineModel(dataModel)
                    continuation.resume(returning: item)
                } catch {
                    if error.isCancelled {
                        continuation.resume(throwing: error)
                    }

                    continuation.resume(throwing: ModuleItemError.cantGetItem(data: dataModel, error: error))
                }
            }
        })
    }

    public static func prepareForDownload(entry: OfflineDownloaderEntry) async throws {
        let item = try await getItem(with: entry.dataModel)
        if case let .externalTool(toolID, url) = item.type {
            try await prepareLTI(entry: entry, toolID: toolID, sourceURL: url)
        } else if case let .page(url) = item.type {
            try await preparePage(entry: entry, url: url, courseID: item.courseID)
        } else if case let .file(fileId) = item.type {
            try await prepareFile(entry: entry, item: item, fileId: fileId)
        } else {
            entry.markAsUnsupported()
            throw ModuleItemError.unsupported(type: item.type?.label ?? "", id: item.id)
        }
    }

    @MainActor
    static func preparePage(entry: OfflineDownloaderEntry, url: String, courseID: String) async throws {
        let context = Context(.course, id: courseID)
        return try await withCheckedThrowingContinuation({[weak entry] continuation in
            var pages: Store<GetPage>?

            pages = AppEnvironment.shared.subscribe(GetPage(context: context, url: url)) {}

            pages?.refresh(force: true, callback: {[entry, pages] page in
                guard let entry = entry else { return }
                DispatchQueue.main.async {
                    if let body = page?.body {
                        if body.isEmpty {
                            entry.markAsServerError()
                            continuation.resume(throwing: ModuleItemError.brokenItem(data: entry.dataModel))
                        } else {
                            CoreWebView.cookieKeepAliveWebView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                                let fullHTML = CoreWebView().html(for: body)
                                entry.parts.removeAll()
                                entry.addHtmlPart(fullHTML, baseURL: page?.html_url.absoluteString, cookieString: cookies.cookieString)
                                continuation.resume()
                            }
                        }
                    } else if let error = pages?.error {
                        if error.isOfflineCancel {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(throwing: ModuleItemError.cantGetPage(data: entry.dataModel, error: error))
                        }
                    } else {
                        continuation.resume(throwing: ModuleItemError.cantGetPage(data: entry.dataModel, error: nil))
                    }
                }
            })
        })
    }

    public static func prepareFile(entry: OfflineDownloaderEntry, item: ModuleItem, fileId: String) async throws {
        guard let url = item.url,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            entry.markAsUnsupported()
            throw ModuleItemError.unsupported(type: item.type?.label ?? "", id: item.id)
        }

        let fileID = urlComponents.queryItems?.first(where: { $0.name == "preview" })?.value ?? fileId

        var context = Context(path: url.path)
        if let courseID = urlComponents.queryItems?.first(where: { $0.name == "courseID" })?.value {
            context = Context(.course, id: courseID)
        }

        return try await withCheckedThrowingContinuation({[weak entry] continuation in
            let files: Store<GetFile>? = AppEnvironment.shared.subscribe(GetFile(context: context, fileID: fileID)) {}
            files?.refresh(force: true, callback: {[entry] file in
                guard let entry = entry else { return }
                if let url = file?.url?.rawValue {
                    entry.parts.removeAll()
                    entry.addURLPart(url.absoluteString)
                    continuation.resume()
                } else if let error = files?.error {
                    if error.isOfflineCancel {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(throwing: ModuleItemError.cantGetFile(data: entry.dataModel, error: error))
                    }

                } else {
                    continuation.resume(throwing: ModuleItemError.cantGetFile(data: entry.dataModel, error: nil))
                }
            })
        })
    }

    static func getLtiURL(from entry: OfflineDownloaderEntry, toolID: String, url: URL) async throws -> URL {
        let item = try fromOfflineModel(entry.dataModel)
        let request = GetSessionlessLaunchURLRequest(
            context: .course(item.courseID),
            id: toolID,
            url: url,
            assignmentID: nil,
            moduleItemID: item.id,
            launchType: .module_item,
            resourceLinkLookupUUID: nil
        )

        let env = AppEnvironment.shared
        return try await withCheckedThrowingContinuation { continuation in
            let responseBlock: (APIGetSessionlessLaunchResponse?) -> Void = { response in
                guard let response = response else {
                    continuation.resume(throwing: ModuleItemError.wrongSession)
                    return
                }

                let url = response.url.appendingQueryItems(URLQueryItem(name: "platform", value: "mobile"))
                if response.name == "Google Apps" {
                    entry.markAsUnsupported()
                    continuation.resume(throwing: ModuleItemError.unsupported(type: item.type?.label ?? "", id: item.id))
                } else {
                    continuation.resume(returning: url)
                }
            }
            if url.path.hasSuffix("/external_tools/sessionless_launch") {
                env.api.makeRequest(url) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let data = data else { return continuation.resume(throwing: ModuleItemError.wrongSession) }
                    let response = try? APIJSONDecoder().decode(APIGetSessionlessLaunchResponse.self, from: data)
                    responseBlock(response)
                }
                return
            }
            env.api.makeRequest(request) { response, _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                responseBlock(response)
            }
        }
    }

    static func prepareLTI(entry: OfflineDownloaderEntry, toolID: String, sourceURL: URL, repeatCount: Int = 0) async throws {
        guard repeatCount < 3 else {
            throw ModuleItemError.cantPrepareLTI(data: entry.dataModel, error: ModuleItemError.retryCountLimitReached)
        }
        var extractor: OfflineHTMLDynamicsLinksExtractor?
        do {
            let url: URL = try await getLtiURL(from: entry, toolID: toolID, url: sourceURL)
            extractor = await OfflineHTMLDynamicsLinksExtractor(
                url: url,
                linksHandler: OfflineDownloadsManager.shared.config.linksHandler
            )
            try await extractor?.fetch()
            if let extractor = extractor,
                let latestURL = await extractor.latestRedirectURL,
                var html = await extractor.html {

                if shouldRetry(for: html, latestURL: latestURL) {
                    try await prepareLTI(entry: entry, toolID: toolID, sourceURL: sourceURL, repeatCount: repeatCount + 1)
                    return
                }
                if !isLTISupported(with: html, latestURL: latestURL) {
                    entry.markAsUnsupported()
                    let item = try fromOfflineModel(entry.dataModel)
                    throw ModuleItemError.unsupported(type: item.type?.label ?? "", id: item.id)
                }

                if isBrokenLTI(with: html, latestURL: latestURL, sourceURL: sourceURL) {
                    entry.markAsServerError()
                    throw ModuleItemError.brokenItem(data: entry.dataModel)
                }

                if isOyster(with: html, latestURL: latestURL) {
                    html = try changeOyster(html: html)
                }

                if isCoursePlayer(with: html, latestURL: latestURL) {
                    html = try changeCoursePlayer(html: html)
                }

                if html.contains(latestURL.absoluteString) {
                    let downloader = OfflineLinkDownloader()
                    let cookieString = await extractor.cookies().cookieString
                    downloader.additionCookies = cookieString
                    let ltiContents = try await downloader.contents(urlString: latestURL.absoluteString)
                    let html = try prepare(html: ltiContents)
                    entry.addHtmlPart(html, baseURL: latestURL.absoluteString, cookieString: cookieString)
                } else {
                    let html = try prepare(html: html)
                    let cookieString = await extractor.cookies().cookieString
                    entry.addHtmlPart(html, baseURL: latestURL.absoluteString, cookieString: cookieString)
                }
            } else {
                throw ModuleItemError.cantPrepareLTI(data: entry.dataModel, error: nil)
            }
        } catch {
            if error.isOfflineCancel {
                throw error
            }
            if let latestURL = await extractor?.latestRedirectURL, latestURL.scheme?.lowercased() == "voicethread" {
                entry.markAsUnsupported()
                let item = try fromOfflineModel(entry.dataModel)
                throw ModuleItemError.unsupported(type: item.type?.label ?? "", id: item.id)
            }
            throw ModuleItemError.cantPrepareLTI(data: entry.dataModel, error: error)
        }
    }

    static func isBrokenLTI(with html: String, latestURL: URL, sourceURL: URL) -> Bool {
        if latestURL.absoluteString.lowercased().contains("/error") {
            return true
        }

        if latestURL.absoluteString.lowercased().contains("/media-player") &&
            !isOyster(with: html, latestURL: latestURL) {
            return true
        }

        return false
    }

    static func isOyster(with html: String, latestURL: URL) -> Bool {
        if latestURL.absoluteString.lowercased().contains("/media-player") {
            let oysterPattern = "<script[^>]*oyster[^>]*>"
            if let oysterScripts = results(for: oysterPattern, in: html),
               !oysterScripts.isEmpty {
                return true
            }
        }
        return false
    }

    static func isCoursePlayer(with html: String, latestURL: URL) -> Bool {
        latestURL.absoluteString.lowercased().contains("/course-player")
    }

    static func isReport(with html: String, latestURL: URL) -> Bool {
        latestURL.absoluteString.lowercased().contains("/report")
    }

    static func isLTISupported(with html: String, latestURL: URL) -> Bool {
        // we can't download course player with multiple cards
        if isCoursePlayer(with: html, latestURL: latestURL) {
            let regexPattern = "<div[^>]*NavigationItem[^>]*>"
            if let matches = results(for: regexPattern, in: html) {
                if !matches.isEmpty {
                    return false
                } else if let errors = results(for: "<div[^>]*ErrorStyles[^>]*>", in: html),
                    !errors.isEmpty {
                    return false
                }
            }
        }
        if isReport(with: html, latestURL: latestURL) {
            return false
        }

        if latestURL.absoluteString.lowercased().contains("/dashboard/") {
            return false
        }
        return true
    }

    static func results(for regexp: String, in html: String) -> [NSTextCheckingResult]? {
        do {
            let regex = try NSRegularExpression(pattern: regexp, options: [])

            return regex.matches(in: html, options: [], range: NSRange(location: 0, length: html.count))
        } catch {
            return nil
        }
    }

    static func shouldRetry(for html: String, latestURL: URL) -> Bool {
        if latestURL.absoluteString.lowercased().contains("3rd-cookie-check/checkpage.html") {
            return true
        }

        if isOyster(with: html, latestURL: latestURL) {
            let regexPattern = "<div[^>]*oyster-wrapper[^>]*>"
            if let matches = results(for: regexPattern, in: html),
                matches.isEmpty {
                return true
            }
        }

        return false
    }

    static func prepare(html: String) throws -> String {
        let document = try SwiftSoup.parse(html)
        let videoTags = try document.getElementsByTag("video")
        for tag in videoTags where tag.hasClass("vjs-tech") {
            try tag.attr("controls", "true")
            try tag.attr("width", "100%")
            try tag.removeAttr("crossorigin")
        }
        return try document.html()
    }

    static func coursePlayerTranscriptionScript() -> String {
        """
            <script>
                function onTranscriptClick() {
                    console.log("asd");

                    var display = document.getElementById("transcript").style.display;
                    var classList = document.getElementsByClassName("icon")[0].classList;

                    if (display == "none") {
                        document.getElementById("transcript").style.display = "block";
                        document.getElementsByTagName("button")[0].style.borderRadius = "0.375rem 0.375rem 0px 0px";
                        classList.remove("icon--caret-right");
                        classList.add("icon--caret-down");

                    } else {
                        document.getElementById("transcript").style.display = "none";
                        document.getElementsByTagName("button")[0].style.borderRadius = "0.375rem";
                        classList.remove("icon--caret-down");
                        classList.add("icon--caret-right");
                    }
                }
            </script>
        """
    }

    static func coursePlayerTranscriptionPattern() -> String {
        """
            <div style="padding: 1.4375rem;box-sizing: inherit;">
                <button aria-expanded="true" onclick="onTranscriptClick()"
                        style="
                            display: block;
                            margin-top: 1.4375rem;
                            border: 0.0625rem solid rgb(204, 204, 204);
                            border-radius: 0.375rem;
                            padding: 0px;
                            width: 100%;
                            text-align: left;
                            background-color: transparent;
                            color: inherit;
                            font-size: inherit;
                            line-height: inherit;
                            font: inherit;
                            cursor: default;
                ">
                    <span style="position: relative;display: inline-block;margin-left: 1rem;width: 0.75rem;top: 0.0625rem;">
                        <span class="icon icon--caret-right" aria-hidden="true"></span>
                    </span>
                    <h5 style="margin: 1rem 0px;display: inline-block;">Transcript</h5>
                </button>

                <div style="width: 100%;">
                    <div id="transcript" style="
                        display: none;
                        padding-top: 5px;
                        border-left: 0.0625rem solid rgb(204, 204, 204);
                        border-right: 0.0625rem solid rgb(204, 204, 204);
                        border-bottom: 0.0625rem solid rgb(204, 204, 204);
                        border-radius: 0px 0px 0.375rem 0.375rem;
                        background: initial;color: rgb(119, 119, 119);
                        font-size: 0.875rem;
                    ">
                        <div style="margin: 1rem;">
                            ###TRANSCRIPT###
                        </div>
                    </div>
                </div>
            </div>
        """
    }

    static func changeCoursePlayer(html: String) throws -> String {
        let document = try SwiftSoup.parse(html)
        // remove scripts
        let scripts = try document.getElementsByTag("script")
        try scripts.forEach {
            try $0.remove()
        }

        let videoTags = try document.getElementsByTag("video")
        if let video = videoTags.first() {
            // It's a video card
            let newContent = Element(Tag("div"), "")
            let transcriptions = try document.getElementsByClass("p3sdk-interactive-transcript-content")
            // Add video to new content
            try newContent.append(try video.outerHtml())

            if let transcription = transcriptions.first() {
                // Add transcription to content
                try document.head()?.append(coursePlayerTranscriptionScript())
                let html = coursePlayerTranscriptionPattern()
                    .replacingOccurrences(of: "###TRANSCRIPT###", with: try transcription.html())
                try newContent.append(html)
            }
            // clear body
            try document.body()?.children().forEach {
                try $0.remove()
            }
            try document.body()?.appendChild(newContent)
        }

        return try document.html()
    }

    static func changeOyster(html: String) throws -> String {
        let document = try SwiftSoup.parse(html)
        let newContent = Element(Tag("div"), "")
        // search video and move it to body begin
        let videoTags = try document.getElementsByTag("video")
        for tag in videoTags {
            try newContent.append(try tag.outerHtml())
        }
        // search transcription remove copy button and move it under video
        let transcriptionContainer = Element(Tag("div"), "")
        try transcriptionContainer.attr("style", "padding:20px;")
        let transcriptions = try document.getElementsByClass("oyster-grid-transcript")
        for transcription in transcriptions {
            let buttons = try transcription.getElementsByTag("button")
            for button in buttons {
                try button.remove()
            }

            let containers = try transcription.getElementsByClass("transcripts-container")
            for container in containers {
                try container.attr("class", "")
            }

            try transcriptionContainer.append(try transcription.outerHtml())

        }
        try newContent.append(try transcriptionContainer.outerHtml())
        // clean all body
        if let children = document.body()?.children() {
            try children.forEach { child in
                try child.remove()
            }
        }

        // remove scripts
        let scripts = try document.getElementsByTag("script")
        try scripts.forEach {
            try $0.remove()
        }

        // insert content
        try document.body()?.insertChildren(0, [newContent])

        return try document.html()
    }

    public func downloaderEntry() throws -> OfflineDownloaderEntry {
        let model = try self.toOfflineModel()
        return OfflineDownloaderEntry(dataModel: model, parts: [])
    }

    public static func isCritical(error: Error) -> Bool {
        switch error {
        case ModuleItemError.wrongSession,
            ModuleItemError.unsupported,
            ModuleItemError.cantGetItem,
            ModuleItemError.cantPrepareLTI,
            ModuleItemError.cantGetPage,
            ModuleItemError.cantGetFile,
            ModuleItemError.brokenItem,
            OfflineEntryPartDownloaderError.cantDownloadHTMLPart:
            return true
        default:
            return false
        }

    }

    public static func replaceHTML(tag: String?) async -> String? {
        await DownloaderClient.replaceHtml(for: tag)
    }
}

extension ModuleItem {
    enum ModuleItemError: Error, LocalizedError {
        case wrongSession
        case unsupported(type: String, id: String)
        case cantGetItem(data: OfflineStorageDataModel, error: Error)
        case cantPrepareLTI(data: OfflineStorageDataModel, error: Error?)
        case cantGetPage(data: OfflineStorageDataModel, error: Error?)
        case cantGetFile(data: OfflineStorageDataModel, error: Error?)
        case retryCountLimitReached
        case brokenItem(data: OfflineStorageDataModel)

        var errorDescription: String? {
            switch self {
            case .wrongSession:
                return "Can't get sessionless launch."
            case .brokenItem(let data):
                return "Item is broken. Data: \(data.json)"
            case let .unsupported(type, id):
                return "Unsupported type. Type: \(type), id: \(id)"
            case let .cantGetItem(data, error):
                return "Can't get item for data: \(data.json). Error: \(error)"
            case let .cantPrepareLTI(data, error):
                if let error = error {
                    return "Can't get item for data: \(data.json). Error: \(error)"
                }
                return "Can't get item for data: \(data.json)."
            case let .cantGetPage(data, error):
                if let error = error {
                    return "Can't get page for data: \(data.json). Error: \(error)"
                }
                return "Can't get page for data: \(data.json)."
            case let .cantGetFile(data, error):
                if let error = error {
                    return "Can't get file for data: \(data.json). Error: \(error)"
                }
                return "Can't get file for data: \(data.json)."
            case .retryCountLimitReached:
                return "Max retry count was reached"

            }
        }
    }
}
