//
//  Stub.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 7/20/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import TooLegit
import XCTest

public struct Stub {
    public let session: Session
    public let name: String
    public let testCase: XCTestCase
    public let bundle: NSBundle

    public init(session: Session, name: String, testCase: XCTestCase, bundle: NSBundle) {
        self.session = session
        self.name = name
        self.testCase = testCase
        self.bundle = bundle
    }
}

// TODO: remove Fixture
extension Stub: Fixture {}
