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

import XCTest

class CKIDiscussionTopicTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let discussionTopicDictionary = Helpers.loadJSONFixture("discussion_topic") as NSDictionary
        let topic = CKIDiscussionTopic(fromJSONDictionary: discussionTopicDictionary)
        
        XCTAssertEqual(topic.title!, "Topic 1", "Discussion Topic title was not parsed correctly")
        XCTAssertEqual(topic.messageHTML!, "<p>content here</p>", "Discussion Topic messageHTML was not parsed correctly")
        
        var url = NSURL(string:"https://canvas.instructure.com/courses/1/discussion_topics/2")
        XCTAssertEqual(topic.htmlURL!, url!, "Discussion Topic htmlURL was not parsed correctly")
        
        var formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2037-07-21T13:29:31Z")
        XCTAssertEqual(topic.postedAt!, date, "Discussion Topic postedAt was not parsed correctly")
        date = formatter.dateFromString("2037-07-28T19:38:31Z")
        XCTAssertEqual(topic.lastReplyAt!, date, "Discussion Topic lastReplyAt was not parsed correctly")
        XCTAssertFalse(topic.requireInitialPost, "Discussion Topic requireInitialPost was not parsed correctly")
        XCTAssert(topic.userCanSeePosts, "Discussion Topic userCanSeePosts was not parsed correctly")
        XCTAssertEqual(topic.subentryCount, 3, "Discussion Topic subentryCount was not parsed correctly")
        XCTAssert(topic.isRead, "Discussion Topic isRead was not parsed correctly")
        XCTAssertEqual(topic.unreadCount, 5, "Discussion Topic unreadCount was not parsed correctly")
        XCTAssert(topic.isSubscribed, "Discussion Topic isSubscribed was not parsed correctly")
        XCTAssertEqual(topic.subscriptionHold, CKIDiscussionTopicSubscriptionHold.InitialPostRequired, "Discussion Topic subscriptionHold was not parsed correctly")
        XCTAssertEqual(topic.assignmentID!, "847", "Discussion Topic assignmentID was not parsed correctly")
        
        date = formatter.dateFromString("2037-07-21T13:29:31Z")
        XCTAssertEqual(topic.delayedPostAt!, date, "Discussion Topic delayedPostAt was not parsed correctly")
        XCTAssertEqual(topic.isPublished, true, "Discussion Topic isPublished was not parsed correctly")
        
        date = formatter.dateFromString("2037-07-21T13:29:31Z")
        XCTAssertEqual(topic.lockAt!, date, "Discussion Topic lockAt was not parsed correctly")
        XCTAssertFalse(topic.isLocked, "Discussion Topic isLocked was not parsed correctly")
        XCTAssertFalse(topic.isPinned, "Discussion Topic isPinned was not parsed correctly")
        XCTAssert(topic.isLockedForUser, "Discussion Topic isLockedForUser was not parsed correctly")
        XCTAssertNotNil(topic.lockInfo, "Discussion Topic lockInfo.class was not parsed correctly")
//        XCTAssertEqual(topic.lockInfo!.dynamicType, CKILockInfo().self, "Discussion Topic lockInfo.class was not parsed correctly")
        XCTAssertEqual(topic.lockExplanation!, "This discussion is locked until September 1 at 12:00am", "Discussion Topic lockExplanation was not parsed correctly")
        XCTAssertEqual(topic.userName!, "User Name", "Discussion Topic userName was not parsed correctly")
        XCTAssertEqual(topic.childrenTopicIDs.count, 3, "Discussion Topic childrenTopicIDs was not parsed correctly")
        XCTAssertEqual(topic.rootTopicID!, "1236", "Discussion Topic rootTopicID was not parsed correctly")
        
        url = NSURL(string:"/feeds/topics/1/enrollment_1XAcepje4u228rt4mi7Z1oFbRpn3RAkTzuXIGOPe.rss")
        XCTAssertEqual(topic.podcastURL!, url!, "Discussion Topic podcastURL was not parsed correctly")
        XCTAssertEqual(topic.type, CKIDiscussionTopicType.SideComment, "Discussion Topic topic.type was not parsed correctly")
        XCTAssertNotNil(topic.attachments[0], "Discussion Topic topic.attachments[0] was not parsed correctly")
//        XCTAssertEqualObjects((topic.attachments[0] as CKIAttachment).self, CKIAttachment().self, "Discussion Topic topic.attachments[0] was not parsed correctly")
        XCTAssert(topic.canAttachPermission, "Discussion Topic canAttachPermission was not parsed correctly")
        XCTAssertEqual(topic.path!, "/api/v1/discussion_topics/1", "Discussion Topic path was not parsed correctly")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
