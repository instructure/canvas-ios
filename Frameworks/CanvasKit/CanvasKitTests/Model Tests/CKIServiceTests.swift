//
//  CKIServiceTests.swift
//  CanvasKit
//
//  Created by Rick Roberts on 7/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        
        let serviceDictionary = Helpers.loadJSONFixture("service") as NSDictionary
        let service = CKIService(fromJSONDictionary: serviceDictionary)
        
        XCTAssertEqual(service.domain!, NSURL(string: "kaltura.example.com")!, "service domain not parsed correctly")
        XCTAssert(service.enabled, "service enabled not parsed correctly")
        XCTAssertEqual(service.partnerID!, "123456", "service partner id not parsed correctly")
        XCTAssertEqual(service.resourceDomain!, NSURL(string: "cdn.kaltura.example.com")!, "service resource domain not parsed correctly")
        XCTAssertEqual(service.rtmp!, NSURL(string: "rtmp.example.com")!, "service rmtp domain not parsed correctly")
    }
}
