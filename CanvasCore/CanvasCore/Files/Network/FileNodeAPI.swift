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
    
    




open class FileNodeAPI{
    
    open class func getFiles(_ session: Session, folderID: String) throws -> URLRequest {
        let path = "/api/v1/folders/\(folderID)/files"
        return try session.GET(path)
    }
    
    open class func deleteFile(_ session: Session, fileID: String) throws -> URLRequest {
        let path = "/api/v1/files/\(fileID)"
        return try session.DELETE(path)
    }
    
    open class func getRootFolder(_ session: Session, contextID: ContextID) throws -> URLRequest {
        let path = contextID.apiPath/"folders/by_path"
        return try session.GET(path)
    }
    
    open class func getFolders(_ session: Session, folderID: String) throws -> URLRequest {
        let path = "/api/v1/folders/\(folderID)/folders"
        return try session.GET(path)
    }
    
    open class func deleteFolder(_ session: Session, folderID: String, shouldForce: Bool) throws -> URLRequest {
        let path = "/api/v1/folders/\(folderID)"
        var nillableParams: [String: Any?] = [ "force": nil ]
        if shouldForce {
            nillableParams = [ "force": "true" ]
        }
        let parameters = Session.rejectNilParameters(nillableParams)
        return try session.DELETE(path, parameters: parameters)
    }
    
    open class func addFolder(_ session: Session, contextID: ContextID, folderID: String?, name: String) throws -> URLRequest {
        let path = contextID.apiPath/"folders"
        let nillableParams: [String: Any?] = [
            "name": name,
            "parent_folder_id": folderID
        ]
        let parameters = Session.rejectNilParameters(nillableParams)
        return try session.POST(path, parameters: parameters)
    }
}
