//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Combine

public class HTMLParser {

    private let imageRegex: NSRegularExpression
    private let fileLinkRegex: NSRegularExpression
    private let internalFileRegex: NSRegularExpression
    private let relativeURLRegex: NSRegularExpression

    private let loginSession: LoginSession
    private let interactor: HTMLDownloadInteractor
    private var subscriptions = Set<AnyCancellable>()
    public let prefix: String

    public var sessionId: String {
        loginSession.uniqueID
    }

    public var sectionName: String {
        interactor.sectionName
    }

    init(loginSession: LoginSession, downloadInteractor: HTMLDownloadInteractor, prefix: String = "") {
        self.loginSession = loginSession
        self.interactor = downloadInteractor
        self.prefix = prefix

        self.imageRegex = (try? NSRegularExpression(pattern: "<img[^>]*src=\"([^\"]*)\"[^>]*>")) ?? NSRegularExpression()
        self.fileLinkRegex = (try? NSRegularExpression(pattern: "<a[^>]*class=\"instructure_file_link[^>]*href=\"([^\"]*)\"[^>]*>")) ?? NSRegularExpression()
        self.internalFileRegex = (try? NSRegularExpression(pattern: ".*\(loginSession.baseURL).*files/(\\d+)")) ?? NSRegularExpression()

        self.relativeURLRegex = (try? NSRegularExpression(pattern: "^(?:[a-z+]+:)?//")) ?? NSRegularExpression()
    }

    func parse(_ content: String, resourceId: String, courseId: String, baseURL: URL? = nil) -> AnyPublisher<String, Error> {
        let imageURLs = findRegexMatches(content, pattern: imageRegex)
        let relativeURLs = findRegexMatches(content, pattern: relativeURLRegex)
        let rootURL = getRootURL(courseId: courseId, prefix: prefix, resourceId: resourceId)

        return imageURLs.publisher
            .flatMap(maxPublishers: .max(5)) { url in // Download images to local Documents folder, return the (original link - content data) tuple
                return self.interactor.download(url)
                    .map {
                        return (url, $0)
                    }
            }
            .receive(on: DispatchQueue.main) // Receive on main, because of the file operations
            .flatMap(maxPublishers: .max(5)) { [interactor] (url, result) in // Save the data to local file, return the (original link - local link) tuple
                return interactor.save(result, courseId: courseId, prefix: "\(self.prefix)-\(resourceId)")
                    .map {
                        return (url, $0)
                    }
            }
            .collect() // Wait for all image download to finish and handle as an array
            .map { [content] urls in // Replace relative links with baseULR based absolute links. The baseURL in the webviews will be different from the original one to load the local images
                var newContent = content
                relativeURLs.forEach { relativeURL in
                    if let baseURL {
                        let newURL = baseURL.appendingPathComponent(relativeURL.path)
                        newContent = newContent.replacingOccurrences(of: relativeURL.absoluteString, with: newURL.absoluteString)
                    }
                }
                return (newContent, urls)
            }
            .map { (content, urls) in // Replace all original links with the local ones, return the replaced string content
                var newContent = content
                urls.forEach { (originalURL, localURL) in
                    let newURL = "\(localURL.lastPathComponent)"
                    newContent = newContent.replacingOccurrences(of: originalURL.absoluteString, with: newURL)
                }
                return newContent
            }
            .flatMap { [interactor, rootURL] content in // Save html parsed html string content to file. It will be loaded in offline mode
                return interactor.saveBaseContent(content: content, folderURL: rootURL)
            }
            .eraseToAnyPublisher()
    }

    private func findRegexMatches(_ content: String, pattern: NSRegularExpression) -> [URL] {
        pattern
            .matches(in: content, range: NSRange(location: 0, length: content.count))
            .compactMap { match in
                if let wholeRange = Range(match.range(at: 1), in: content) {
                    let url = String(content[wholeRange])
                    return url
                }
                return ""
            }
            .compactMap { rawURL in
                URL(string: rawURL)
            }
    }

    private func getRootURL(courseId: String, prefix: String, resourceId: String) -> URL {
        return URL.Directories.documents.appendingPathComponent(
            URL.Paths.Offline.courseSectionFolder(
                sessionId: loginSession.uniqueID,
                courseId: courseId,
                sectionName: sectionName
            )
        )
        .appendingPathComponent("\(prefix)-\(resourceId)")
    }

}
