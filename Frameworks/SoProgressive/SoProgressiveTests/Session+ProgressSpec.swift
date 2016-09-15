//
//  Session+SoProgressiveSpec.swift
//  SoProgressive
//
//  Created by Derrick Hathaway on 4/5/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import TooLegit
import DoNotShipThis
import SoProgressive

class DescribeSessionProgress: XCTestCase {
    func test_itHasAProgressDispatcher() {
        let session = Session.art
        
        let dispatcher = session.progressDispatcher
        XCTAssert(dispatcher === session.progressDispatcher)
        
        
        dispatcher.onProgress.observeNext({ _ in })// avoid a warning of unused dispatcher
    }
}
