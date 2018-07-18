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

extension User {
    public static func getUsers(_ context: ContextID, session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try UserAPI.getUsers(session, context: context)
        return session.paginatedJSONSignalProducer(request)
    }
    
    
    public static func getObserveeUsers(_ session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try UserAPI.getObserveeUsers(session)
        return session.paginatedJSONSignalProducer(request)
    }

    public static func getObserveeUser(_ session: Session, observeeID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try UserAPI.getObserveeUser(session, observeeID: observeeID)
        return session.JSONSignalProducer(request)
    }

    public static func removeObserver(_ session: Session, observeeID: String) throws -> SignalProducer<(), NSError> {
        let request = try UserAPI.removeObserver(session, observeeID: observeeID)
        return session.emptyResponseSignalProducer(request)
    }

    public static func addObserver(_ session: Session, accessToken: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try UserAPI.addObserver(session, accessToken: accessToken)
        return session.paginatedJSONSignalProducer(request)
    }

    public static func removeAccessToken(_ session: Session) throws -> SignalProducer<(), NSError> {
        let request = try UserAPI.removeAccessToken(session)
        return session.emptyResponseSignalProducer(request)
    }
}
