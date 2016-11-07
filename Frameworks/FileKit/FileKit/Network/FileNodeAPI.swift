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
    
    

import TooLegit
import SoLazy

public class FileNodeAPI{
    
    public class func getFiles(session: Session, folderID: String) throws -> NSURLRequest {
        let path = "/api/v1/folders/\(folderID)/files"
        return try session.GET(path)
    }
    
    public class func deleteFile(session: Session, fileID: String) throws -> NSURLRequest {
        let path = "/api/v1/files/\(fileID)"
        return try session.DELETE(path)
    }
    
    public class func getRootFolder(session: Session, contextID: ContextID) throws -> NSURLRequest {
        let path = contextID.apiPath/"folders/by_path"
        return try session.GET(path)
    }
    
    public class func getFolders(session: Session, folderID: String) throws -> NSURLRequest {
        let path = "/api/v1/folders/\(folderID)/folders"
        return try session.GET(path)
    }
    
    public class func deleteFolder(session: Session, folderID: String, shouldForce: Bool) throws -> NSURLRequest {
        let path = "/api/v1/folders/\(folderID)"
        var nillableParams: [String: AnyObject?] = [ "force": nil ]
        if shouldForce {
            nillableParams = [ "force": "true" ]
        }
        let parameters = Session.rejectNilParameters(nillableParams)
        return try session.DELETE(path, parameters: parameters)
    }
    
    public class func addFolder(session: Session, contextID: ContextID, folderID: String?, name: String) throws -> NSURLRequest {
        let path = contextID.apiPath/"folders"
        let nillableParams: [String: AnyObject?] = [
            "name": name,
            "parent_folder_id": folderID
        ]
        let parameters = Session.rejectNilParameters(nillableParams)
        return try session.POST(path, parameters: parameters)
    }
}
