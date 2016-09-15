//
//  Context.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 7/6/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import CoreData
import SoPersistent
import ReactiveCocoa

public struct Context {
    public let user: User
    public let testCase: XCTestCase

    public init(user: User, testCase: XCTestCase) {
        self.user = user
        self.testCase = testCase
    }

    public func refresh(tableViewController tvc: TableViewController, fixture: Fixture?, timeout: NSTimeInterval = DefaultNetworkTimeout) {
        guard let refresher = tvc.refresher?.safeCopy() else {
            XCTFail("expected a refresher")
            return
        }

        let refresh: XCTestExpectation->Void = { expectation in
            refresher.refreshingCompleted.observeNext(self.testCase.refreshCompletedWithExpectation(expectation))
            refresher.refresh(true)
        }

        if let fixture = fixture {
            testCase.stub(user.session, fixture) { expectation in
                refresh(expectation)
            }
        } else {
            let expectation = testCase.expectationWithDescription("refresh completed")
            refresh(expectation)
            testCase.waitForExpectationsWithTimeout(timeout, handler: nil)
        }

    }
}
