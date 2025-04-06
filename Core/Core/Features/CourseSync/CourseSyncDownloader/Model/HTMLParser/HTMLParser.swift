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
    var sectionName: String { get }
    func parse(_ content: String, resourceId: String, courseId: CourseSyncID, baseURL: URL?) -> AnyPublisher<String, Error>
    func downloadAttachment(_ url: URL, courseId: CourseSyncID, resourceId: String) -> AnyPublisher<String, Error>
}

public class HTMLParserLive: HTMLParser {
    public var sectionName: String {
        interactor.sectionName
    }

    private let imageRegex: NSRegularExpression
    private let fileRegex: NSRegularExpression
    private let relativeURLRegex: NSRegularExpression
    private let interactor: HTMLDownloadInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(downloadInteractor: HTMLDownloadInteractor) {
        self.interactor = downloadInteractor

        self.imageRegex = (try? NSRegularExpression(pattern: "<img[^>]*src=\"([^\"]*)\"[^>]*>")) ?? NSRegularExpression()
        self.fileRegex = (try? NSRegularExpression(pattern: "<a[^>]*class=\"instructure_file_link[^>]*href=\"([^\"]*)\"[^>]*>")) ?? NSRegularExpression()
        self.relativeURLRegex = (try? NSRegularExpression(pattern: "<.+(src|href)=\"(.+((\\.|\\/)\\.+)*)\".*>")) ?? NSRegularExpression()
    }

    public func downloadAttachment(_ url: URL, courseId: CourseSyncID, resourceId: String) -> AnyPublisher<String, Error> {
        return Just(url)
            .setFailureType(to: Error.self)
            .flatMap { [interactor] url in
                interactor.downloadFile(url, courseId: courseId, resourceId: resourceId)
            }
            .eraseToAnyPublisher()
    }

    public func parse(_ content: String, resourceId: String, courseId: CourseSyncID, baseURL: URL? = nil) -> AnyPublisher<String, Error> {
        let imageURLs = findRegexMatches(content, pattern: imageRegex)
        let fileURLs = Array(Set(findRegexMatches(content, pattern: fileRegex)))
        let relativeURLs = findRegexMatches(content, pattern: relativeURLRegex, groupCount: 2).filter { url in url.host ==  nil }
        let rootURL = getRootURL(courseId: courseId, resourceId: resourceId)

        print()
        print("ROOT URL:")
        print(baseURL)
        print(rootURL)

        let fileParser: AnyPublisher<[(URL, String)], Error> = fileURLs.publisher // Download the files to local Documents folder, return the (original link - local link) tuple
            .flatMap(maxPublishers: .max(5)) { url in // Replace File Links with valid access urls
                if url.pathComponents.contains("files") && !url.containsQueryItem(named: "verifier") {
                    let fileId = url.pathComponents[(url.pathComponents.firstIndex(of: "files") ?? 0) + 1]
                    let context = Context(url: url)
                    return ReactiveStore(
                        useCase: GetFile(context: context, fileID: fileId),
                        environment: courseId.env
                    )
                    .getEntities(ignoreCache: false)
                    .map { files in
                        (files.first?.url ?? url, url)
                    }
                    .eraseToAnyPublisher()
                } else if url.pathComponents.contains("files") {
                    if !url.pathComponents.contains("download") {
                        return Just((url.appendingPathComponent("download"), url)).setFailureType(to: Error.self).eraseToAnyPublisher()
                    } else {
                        return Just((url, url)).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }
                } else {
                    return Just((url, url)).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
            }
            .flatMap { [interactor] (fileURL, originalURL) in
                return interactor.downloadFile(fileURL, courseId: courseId, resourceId: resourceId)
                    .map {
                        return (originalURL, $0)
                    }
            }
            .collect()
            .eraseToAnyPublisher()

        let imageParser: AnyPublisher<[(URL, String)], Error> =  imageURLs.publisher
            .flatMap(maxPublishers: .max(5)) { url in // Replace File Links with valid access urls
                if url.pathComponents.contains("files") && !url.containsQueryItem(named: "verifier") {
                    let fileId = url.pathComponents[(url.pathComponents.firstIndex(of: "files") ?? 0) + 1]
                    let context = Context(url: url)
                    return ReactiveStore(
                        useCase: GetFile(context: context, fileID: fileId),
                        environment: courseId.env
                    )
                    .getEntities(ignoreCache: false)
                    .map { files in
                        (files.first?.url ?? url, url)
                    }
                    .eraseToAnyPublisher()
                } else {
                    return Just((url, url)).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
            }
            .flatMap { [interactor] (fileURL, originalURL) in // Download images to local Documents folder, return the (original link - local link) tuple
                return interactor.download(
                    fileURL,
                    courseId: courseId,
                    resourceId: resourceId,
                    documentsDirectory: URL.Directories.documents
                )
                    .map {
                        return (originalURL, $0)
                    }

            }
            .collect() // Wait for all image download to finish and handle as an array
            .eraseToAnyPublisher()

        return Publishers.Zip(
            fileParser,
            imageParser
        )
        .map { (fileURLs, imageURLs) in
            return fileURLs + imageURLs
        }
        .map { [content] urls in
            // Replace relative path links with baseURL based absolute links. This is
            // to normalize all url's for the next step that works with absolute URLs.
            var newContent = content
            relativeURLs.forEach { relativeURL in
                if let baseURL {
                    let newURL = baseURL.appendingPathComponent(relativeURL.path)
                    newContent = newContent.replacingOccurrences(of: relativeURL.absoluteString, with: newURL.absoluteString)
                }
            }
            return (newContent, urls)
        }
        .map { (content: String, urls: [(URL, String)]) in
            // Replace all original links with the local ones, return the replaced string content
            var newContent = content
            urls.forEach { (originalURL, offlineURL) in
                newContent = newContent.replacingOccurrences(of: originalURL.absoluteString, with: offlineURL)
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

    private func getRootURL(courseId: CourseSyncID, resourceId: String) -> URL {
        return URL.Directories.documents.appendingPathComponent(
            URL.Paths.Offline.courseSectionFolder(
                sessionId: courseId.env.currentSession?.uniqueID ?? "",
                courseId: courseId.value,
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
        courseId: CourseSyncID,
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

    func parseAttachment(
        attribute url: ReferenceWritableKeyPath<Output.Element, File?>,
        topicId: String,
        courseId: CourseSyncID,
        htmlParser: HTMLParser
    ) -> AnyPublisher<[Output.Element], Error> {
        return self
            .flatMap { dataArray in
                return Publishers.Sequence(sequence: dataArray)
                    .setFailureType(to: Error.self)
                    .flatMap { element -> AnyPublisher<Self.Output.Element, Error> in
                        if let value = element[keyPath: url], let downloadURL = value.url { // Parse only non null attributes
                            return htmlParser.downloadAttachment(downloadURL, courseId: courseId, resourceId: topicId)
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

    func parseAttachment(
        attribute url: ReferenceWritableKeyPath<Output.Element, Set<File>?>,
        id: ReferenceWritableKeyPath<Output.Element, String>,
        courseId: CourseSyncID,
        htmlParser: HTMLParser
    ) -> AnyPublisher<[Output.Element], Error> {
        return self
            .flatMap { dataArray in
                Publishers.Sequence(sequence: dataArray)
                    .setFailureType(to: Error.self)
                    .flatMap { element -> AnyPublisher<Self.Output.Element, Error> in
                        if let values = element[keyPath: url] { // Parse only non null attributes
                            let resourceId = element[keyPath: id]
                            return values.publisher.flatMap { file in
                                if let downloadURL = file.url {
                                    return htmlParser.downloadAttachment(downloadURL, courseId: courseId, resourceId: resourceId)
                                        .eraseToAnyPublisher()
                                } else {
                                    return Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
                                }
                            }
                            .collect()
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

extension Publisher where Output: Collection, Output.Element: DiscussionEntry, Failure == Error {
    func parseRepliesHtmlContent(courseId: CourseSyncID, topicId: String, htmlParser: HTMLParser) -> AnyPublisher<[DiscussionEntry], Error> {
        return self.flatMap { entries in
            Publishers.Sequence(sequence: entries)
                .setFailureType(to: Error.self)
                .flatMap { entry in
                    Publishers.Sequence(sequence: entry.replies)
                        .setFailureType(to: Error.self)
                }
                .flatMap { entry in
                    return htmlParser.parse(entry.message ?? "", resourceId: entry.id, courseId: courseId, baseURL: nil).map { return (entry, $0) }
                }
                .flatMap { (entry: DiscussionEntry, newContent: String) in
                    entry.message = newContent
                    return Just(entry.replies)
                        .setFailureType(to: Error.self)
                        .parseRepliesHtmlContent(courseId: courseId, topicId: topicId, htmlParser: htmlParser)
                        .parseAttachment(attribute: \.attachment, topicId: topicId, courseId: courseId, htmlParser: htmlParser)
                        .map { return (entry, $0) }
                }
                .map { (entry: DiscussionEntry, newReplies: [DiscussionEntry]) -> DiscussionEntry in
                    entry.replies = newReplies
                    return entry
                }
                .collect()
        }
        .eraseToAnyPublisher()
    }
}
