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

public class GetBrandVariables: OperationSet {
    let api: API
    let request: GetBrandVariablesRequest

    lazy var fetch: APIOperation = {
        return APIOperation(api: self.api, request: self.request)
    }()

    public init(env: AppEnvironment, force: Bool = false) {
        self.api = env.api
        self.request = GetBrandVariablesRequest()
        super.init()
        addSequence([
            fetch,
            BlockOperation { [weak self] in self?.save(self?.fetch.response) },
        ])
    }

    func save(_ response: APIBrandVariables?) {
        guard let response = response else { return }
        Brand.shared = Brand(response: response)
    }
}
