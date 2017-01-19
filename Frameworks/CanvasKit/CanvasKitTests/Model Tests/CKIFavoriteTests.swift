//
//  CKIFavoriteTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/23/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIFavoriteTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let favoriteDictionary = Helpers.loadJSONFixture("favorite") as NSDictionary
        let favorite = CKIFavorite(fromJSONDictionary: favoriteDictionary)
        
        XCTAssertEqual(favorite.contextID!, "1170", "Favorite contextID did not parse correctly")
        XCTAssertEqual(favorite.contextType!, "Course", "Favorite contextType did not parse correctly")
    }
}
