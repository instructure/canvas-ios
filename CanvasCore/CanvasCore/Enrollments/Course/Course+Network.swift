//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
