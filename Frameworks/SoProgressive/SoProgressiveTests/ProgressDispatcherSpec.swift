//
//  ProgressDispatcherSpec.swift
//  SoProgressive
//
//  Created by Derrick Hathaway on 4/5/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
