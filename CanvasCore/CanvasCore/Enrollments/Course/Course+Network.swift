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
    
    

import ReactiveSwift

import Marshal

extension Course {
    public static var getCoursesParameters: [String: Any] {
        return ["include": ["needs_grading_count", "syllabus_body", "total_scores", "term", "permissions", "current_grading_period_scores", "favorites", "tabs", "observed_users"]]
    }
    
    public static var getCourseParameters: [String: Any] {
        return ["include": ["needs_grading_count", "syllabus_body", "total_scores", "term", "permissions", "current_grading_period_scores", "observed_users"]]
    }

    public static func filter(rawCourses: [JSONObject]) -> [JSONObject] {
        return rawCourses
            // filter out restricted courses because their json is too sparse and will cause parsing issues
            .filter { json in
                let restricted: Bool = (try? json <| "access_restricted_by_date") ?? false
                return !restricted
            }

            // remove pending enrollments because their json is also too sparse
            .map { json in
                var json = json
                let enrollments: [JSONObject] = (try? json <| "enrollments") ?? []
                json["enrollments"] = enrollments.filter { json in
                    let enrollmentState: String = (try? json <| "enrollment_state") ?? ""
                    return enrollmentState != "invited"
                }
                return json
            }

            // filter out courses without any enrollments
            .filter { json in
                let enrollments: [JSONObject] = (try? json <| "enrollments") ?? []
                return enrollments.any()
            }
    }

    public static func getAllCourses(_ session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try session.GET(api/v1/"courses", parameters: getCoursesParameters)
        return session.paginatedJSONSignalProducer(request).map { filter(rawCourses: $0) }
    }
}
