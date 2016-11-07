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
        let topic = DiscussionTopic(inContext: context)
        try! topic.updateValues(json, inContext: context)
        XCTAssertEqual("Simple Discussion - No Due Date", topic.title)
    }
}
