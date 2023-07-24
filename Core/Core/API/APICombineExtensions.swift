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

public extension API {

    func makeRequest<Request: APIRequestable>(
        _ requestable: Request,
        refreshToken: Bool = true
    ) -> AnyPublisher<(body: Request.Response, urlResponse: HTTPURLResponse?), Error> {
        Future { promise in
            self.makeRequest(requestable,
                             refreshToken: refreshToken) { response, urlResponse, error in
                if let response {
                    promise(.success((body: response,
                                      urlResponse: urlResponse as? HTTPURLResponse)))
                } else if let error {
                    promise(.failure(error))
                } else if Request.Response.self is APINoContent.Type {
                    // swiftlint:disable:next force_cast
                    promise(.success((body: APINoContent() as! Request.Response,
                                      urlResponse: urlResponse as? HTTPURLResponse)))
                } else {
                    promise(.failure(NSError.instructureError("No response or error received.")))
                }
            }
        }.eraseToAnyPublisher()
    }

    func makeRequest(_ url: URL,
                     method: APIMethod? = nil)
    -> AnyPublisher<URLResponse?, Error> {
        Future { promise in
            self.makeDownloadRequest(url, method: method) { _, response, error in
                if let response {
                    promise(.success(response))
                } else {
                    promise(.failure(error ?? NSError.instructureError("No response or error received.")))
                }
            }
        }.eraseToAnyPublisher()
    }
}
