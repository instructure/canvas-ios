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

import Combine

/**
 File viewing related page view events and API calls don't trigger a file access report entry for the user in a course.
 This class mimics a file access like it was opened in a browser which successfully registers a file access. The file
 is not actually downloaded just its HTTP HEAD is requested.
 */
public class FileAccessReportInteractor {
    private let api: API
    private let webSessionRequest: GetWebSessionRequest

    public init(context: Context, fileID: String, api: API) {
        let path = "\(context.pathComponent)/files/\(fileID)"
        let reportURL = api.baseURL.appendingPathComponent(path)
        self.webSessionRequest = GetWebSessionRequest(to: reportURL)
        self.api = api
    }

    public func reportFileAccess() -> AnyPublisher<Void, Error> {
        let api = api

        return api
            .makeRequest(webSessionRequest)
            .map { $0.body.makeReportURL() }
            .flatMap { api.makeRequest($0, method: .head) }
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

private extension GetWebSessionRequest.Response {

    func makeReportURL() -> URL {
        session_url.appendingQueryItems(.init(name: "preview", value: "1"))
    }
}
