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
    
    

import Marshal
import ReactiveSwift


extension Folder {
    
    static func getRootFolder(_ session: Session, contextID: ContextID) throws -> SignalProducer<JSONObject, NSError> {
        let request = try FileNodeAPI.getRootFolder(session, contextID: contextID)
        return session.paginatedJSONSignalProducer(request).map { $0.first }.filter { $0 != nil }.map { $0! }
    }
    
    static func getFolders(_ session: Session, folderID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try FileNodeAPI.getFolders(session, folderID: folderID)
        return session.paginatedJSONSignalProducer(request)
    }
    
    static func deleteFolder(_ session: Session, folderID: String, shouldForce: Bool) throws -> SignalProducer<JSONObject, NSError> {
        let request = try FileNodeAPI.deleteFolder(session, folderID: folderID, shouldForce: shouldForce)
        return session.JSONSignalProducer(request)
    }
    
    static func addFolder(_ session: Session, contextID: ContextID, folderID: String?, name: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try FileNodeAPI.addFolder(session, contextID: contextID, folderID: folderID, name: name)
        return session.JSONSignalProducer(request)
    }
}
