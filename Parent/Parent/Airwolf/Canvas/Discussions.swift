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

extension DiscussionTopic {
    public static func refresher(_ session: Session, studentID: String, courseID: String, discussionTopicID: String) throws -> Refresher {
        let remote = try DiscussionTopic.getDiscussionTopic(session, courseID: courseID, discussionTopicID: discussionTopicID).map { [$0] }
        let context = try session.discussionsManagedObjectContext(studentID)
        let sync = DiscussionTopic.syncSignalProducer(inContext: context, fetchRemote: remote)

        let key = cacheKey(context, [courseID, discussionTopicID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(_ session: Session, studentID: String, courseID: String, discussionTopicID: String) throws -> ManagedObjectObserver<DiscussionTopic> {
        let pred = predicate(discussionTopicID)
        let context = try session.discussionsManagedObjectContext(studentID)
        return try ManagedObjectObserver<DiscussionTopic>(predicate: pred, inContext: context)
    }
}
