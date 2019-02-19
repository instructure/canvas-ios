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

class GetSessionlessLaunchURL: APIOperation<GetSessionlessLaunchURLRequest> {
    init(api: API = URLSessionAPI(), context: Context, id: String?, url: URL?, launchType: GetSessionlessLaunchURLRequest.LaunchType?, assignmentID: String?, moduleItemID: String?) {
        let request = GetSessionlessLaunchURLRequest(context: context, id: id, url: url, assignmentID: assignmentID, moduleItemID: moduleItemID, launchType: launchType)
        super.init(api: api, request: request)
    }
}
