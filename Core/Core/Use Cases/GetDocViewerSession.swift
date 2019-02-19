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

class GetDocViewerSession: AsyncOperation, URLSessionTaskDelegate {
    let accessToken: String
    var sessionURL: URL?
    var task: URLSessionTask?
    let url: URL
    lazy var urlSession: URLSession = {
        return URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
    }()

    init(url: URL, accessToken: String) {
        self.accessToken = accessToken
        self.url = url
    }

    override func execute() {
        guard !isCancelled else { return }

        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: HttpHeader.authorization)
        task = urlSession.dataTask(with: request) { [weak self] _, response, error in
            self?.addError(error)
            if let url = (response as? HTTPURLResponse)?.allHeaderFields["Location"] as? String {
                var components = URLComponents.parse(url)
                components.query = nil
                components.path = components.path.replacingOccurrences(of: "/view", with: "")
                self?.sessionURL = components.url
            }
            self?.finish()
        }
        task?.resume()
    }

    override func cancel() {
        super.cancel()
        task?.cancel()
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}
