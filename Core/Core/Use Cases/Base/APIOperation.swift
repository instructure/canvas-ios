//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public class APIOperation<Request: APIRequestable>: AsyncOperation {
    public typealias Callback = (Request.Response?, URLResponse?, Error?) -> Void
    public let api: API
    public let request: Request
    public let callback: Callback?
    public var task: URLSessionTask?

    public var response: Request.Response?
    public var urlResponse: URLResponse?
    public var next: GetNextRequest<Request.Response>? {
        if let response = urlResponse {
            return request.getNext(from: response)
        }
        return nil
    }

    public init(api: API, request: Request, callback: Callback? = nil) {
        self.api = api
        self.request = request
        self.callback = callback
    }

    public override func execute() {
        if isCancelled {
            return
        }

        task = api.makeRequest(request) { [weak self] response, urlResponse, error in
            self?.response = response
            self?.urlResponse = urlResponse
            self?.addError(error)
            self?.callback?(response, urlResponse, error)
            self?.finish()
        }
    }

    public override func cancel() {
        super.cancel()
        task?.cancel()
    }
}
