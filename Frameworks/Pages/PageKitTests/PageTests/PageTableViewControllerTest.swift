//
//  PageTableViewControllerTest.swift
//  Pages
//
//  Created by Joseph Davison on 5/31/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import PageKit
import SoAutomated
import SoPersistent
import XCTest
import TooLegit
import DoNotShipThis

class PageTableViewControllerTest: XCTestCase {
    
    let session = Session.ivy
    var contextID: ContextID {
        return ContextID(id: "24219", context: .Course)
    }
    
    func testTableViewControllerInitializer_itAssignsAttributes() {
        attempt {
            let controller = try Page.TableViewController.build()

            XCTAssertNotNil(controller.refresher)
            XCTAssertNotNil(controller.collection)
            XCTAssertNotNil(controller.route)
            XCTAssertNotNil(controller.dataSource)
        }
    }


}
