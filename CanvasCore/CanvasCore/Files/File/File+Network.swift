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


extension File {
    
    static func getFiles(_ session: Session, folderID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try FileNodeAPI.getFiles(session, folderID: folderID)
        return session.paginatedJSONSignalProducer(request)
    }
    
    static func deleteFile(_ session: Session, fileID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try FileNodeAPI.deleteFile(session, fileID: fileID)
        return session.JSONSignalProducer(request)
    }
}
