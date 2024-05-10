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

import CoreData
import Combine

public protocol HTMLParser {
    var sessionId: String { get }
    var sectionName: String { get }
    func parse(_ content: String, resourceId: String, courseId: String, baseURL: URL?) -> AnyPublisher<String, Error>
}

public class HTMLParserLive: HTMLParser {
    public var sectionName: String {
        interactor.sectionName
    }
    public let sessionId: String

    private let imageRegex: NSRegularExpression
    private let relativeURLRegex: NSRegularExpression
    private let interactor: HTMLDownloadInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(sessionId: String, downloadInteractor: HTMLDownloadInteractor) {
        self.sessionId = sessionId
        self.interactor = downloadInteractor

        self.imageRegex = (try? NSRegularExpression(pattern: "<img[^>]*src=\"([^\"]*)\"[^>]*>")) ?? NSRegularExpression()
        self.relativeURLRegex = (try? NSRegularExpression(pattern: "<.+(src|href)=\"(.+((\\.|\\/)\\.+)*)\".*>")) ?? NSRegularExpression()
    }

    public func parse(_ content: String, resourceId: String, courseId: String, baseURL: URL? = nil) -> AnyPublisher<String, Error> {
        let imageURLs = findRegexMatches(content, pattern: imageRegex)
        let relativeURLs = findRegexMatches(content, pattern: relativeURLRegex, groupCount: 2).filter { url in url.host ==  nil }
        let rootURL = getRootURL(courseId: courseId, resourceId: resourceId)

        return imageURLs.publisher
            .flatMap(maxPublishers: .max(5)) { [interactor] url in // Download images to local Documents folder, return the (original link - local link) tuple
                return interactor.download(url)
                    .map {
                        return (url, $0)
                    }
            }
            .flatMap { [interactor] (url, downloadResult) in // Save the data to local file, return the (original link - local link) tuple
                let (tempURL, fileName) = downloadResult
                return interactor.copy(tempURL, fileName: fileName, courseId: courseId, resourceId: resourceId)
                    .map {
                        return (url, $0)
                    }
            }
            .collect() // Wait for all image download to finish and handle as an array
            .map { [content] urls in // Replace relative links with baseURL based absolute links. The baseURL in the webviews will be different from the original one to load the local images
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
                    let newURL = "\(localURL.path)"
                    newContent = newContent.replacingOccurrences(of: originalURL.absoluteString, with: newURL)
                }
                return newContent
            }
            .flatMap { [interactor, rootURL] content in // Save html parsed html string content to file. It will be loaded in offline mode)
                return interactor.saveBaseContent(content: content, folderURL: rootURL)
            }
            .eraseToAnyPublisher()
    }

    private func findRegexMatches(_ content: String, pattern: NSRegularExpression, groupCount: Int = 1) -> [URL] {
        pattern
            .matches(in: content, range: NSRange(location: 0, length: content.count))
            .compactMap { match in
                if let wholeRange = Range(match.range(at: groupCount), in: content) {
                    var url = String(content[wholeRange])
                    if let index = url.firstIndex(of: "\"") { // Remove Swift's wrong Regex Group handling
                        url = String(url.prefix(upTo: index))
                    }
                    return url
                }
                return ""
            }
            .compactMap { rawURL in
                URL(string: rawURL)
            }
    }

    private func getRootURL(courseId: String, resourceId: String) -> URL {
        return URL.Directories.documents.appendingPathComponent(
            URL.Paths.Offline.courseSectionFolder(
                sessionId: sessionId,
                courseId: courseId,
                sectionName: sectionName
            )
        )
        .appendingPathComponent("\(sectionName)-\(resourceId)")
    }
}

public extension Publisher where Output: Collection, Output.Element: NSManagedObject, Failure == Error {
    func parseHtmlContent<T>(
        attribute keyPath: ReferenceWritableKeyPath<Output.Element, T>,
        id: ReferenceWritableKeyPath<Output.Element, String>,
        courseId: String,
        baseURLKey: ReferenceWritableKeyPath<Output.Element, URL?>? = nil,
        htmlParser: HTMLParser
    ) -> AnyPublisher<[Output.Element], Error> {
        return self
            .flatMap { dataArray in
                Publishers.Sequence(sequence: dataArray)
                    .setFailureType(to: Error.self)
                    .flatMap { element -> AnyPublisher<Self.Output.Element, Error> in
                        if let value = element[keyPath: keyPath] as? String { // Parse only non null attributes
                            let resourceId = element[keyPath: id]
                            var baseURL: URL?
                            if let baseURLKey {
                                baseURL = element[keyPath: baseURLKey]
                            }
                            return htmlParser.parse(value, resourceId: resourceId, courseId: courseId, baseURL: baseURL)
                                .map { _ in element }
                                .eraseToAnyPublisher()
                        } else {
                            return Just(element)
                                .setFailureType(to: Error.self)
                                .eraseToAnyPublisher()
                        }
                    }
                    .collect()
            }
            .eraseToAnyPublisher()
    }
}
