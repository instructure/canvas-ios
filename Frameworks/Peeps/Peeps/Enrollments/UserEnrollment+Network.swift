//
//  UserEnrollment+Network.swift
//  Peeps
//
//  Created by Derrick Hathaway on 2/6/17.
//  Copyright © 2017 Instructure Inc. All rights reserved.
//

import TooLegit
import ReactiveSwift
import Marshal


extension UserEnrollment {
    public static func getUsers(enrolledInCourseWithID courseID: String, session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        
        let parameters: [String: Any] = ["include": ["avatar_url"]]
        let request = try session.GET(ContextID.course(withID: courseID).apiPath/"enrollments", parameters: parameters)
        return session.paginatedJSONSignalProducer(request)
    }
}
