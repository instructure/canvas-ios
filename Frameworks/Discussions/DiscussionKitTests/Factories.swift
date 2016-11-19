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
    
    

@testable import DiscussionKit
import SoAutomated
import TooLegit
import DoNotShipThis
import Marshal
import CoreData
import SoPersistent

extension DiscussionTopic {
    static var validJSON: JSONObject {
        let bundle = NSBundle.soAutomated
        let data = NSData(contentsOfFile: bundle.pathForResource("discussion_topic", ofType: "json")!)!
        return try! JSONParser.JSONObjectWithData(data)
    }

    static func build(context: NSManagedObjectContext,
                      id: String = "11719055",
                      title: String = "Simple Discussion",
                      message: String = "Hello",
                      username: String = "John Doe",
                      htmlURL: NSURL = NSURL(string: "https://mobiledev.instructure.com/courses/1861019/discussion_topics/11719055")!,
                      postedAt: NSDate? = nil,
                      type: DiscussionTopicType = .SideComment,
                      requiresInitialPost: Bool = false,
                      isRead: Bool = false,
                      unreadCount: Int16 = 0,
                      pinned: Bool = false,
                      assignmentID: String? = nil,
                      closedForComments: Bool = false,
                      published: Bool = true,
                      lockedForUser: Bool = false,
                      lockExplanation: String? = nil
    ) -> DiscussionTopic {
        let discussion = DiscussionTopic(inContext: context)
        discussion.id = id
        discussion.title = title
        discussion.message = message
        discussion.username = username
        discussion.htmlURL = htmlURL
        discussion.postedAt = postedAt
        discussion.type = type
        discussion.requiresInitialPost = requiresInitialPost
        discussion.isRead = isRead
        discussion.unreadCount = unreadCount
        discussion.pinned = pinned
        discussion.assignmentID = assignmentID
        discussion.closedForComments = closedForComments
        discussion.published = published
        discussion.lockedForUser = lockedForUser
        discussion.lockExplanation = lockExplanation
        return discussion
    }
}
