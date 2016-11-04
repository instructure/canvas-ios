
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import ReactiveCocoa
import TooLegit
import Marshal

extension Course {
    public static var getCoursesParameters: [String: AnyObject] {
        return ["include": ["needs_grading_count", "syllabus_body", "total_scores", "term", "permissions", "current_grading_period_scores", "favorites"]]
    }
    
    public static var getCourseParameters: [String: AnyObject] {
        return ["include": ["needs_grading_count", "syllabus_body", "total_scores", "term", "permissions", "current_grading_period_scores"]]
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
