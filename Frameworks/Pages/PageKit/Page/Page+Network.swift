//
//  Page+Network.swift
//  Pages
//
//  Created by Joseph Davison on 5/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import Marshal
import ReactiveCocoa

extension Page {
    
    public static func getPages(session: Session, contextID: ContextID) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try PageAPI.getPages(session, contextID: contextID)
        return session.paginatedJSONSignalProducer(request)
    }
    
    public static func getPage(session: Session, contextID: ContextID, url: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try PageAPI.getPage(session, contextID: contextID, url: url)
        return session.JSONSignalProducer(request)
    }

    public static func getFrontPage(session: Session, contextID: ContextID) throws -> SignalProducer<JSONObject, NSError> {
        let request = try PageAPI.getFrontPage(session, contextID: contextID)
        return session.JSONSignalProducer(request)
    }
    
}