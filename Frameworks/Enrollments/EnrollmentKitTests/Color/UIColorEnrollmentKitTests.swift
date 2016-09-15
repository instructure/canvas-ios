//
//  TestUIColorHEX.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 3/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
import UIKit

func Assert(hex: String, red: CGFloat, green: CGFloat, blue: CGFloat, file: StaticString = #file, line: UInt = #line) {

    guard let color = UIColor.colorFromHexString(hex) else { XCTFail(file: file, line: line); return }

    var r = CGFloat(), g = CGFloat(), b = CGFloat()
    color.getRed(&r, green: &g, blue: &b, alpha: nil)

    XCTAssertEqual(r, red, file: file, line: line)
    XCTAssertEqual(g, green, file: file, line: line)
    XCTAssertEqual(b, blue, file: file, line: line)
}

class TestUIColorHEX: XCTestCase {
    
    func test0000FF() {
        Assert("#0000FF", red: 0, green: 0, blue: 1)
    }
    
    func test00FF00() {
        Assert("#00FF00", red: 0, green: 1, blue: 0)
    }
    
    func testFF0000() {
        Assert("#FF0000", red: 1, green: 0, blue: 0)
    }
    
    func test010101() {
        Assert("#010101", red: 1/255.0, green: 1/255.0, blue: 1/255.0)
    }
    
    func test101010() {
        Assert("#101010", red: 0x10/255.0, green: 0x10/255.0, blue: 0x10/255.0)
    }
    
    func testabc() {
        Assert("#abc", red: 0xaa/255.0, green: 0xbb/255.0, blue: 0xcc/255.0)
    }
    
    func test000000() {
        Assert("#000000", red: 0, green: 0, blue: 0)
    }
    
    func test555533() {
        Assert("555533", red: 0x55/255.0, green: 0x55/255.0, blue: 0x33/255.0)
    }
}
