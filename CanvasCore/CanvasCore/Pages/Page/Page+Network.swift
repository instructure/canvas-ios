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
    
    

import Foundation

import Marshal
import ReactiveSwift

extension Page {
    
    public static func getPages(_ session: Session, contextID: ContextID) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try PageAPI.getPages(session, contextID: contextID)
        return session.paginatedJSONSignalProducer(request)
    }
    
    public static func getPage(_ session: Session, contextID: ContextID, url: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try PageAPI.getPage(session, contextID: contextID, url: url)
        return session.JSONSignalProducer(request)
    }

    public static func getFrontPage(_ session: Session, contextID: ContextID) throws -> SignalProducer<JSONObject, NSError> {
        let request = try PageAPI.getFrontPage(session, contextID: contextID)
        return session.JSONSignalProducer(request)
    }
    
}
