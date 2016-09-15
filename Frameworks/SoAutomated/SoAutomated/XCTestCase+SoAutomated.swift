//
//  UnitTestCase.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 1/24/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import XCTest
import TooLegit
import CoreData
import SoLazy
import DVR
@testable import SoPersistent

public let DefaultNetworkTimeout: NSTimeInterval = 5

@available(*, deprecated, message="use Stub instead")
public protocol Fixture {
    var name: String { get }
    var bundle: NSBundle { get }
}

public class UnitTestCase: XCTestCase {
    override public func invokeTest() {
        continueAfterFailure = false
        super.invokeTest()
    }
}

public typealias DoneAction = ()->Void

extension XCTestCase {
    public func attempt(file: StaticString = #file, line: UInt = #line, @noescape block: () throws -> Void) {
        do {
            try block()
        } catch {
            XCTFail("\(error)", file: file, line: line)
        }
    }

    /**
     Used to assert that the number of something changed within a block.

     - parameter selector: A method that returns some form of computation
     - parameter difference: The expected difference between the result of `selector` before and after the `block`
     - parameter block: The block that will be executed to possibly change the outcome of `selector` by a factor of `difference`
    */
    public func assertDifference<T: IntegerArithmeticType>(@noescape selector: ()->T, _ difference: T, _ message: String = "", @noescape block: () throws -> Void) {
        let before = selector()
        attempt {
            try block()
        }
        let after = selector()
        XCTAssertEqual(difference, after - before, message)
    }

    @available(*, deprecated, message="use performNetworkRequests instead")
    public func stub(session: TooLegit.Session, _ fixture: Fixture, timeout: NSTimeInterval = DefaultNetworkTimeout, @noescape block: XCTestExpectation throws -> Void) {
        let stub = Stub(session: session, name: fixture.name, testCase: self, bundle: fixture.bundle)
        performNetworkRequests(with: stub, timeout: timeout, block: block)
    }

    public func performNetworkRequests(with stub: Stub, timeout: NSTimeInterval = DefaultNetworkTimeout, @noescape block: XCTestExpectation throws -> Void) {
        let expectation = expectationWithDescription(stub.name)
        // hang on to the original URLSession so we can put it back
        let URLSession = stub.session.URLSession

        // create the DVR Session
        let DVRSession = DVR.Session(outputDirectory: "~/Desktop/", cassetteName: stub.name, testBundle: stub.bundle, backingSession: URLSession)
        stub.session.URLSession = DVRSession

        // perform block with stub
        DVRSession.beginRecording()
        attempt {
            try block(expectation)
        }
        waitForExpectationsWithTimeout(timeout, handler: nil)
        DVRSession.endRecording()

        // restore the original URLSession
        stub.session.URLSession = URLSession
    }

    public func refreshCompletedWithExpectation(expectation: XCTestExpectation, file: StaticString = #file, line: UInt = #line) -> NSError? -> Void {
        return { error in
            if let error = error {
                XCTFail(error.localizedDescription, file: file, line: line)
            }
            expectation.fulfill()
        }
    }
}

import Quick
import Nimble
extension XCTestCase {
    public func performNetworkRequests(with stub: Stub, timeout: NSTimeInterval = DefaultNetworkTimeout, doneBlock: (DoneAction) throws -> Void) {
        // hang on to the original URLSession so we can put it back
        let URLSession = stub.session.URLSession

        // create the DVR Session
        let DVRSession = DVR.Session(outputDirectory: "~/Desktop/", cassetteName: stub.name, testBundle: stub.bundle, backingSession: URLSession)
        stub.session.URLSession = DVRSession

        // perform block with stub
        DVRSession.beginRecording()
        waitUntil { done in
            self.attempt {
                try doneBlock(done)
            }
        }
        DVRSession.endRecording()

        // restore the original URLSession
        stub.session.URLSession = URLSession
    }
}
