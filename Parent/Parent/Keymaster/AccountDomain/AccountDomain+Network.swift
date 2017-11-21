//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import ReactiveSwift

import Marshal
import CanvasCore

extension AccountDomain {
    static func getAccountDomains() throws -> SignalProducer<[JSONObject], NSError> {
        guard let url = URL(string: "https://canvas.instructure.com/api/v1/accounts/search?per_page=99") else {
            ❨╯°□°❩╯⌢"URL parsing from normal url string didn't work"
        }
        let request = URLRequest(url: url)
        return Session.unauthenticated.paginatedJSONSignalProducer(request)
    }
}
