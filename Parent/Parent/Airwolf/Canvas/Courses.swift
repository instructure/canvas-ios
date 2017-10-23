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
    
    public static func getCoursesFromAirwolf(_ session: Session, studentID: String) throws -> SignalProducer<[JSONObject], NSError> {
        
        var coursesParams = getCoursesParameters
        coursesParams["enrollment_state"] = "active"
        
        let request = try session.GET("/canvas/\(session.user.id)/\(studentID)/courses", parameters: coursesParams)
        return session.paginatedJSONSignalProducer(request)
            
            // filter out restricted courses because their json is too sparse and will cause parsing issues
            .map { coursesJSON in
                return coursesJSON.filter { json in
                    let restricted: Bool = (try? json <| "access_restricted_by_date") ?? false
                    return !restricted
                }
        }
    }
    
    public static func getCourseFromAirwolf(_ session: Session, studentID: String, courseID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.GET("/canvas/\(session.user.id)/\(studentID)/courses/\(courseID)", parameters: Course.getCourseParameters)
        return session.JSONSignalProducer(request)
    }
    
    public static func airwolfCollectionRefresher(_ session: Session, studentID: String) throws -> Refresher {
        let remote = try Course.getCoursesFromAirwolf(session, studentID: studentID)
        let context = try session.enrollmentManagedObjectContext(studentID)
        
        let sync = Course.syncSignalProducer(inContext: context, fetchRemote: remote)

        let key = cacheKey(context, [studentID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
    
    public static func airwolfRefresher(_ session: Session, studentID: String, courseID: String) throws -> Refresher {
        let remote = try Course.getCourseFromAirwolf(session, studentID: studentID, courseID: courseID).map { [$0] }
        let context = try session.enrollmentManagedObjectContext(studentID)
        let predicate = Course.predicate(courseID)
        
        let sync = Course.syncSignalProducer(predicate, inContext: context, fetchRemote: remote)
        
        let key = cacheKey(context, [studentID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
}

