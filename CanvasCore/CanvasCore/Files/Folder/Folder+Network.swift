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
