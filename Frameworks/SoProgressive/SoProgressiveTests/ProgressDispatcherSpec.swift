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
import Result
import ReactiveCocoa
import TooLegit
import DoNotShipThis
import SoProgressive

class DescribeProgressDispatcher: XCTestCase {
    let discussionViewed = Progress(kind: .Viewed, contextID: ContextID(id: "12", context: .Course), itemType: .Discussion, itemID: "19")
    
    func test_itCanDispatchWithoutAnyoneListening() {
        let dispatcher = ProgressDispatcher()
        
        // no assertion. just making sure you can dispatch with noone listening without any hiccups
        dispatcher.dispatch(discussionViewed)
    }

    
    func test_itSignalsProgress() {
        let dispatcher = ProgressDispatcher()

        let expectation = expectationWithDescription("observe discussion viewed")
        
        dispatcher
            .onProgress
            .observeNext { progress in
        
            XCTAssertEqual(progress, self.discussionViewed)
            expectation.fulfill()
        }
        
        dispatcher.dispatch(discussionViewed)

        waitForExpectationsWithTimeout(0.1, handler: nil)
    }
}
