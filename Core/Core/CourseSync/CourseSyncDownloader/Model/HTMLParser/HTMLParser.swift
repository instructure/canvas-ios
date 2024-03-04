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

class HTMLParser {

    private let imageRegex: NSRegularExpression
    private let fileLinkRegex: NSRegularExpression
    private let internalFileRegex: NSRegularExpression

    private let loginSession: LoginSession
    private let interactor: HTMLDownloadInteractor
    private var subscriptions = Set<AnyCancellable>()

    init(loginSession: LoginSession, downloadInteractor: HTMLDownloadInteractor) {
        self.loginSession = loginSession
        self.interactor = downloadInteractor

        self.imageRegex = try! NSRegularExpression(pattern: "<img[^>]*src=\"([^\"]*)\"[^>]*>")
        self.fileLinkRegex = try! NSRegularExpression(pattern: "<a[^>]*class=\"instructure_file_link[^>]*href=\"([^\"]*)\"[^>]*>")
        self.internalFileRegex = try! NSRegularExpression(pattern: ".*\(loginSession.baseURL).*files/(\\d+)")
    }
    
    func parse(_ content: String) -> PassthroughSubject<String, Error> {
        let resultValue = PassthroughSubject<String, Error>()
        let imageURLs = findImageMatches(content)
        imageURLs.publisher
            .flatMap { url in
                self.interactor.download(url)
                    .replaceError(with: (data: Data(), response: URLResponse()))
                    .map {
                        (url, $0)
                    }
            }
            .flatMap { [unowned self] (url, result) in
                self.interactor.save(result)
                    .map {
                        (url, $0)
                    }
            }
            .collect()
            .sink(receiveCompletion: { result in
                switch result {
                case .failure:
                    print()
                case .finished:
                    break
                }
            }, receiveValue: { [content] urls in
                var result = content
                urls.forEach { (originalUrl, localUrl) in
                    result = result.replacingOccurrences(of: originalUrl.absoluteString, with: localUrl.absoluteString)
                }
                resultValue.send(result)
            })
            .store(in: &subscriptions)

        return resultValue
    }

    func findImageMatches(_ content: String) -> [URL] {
        imageRegex
            .matches(in: content, range: NSMakeRange(0, content.count))
            .compactMap { result in
                let rawString = NSString(string: content).substring(with: result.range)
                let groupedAttributes = rawString.split(separator: " ")
                let url = groupedAttributes
                    .last(where: {$0.contains("src=")})?
                    .replacingOccurrences(of: "src=\"", with: "")
                    .replacingOccurrences(of: "\"", with: "")
                return url
            }
            .compactMap { rawURL in
                URL(string: rawURL)
            }
    }

}
