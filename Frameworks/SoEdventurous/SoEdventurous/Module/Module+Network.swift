//
//  Module+Network.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 9/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import Marshal
import ReactiveCocoa

extension Module {
    public static func getModules(session: Session, courseID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try session.GET(api/v1/"courses"/courseID/"modules")
        return session.paginatedJSONSignalProducer(request)
    }
}