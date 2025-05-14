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
import Foundation

public typealias StudioIFramesByLocation = [URL: [StudioIFrame]]

public protocol StudioIFrameDiscoveryInteractor {

    func discoverStudioIFrames(
        courseID: CourseSyncID
    ) -> AnyPublisher<StudioIFramesByLocation, Never>
}

public class StudioIFrameDiscoveryInteractorLive: StudioIFrameDiscoveryInteractor {
    private let studioHtmlParser: StudioHTMLParserInteractor
    private let envResolver: CourseSyncEnvironmentResolver

    public init(studioHtmlParser: StudioHTMLParserInteractor, envResolver: CourseSyncEnvironmentResolver) {
        self.studioHtmlParser = studioHtmlParser
        self.envResolver = envResolver
    }

    public func discoverStudioIFrames(
        courseID: CourseSyncID
    ) -> AnyPublisher<StudioIFramesByLocation, Never> {

        let coursePath = "course-\(courseID.value)"
        let htmls = FileManager
            .default
            .allFiles(withExtension: "html", inDirectory: envResolver.offlineDirectory(for: courseID))
            .filter { $0.absoluteString.contains(coursePath) }
        return Publishers
            .Sequence(sequence: htmls)
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
