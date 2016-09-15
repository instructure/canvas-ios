//
//  Folder+Network.swift
//  FileKit
//
//  Created by Egan Anderson on 5/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Marshal
import ReactiveCocoa
import TooLegit

extension Folder {
    
    static func getRootFolder(session: Session, contextID: ContextID) throws -> SignalProducer<JSONObject, NSError> {
        let request = try FileNodeAPI.getRootFolder(session, contextID: contextID)
        return session.paginatedJSONSignalProducer(request).map { $0.first }.filter { $0 != nil }.map { $0! }
    }
    
    static func getFolders(session: Session, folderID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try FileNodeAPI.getFolders(session, folderID: folderID)
        return session.paginatedJSONSignalProducer(request)
    }
    
    static func deleteFolder(session: Session, folderID: String, shouldForce: Bool) throws -> SignalProducer<JSONObject, NSError> {
        let request = try FileNodeAPI.deleteFolder(session, folderID: folderID, shouldForce: shouldForce)
        return session.JSONSignalProducer(request)
    }
    
    static func addFolder(session: Session, contextID: ContextID, folderID: String?, name: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try FileNodeAPI.addFolder(session, contextID: contextID, folderID: folderID, name: name)
        return session.JSONSignalProducer(request)
    }
}
