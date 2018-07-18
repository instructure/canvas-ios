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
