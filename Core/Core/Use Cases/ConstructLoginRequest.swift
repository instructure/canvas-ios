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

class ConstructLoginRequest: OperationSet {
    var request: URLRequest?
    var mobileVerify: APIVerifyClient?

    init(params: LoginParams, urlSession: URLSession = URLSession.shared) {
        super.init()
        let mobileVerifyOp = GetMobileVerify(api: URLSessionAPI(urlSession: urlSession), host: params.host)
        let buildRequestOp = dependencyOperation(mobileVerifyOp) { [weak self] (op) in
            if let mobileVerify = op.response {
                self?.mobileVerify = mobileVerify
                if let url = mobileVerify.base_url {
                    let requestable = LoginWebRequest(clientID: mobileVerify.client_id, params: params)
                    self?.request = try? requestable.urlRequest(relativeTo: url, accessToken: "")
                }
            }
        }
        addOperations([mobileVerifyOp, buildRequestOp])
    }
}
