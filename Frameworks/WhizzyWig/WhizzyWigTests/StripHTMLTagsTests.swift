
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
    
    

//
//  StripHTMLTagsTests.swift
//  WhizzyWig
//
//  Created by Derrick Hathaway on 5/8/15.
//
//

import Foundation
import XCTest
import WhizzyWig

class StripHTMLTagsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStripBRTags() {
        let html =      "There should be a newline here.<br />There should also be one here. <BR/>ducks"
        let expected =  "There should be a newline here.\nThere should also be one here. \nducks"
        let stripped = html.stringByStrippingHTML()
        XCTAssertEqual(expected, stripped, "<br /> tags replaced by \\n")
    }
    
    func testStripEndPTags() {
        let html =      "There should be a newline here.<p> And one here.</P>Bananas"
        let expected =  "There should be a newline here.\n And one here.\nBananas"
        
        let stripped = html.stringByStrippingHTML()
        XCTAssertEqual(expected, stripped, "<p> tags replaced with \\n")
    }
    
    func testStripOtherTags() {
        let html =      "<strong>The quick brown fox</strong> jumps over the <italic>lazy</italic> dog."
        let expected =  "The quick brown fox jumps over the lazy dog."
        
        let stripped = html.stringByStrippingHTML()
        XCTAssertEqual(expected, stripped, "other tags stripped")
    }
    
    func testStripTagsWithAttributes() {
        let html =      "<img src=\"image4.jpg\" />This is a picture of a duck. Here's a link to a <a href=\"chicken.html\"><IMG src=\"chicken.jpg\" />chicken</A>"
        let expected =  "This is a picture of a duck. Here's a link to a chicken"
        
        let stripped = html.stringByStrippingHTML()
        XCTAssertEqual(expected, stripped, "Remove all the tags")
    }
    
    func testTrimLeadingAndTrailingWhitespace() {
        let html =      "   This has some space that we don't care about.\n  "
        let expected =  "This has some space that we don't care about."
        
        let stripped = html.stringByStrippingHTML()
        XCTAssertEqual(expected, stripped, "leading and trailing whitespace removed")
    }

    func testPerformanceExample() {
        let html = try! String(contentsOfFile: NSBundle(forClass: StripHTMLTagsTests.classForCoder()).pathForResource("SomeTestHTML", ofType: "html")!, encoding: NSUTF8StringEncoding)
        
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            html.stringByStrippingHTML()
        }
    }

}
