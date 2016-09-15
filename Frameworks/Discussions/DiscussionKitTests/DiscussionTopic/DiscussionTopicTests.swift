//
//  DiscussionTopicTests.swift
//  Discussions
//
//  Created by Brandon Pluim on 4/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
@testable import DiscussionKit
import SoAutomated
import CoreData
import Marshal
import SoPersistent
import TooLegit

class DiscussionTopicTests: XCTestCase {

    func testIsValid() {
        let session = Session.inMemory
        let context = try! session.discussionsManagedObjectContext()
        let topic = DiscussionTopic.build(context)
        XCTAssert(topic.isValid)
    }

    func testUpdateValues() {
        let json = DiscussionTopic.validJSON
        let session = Session.inMemory
        let context = try! session.discussionsManagedObjectContext()
        let topic = DiscussionTopic.create(inContext: context)
        try! topic.updateValues(json, inContext: context)
        XCTAssertEqual("Simple Discussion - No Due Date", topic.title)
    }
}
