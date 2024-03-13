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

    private let loginSession: LoginSession
    private let interactor: HTMLDownloadInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(loginSession: LoginSession, downloadInteractor: HTMLDownloadInteractor) {
        self.loginSession = loginSession
        self.interactor = downloadInteractor

        self.imageRegex = (try? NSRegularExpression(pattern: "<img[^>]*src=\"([^\"]*)\"[^>]*>")) ?? NSRegularExpression()
        self.fileLinkRegex = (try? NSRegularExpression(pattern: "<a[^>]*class=\"instructure_file_link[^>]*href=\"([^\"]*)\"[^>]*>")) ?? NSRegularExpression()
        self.internalFileRegex = (try? NSRegularExpression(pattern: ".*\(loginSession.baseURL).*files/(\\d+)")) ?? NSRegularExpression()
    }

    func parse(_ content: String) -> AnyPublisher<String, Error> {
        let imageURLs = findImageMatches(content)
        return imageURLs.publisher
            .flatMap { url in
                return self.interactor.download(url)
                    .map {
                        return (url, $0)
                    }
            }
            .flatMap { [unowned self] (url, result) in
                return self.interactor.save(result)
                    .map {
                        return (url, $0)
                    }
            }
            .collect()
            .map { [content] urls in
                var newContent = content
                urls.forEach { (originalURL, localURL) in
                    newContent = newContent.replacingOccurrences(of: originalURL.absoluteString, with: localURL.lastPathComponent)
                }
                return newContent
            }
            .eraseToAnyPublisher()
    }

    func findImageMatches(_ content: String) -> [URL] {
        imageRegex
            .matches(in: content, range: NSRange(location: 0, length: content.count))
            .compactMap { match in
                if let wholeRange = Range(match.range(at: 1), in: content) {
                    let url = String(content[wholeRange])
                    return url
                }
                return ""
            }
//            .compactMap { result in
//                let rawString = NSString(string: content).substring(with: result.range)
//                let groupedAttributes = rawString.split(separator: " ")
//                let url = groupedAttributes
//                    .last(where: {$0.contains("src=")})?
//                    .replacingOccurrences(of: "src=\"", with: "")
//                    .replacingOccurrences(of: "\"", with: "")
//                return url
//            }
            .compactMap { rawURL in
                URL(string: rawURL)
            }
    }

}
