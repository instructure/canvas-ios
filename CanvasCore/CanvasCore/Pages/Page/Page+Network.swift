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
