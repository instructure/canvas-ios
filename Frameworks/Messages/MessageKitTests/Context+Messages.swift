
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
import CoreData
import Marshal
import MessageKit
import SoAutomated
import SoPersistent

extension Context {
    func getConversations(fixture fixture: String?) -> [JSONObject] {
        let session = user.session
        var conversations: [JSONObject]!

        if let fixture = fixture {
            testCase.stub(session, fixture) { expectation in
                testCase.attempt {
                    try Conversation.getConversations(session).startWithCompletedExpectation(expectation) { response in
                        conversations = response
                    }
                }
            }
        } else {
            testCase.attempt {
                let expectation = testCase.expectationWithDescription("network")
                try Conversation.getConversations(session).startWithCompletedExpectation(expectation) { response in
                    conversations = response
                }
            }
        }

        if conversations == nil {
            XCTFail("failed to get conversations")
        }

        return conversations
    }

    func syncConversations(fixture fixture: String?) {
        let session = user.session

        if let fixture = fixture {
            testCase.stub(session, fixture) { expectation in
                testCase.attempt {
                    try Conversation.syncSignalProducer(session).startWithCompletedExpectation(expectation) { _ in }
                }
            }
        } else {
            let expectation = testCase.expectationWithDescription("network")
            testCase.attempt {
                try Conversation.syncSignalProducer(session).startWithCompletedExpectation(expectation) { _ in }
            }
            testCase.waitForExpectationsWithTimeout(5, handler: nil)
        }
    }

    func findConversation(id id: String) -> Conversation {
        var conversation: Conversation!
        testCase.attempt {
            let context = try user.session.messagesManagedObjectContext()
            conversation = try Conversation.findOne(withValue: id, forKey: "id", inContext: context)
        }

        if conversation == nil {
            XCTFail("could not find conversation")
        }

        return conversation
    }
}
