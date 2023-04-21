//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core

public class DataSeeder {
    public struct Retry {
        public static let standard = Retry(count: 10, gracePeriod: 2)

        /** The number of times the request to be retried in case of a failure. The total API call count will be 1 + `count`. */
        public let count: Int
        /** How many seconds should be waited before another retry occurs. */
        public let gracePeriod: Int
    }

    private let api: API

    public init() {
        let loginSession: LoginSession = {
            let dataSeedUser = UITestUser.dataSeedAdmin
            return LoginSession(accessToken: dataSeedUser.password,
                                baseURL: URL(string: "https://\(dataSeedUser.host)")!,
                                userID: "",
                                userName: "")
        }()
        self.api = API(loginSession)
    }

    @discardableResult
    public func makeRequest<Request: APIRequestable>(_ requestable: Request, retry: Retry? = nil) throws -> Request.Response {
        let requestCount: Int =  {
            guard let retry = retry else {
                return 1
            }
            return retry.count + 1
        }()
        let retrySleep = retry?.gracePeriod ?? 0
        var result: (entity: Request.Response?, urlResponse: URLResponse?, error: Error?)?

        for requestIndex in 0..<requestCount {
            if requestIndex != 0 {
                sleep(UInt32(retrySleep))
            }

            result = request(requestable)

           if Request.Response.self is APINoContent.Type {
               // swiftlint:disable:next force_cast
               return APINoContent() as! Request.Response
           }

            if let resultEntity = result?.entity {
                return resultEntity
            }
        }

        throw result?.error ?? NSError.instructureError("API call failed")
    }

    private func request<Request: APIRequestable>(_ requestable: Request) -> (entity: Request.Response?, urlResponse: URLResponse?, error: Error?) {
        var result: (entity: Request.Response?, urlResponse: URLResponse?, Error?) = (nil, nil, nil)

        let serializer = DispatchSemaphore(value: 0)
        api.makeRequest(requestable, refreshToken: false) { apiEntity, urlResponse, error in
            result = (apiEntity, urlResponse, error)
            serializer.signal()
        }
        serializer.wait()

        return result
    }
}
