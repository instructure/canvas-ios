//
//  Enrollment+Network.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 3/14/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import TooLegit
import ReactiveCocoa
import SoPretty
import Marshal

extension Enrollment {
    public static func put(session:Session, color: UIColor, forContextID: ContextID) -> SignalProducer<(), NSError> {
        let path = "/api/v1/users/self/colors" / forContextID.canvasContextID
        let params: [String: AnyObject] = ["hexcode": color.hex]
        return attemptProducer { try session.PUT(path, parameters: params) }
            .flatMap(.Merge, transform: session.emptyResponseSignalProducer)
    }
}
