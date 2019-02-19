//
// Copyright (C) 2017-present Instructure, Inc.
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
import Marshal
import ReactiveSwift



extension Activity {
    static func getActivity(session: Session, context: ContextID) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try session.GET(context.apiPath/"activity_stream")
        return session.paginatedJSONSignalProducer(request)
    }
}
