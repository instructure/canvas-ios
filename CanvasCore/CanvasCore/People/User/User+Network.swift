//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
