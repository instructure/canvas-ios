//
//  ModuleItem+Network.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 9/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import Marshal
import ReactiveCocoa

extension ModuleItem {
    public static var getModuleItemsParameters: [String: AnyObject] {
        return ["include": ["content_details", "mastery_paths"]]
    }

    public static func getModuleItems(session: Session, courseID: String, moduleID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try session.GET(api/v1/"courses"/courseID/"modules"/moduleID/"items", parameters: getModuleItemsParameters)
        return session.paginatedJSONSignalProducer(request)
    }

    // TODO: what does this return? documentation did not say :(
    public static func markModuleItemDone(session: Session, courseID: String, moduleID: String, moduleItemID: String, done: Bool) throws -> SignalProducer<JSONObject, NSError> {
        let path: String = api/v1/"courses"/courseID/"modules"/moduleID/"items"/moduleID/"done"
        let request = done ? try session.PUT(path) : try session.DELETE(path)
        // TODO: is this correct?
        return session.JSONSignalProducer(request)
    }

    // TODO: This too, what is the response? a json object?
    public static func markModuleItemRead(session: Session, courseID: String, moduleID: String, moduleItemID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.POST(api/v1/"courses"/courseID/"modules"/moduleID/"items"/moduleItemID/"mark_read")
        return session.JSONSignalProducer(request)
    }
}