//
//  Course+Network.swift
//  Enrollments
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import ReactiveCocoa
import TooLegit
import Marshal

extension Course {
    public static var getCoursesParameters: [String: AnyObject] {
        return ["include": ["needs_grading_count", "syllabus_body", "total_scores", "term", "permissions", "current_grading_period_scores", "favorites"]]
    }

    public static func getAllCourses(session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try session.GET(api/v1/"courses", parameters: getCoursesParameters)
        return session.paginatedJSONSignalProducer(request)
            
            // filter out restricted courses because their json is too sparse and will cause parsing issues
            .map { coursesJSON in
                return coursesJSON.filter { json in
                    let restricted: Bool = (try? json <| "access_restricted_by_date") ?? false
                    return !restricted
                }
            }
    }
}
