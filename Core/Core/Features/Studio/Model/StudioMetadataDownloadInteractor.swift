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

public protocol StudioMetadataDownloadInteractor {

    /// - parameters:
    ///   - api: The API instance pointing to the Studio API.
    func fetchStudioMediaItems(
        api: API,
        courseID: String
    ) -> AnyPublisher<[APIStudioMediaItem], Error>
}

class StudioMetadataDownloadInteractorLive: StudioMetadataDownloadInteractor {

    func fetchStudioMediaItems(
        api: API,
        courseID: String
    ) -> AnyPublisher<[APIStudioMediaItem], Error> {
        let request = GetStudioCourseMediaRequest(courseId: courseID)
        return api
            .makeRequest(request)
            .catch(Self.replaceNotFoundErrorWithEmptyResponse)
            .map(\.body)
            .eraseToAnyPublisher()
    }

    private static func replaceNotFoundErrorWithEmptyResponse(
        _ error: Error
    ) -> AnyPublisher<(body: [APIStudioMediaItem], urlResponse: HTTPURLResponse?), Error> {
        if error.isNotFound {
            return Just((body: [], urlResponse: nil))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return Fail(error: error).eraseToAnyPublisher()
    }
}
