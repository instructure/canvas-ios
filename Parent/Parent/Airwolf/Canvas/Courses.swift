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
    
    

import Foundation


import ReactiveSwift
import Marshal
import CanvasCore

extension Course {
    public static func predicate(_ courseID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", courseID)
    }
    
    public static func getCourses(_ session: Session, studentID: String) throws -> SignalProducer<[JSONObject], NSError> {
        
        var coursesParams = getCoursesParameters
        coursesParams["enrollment_state"] = "active"
        
        let request = try session.GET("/api/v1/courses", parameters: coursesParams)
        return session.paginatedJSONSignalProducer(request)
            
            // filter out restricted courses because their json is too sparse and will cause parsing issues
            .map { coursesJSON in
                return coursesJSON.filter { json in
                    // filter out restricted courses because their json is too sparse and will cause parsing issues
                    let restricted: Bool = (try? json <| "access_restricted_by_date") ?? false
                    if restricted {
                        return false
                    }

                    // only include courses for this studentID
                    let enrollments: [JSONObject] = (try? json <| "enrollments") ?? []
                    let observing = enrollments.any { enrollment in
                        let associated_user_id = try? enrollment.stringID("associated_user_id")
                        return associated_user_id == studentID
                    }
                    return observing
                }
        }
    }
    
    public static func getCourse(_ session: Session, studentID: String, courseID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.GET("/api/v1/courses/\(courseID)", parameters: Course.getCourseParameters)
        return session.JSONSignalProducer(request)
    }
    
    public static func airwolfCollectionRefresher(_ session: Session, studentID: String) throws -> Refresher {
        let remote = try Course.getCourses(session, studentID: studentID)
        let context = try session.enrollmentManagedObjectContext(studentID)
        
        let courses = Course.syncSignalProducer(inContext: context, fetchRemote: remote).map { _ in () }
        let students = try Student.observedStudentsSyncProducer(session).map { _ in () }
        
        let producer = SignalProducer.concat([courses, students])
        
        let key = cacheKey(context, [studentID])
        return SignalProducerRefresher(refreshSignalProducer: producer, scope: session.refreshScope, cacheKey: key, ttl: ParentAppRefresherTTL)
    }
    
    public static func airwolfRefresher(_ session: Session, studentID: String, courseID: String) throws -> Refresher {
        let remote = try Course.getCourse(session, studentID: studentID, courseID: courseID).map { [$0] }
        let context = try session.enrollmentManagedObjectContext(studentID)
        let predicate = Course.predicate(courseID)
        
        let sync = Course.syncSignalProducer(predicate, inContext: context, fetchRemote: remote)
        
        let key = cacheKey(context, [studentID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key, ttl: ParentAppRefresherTTL)
    }
}

