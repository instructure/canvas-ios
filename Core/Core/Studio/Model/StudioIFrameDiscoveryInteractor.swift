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

import Combine

public typealias StudioIFramesByLocation = [URL: [StudioIFrame]]

public class StudioIFrameDiscoveryInteractor {
    private let studioHtmlParser: StudioHTMLParserInteractor

    public init(studioHtmlParser: StudioHTMLParserInteractor) {
        self.studioHtmlParser = studioHtmlParser
    }

    public func discoverStudioIFrames(
        in offlineDirectory: URL,
        courseIDs: [String]
    ) -> AnyPublisher<StudioIFramesByLocation, Never> {
        Just(offlineDirectory)
            .map { offlineDirectory in
                let coursePaths = courseIDs.map { "course-\($0)"}
                return FileManager
                    .default
                    .allFiles(withExtension: "html", inDirectory: offlineDirectory)
                    .filter { url in
                        for coursePath in coursePaths where url.absoluteString.contains(coursePath) {
                            return true
                        }
                        return false
                    }
            }
            .flatMap { htmls in
                Publishers.Sequence(sequence: htmls)
            }
            .compactMap { [studioHtmlParser] htmlURL -> (URL, [StudioIFrame]) in
                let iframes = studioHtmlParser.extractStudioIFrames(htmlLocation: htmlURL)
                return (htmlURL, iframes)
            }
            .collect()
            .map {
                var result: StudioIFramesByLocation = [:]

                for (url, iframes) in $0 {
                    if iframes.isEmpty {
                        continue
                    }
                    result[url] = iframes
                }

                return result
            }
            .eraseToAnyPublisher()
    }
}
