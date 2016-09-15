//
//  File+Network.swift
//  FileKit
//
//  Created by Egan Anderson on 5/11/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Marshal
import ReactiveCocoa
import TooLegit

extension File {
    
    static func getFiles(session: Session, folderID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try FileNodeAPI.getFiles(session, folderID: folderID)
        return session.paginatedJSONSignalProducer(request)
    }
    
    static func deleteFile(session: Session, fileID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try FileNodeAPI.deleteFile(session, fileID: fileID)
        return session.JSONSignalProducer(request)
    }
}