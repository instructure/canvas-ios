//
//  DiscussionTopicNetworkTests.swift
//  Discussions
//
//  Created by Brandon Pluim on 4/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

@testable import DiscussionKit
import SoAutomated
import Marshal
import ReactiveCocoa
import TooLegit
import DoNotShipThis

class DiscussionTopicNetworkTests: XCTestCase {
    func testGetDiscussionTopic() {
        var json: JSONObject?
        let session = Session.bt
        let context = try! session.discussionsManagedObjectContext()
        let discussionTopic = DiscussionTopic.build(context, title: "Change me")

        stub(session, "discussion_topic_details") { expectation in
            try! DiscussionTopic.getDiscussionTopic(session, courseID: "1861019", discussionTopicID: "11719055")
                .on(failed: { XCTFail($0.localizedDescription) })
                .startWithNext {
                    json = $0
                    expectation.fulfill()
                }
        }

        guard let JSON = json else {
            XCTFail("expected json to not be nil")
            return
        }

        try! discussionTopic.updateValues(JSON, inContext: context)
        XCTAssertEqual("Simple Discussion - No Due Date", discussionTopic.title)
    }

    func testGetDiscussionTopics() {
        let session = Session.bt
        var response: [JSONObject]?

        stub(session, "discussion_topics_list") { expectation in
            try! DiscussionTopic.getDiscussionTopics(session, courseID: "1861019")
                .startWithNext {
                    response = $0
                    expectation.fulfill()
                }
        }

        XCTAssertNotNil(response)
        XCTAssertEqual(1, response?.count)
    }
}
