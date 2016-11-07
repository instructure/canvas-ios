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
