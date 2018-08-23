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

class APIOperation<Request: APIRequestable>: AsyncOperation {
    let api: API
    let request: Request
    var task: URLSessionTask?

    var response: Request.Response?
    var urlResponse: URLResponse?
    var error: Error?

    init(api: API, request: Request) {
        self.api = api
        self.request = request
    }

    override func execute() {
        guard !isCancelled else {
            return
        }
        task = api.makeRequest(request) { [weak self] response, urlResponse, error in
            self?.response = response
            self?.urlResponse = urlResponse
            self?.error = error
            self?.finish()
        }
    }

    override func cancel() {
        super.cancel()
        task?.cancel()
    }
}
