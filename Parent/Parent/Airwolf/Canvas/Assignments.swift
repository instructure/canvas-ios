//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

import ReactiveSwift
import Marshal
import CanvasCore

extension Assignment {

    public static func getAssignment(_ session: Session, courseID: String, assignmentID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.GET("/api/v1/courses/\(courseID)/assignments/\(assignmentID)", parameters: Assignment.parameters)
        return session.JSONSignalProducer(request)
    }

    public static func refresher(_ session: Session, studentID: String, courseID: String, assignmentID: String) throws -> Refresher {
        let remote = try Assignment.getAssignment(session, courseID: courseID, assignmentID: assignmentID).map { [$0] }.map(insert(studentID, forKey: "studentID"))

        let local = predicate(courseID, assignmentID: assignmentID)
        let context = try session.assignmentsManagedObjectContext(studentID)
        let sync = Assignment.syncSignalProducer(local, inContext: context, fetchRemote: remote)

        let key = cacheKey(context, [studentID, courseID, assignmentID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(_ session: Session, studentID: String, courseID: String, assignmentID: String) throws -> ManagedObjectObserver<Assignment> {
        let pred = predicate(courseID, assignmentID: assignmentID)
        let context = try session.assignmentsManagedObjectContext(studentID)
        return try ManagedObjectObserver<Assignment>(predicate: pred, inContext: context)
    }
}
