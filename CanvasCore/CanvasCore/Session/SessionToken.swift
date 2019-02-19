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
import Result

public struct APISessionToken: Codable {
    public let session_url: URL
}

extension Session {
    public func getAuthenticatedURL(forURL url: URL, callback: @escaping (Result<URL, NSError>) -> Void) {
        let returnURL = url.appending(value: "borderless", forQueryParameter: "display") ?? url
        let params = [
            "return_to": returnURL.absoluteString,
            ]

        do {
            let request = try GET("/login/session_token", parameters: params, encoding: .url, authorized: true)
            makeRequest(request) { (result: Result<APISessionToken, NSError>) in
                switch result {
                case .success(let token):
                    callback(.success(token.session_url))
                case .failure(let error):
                    callback(.failure(error))
                }
            }
        } catch {
            callback(.failure(error as NSError))
        }
    }
}
