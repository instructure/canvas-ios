//
//  PatheticTests.swift
//  PatheticTests
//
//  Created by Derrick Hathaway on 7/19/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import Pathetic

class PatheticTests: XCTestCase {
    
    func testRoot() {
        XCTAssertNotNil(root.match("/"))
        XCTAssertNil(root.match(""))
        XCTAssertNil(root.match("//"))
    }
    
    func testOneLiteral() {
        let path = /"cats"
        XCTAssertNotNil(path.match("/cats"))
        XCTAssertNil(path.match("cats"))
    }
    
    func testOneParameter() {
        let path = /integer
        XCTAssertEqual(path.match("/14"), 14)
    }
    
    func testOneOfEach() {
        let nCats = /double/"cats"
        XCTAssertEqual(nCats.match("/3.14/cats"), 3.14)
    }
    
    func testLotsOfParams() {
        let nNString = /integer/double/string
        
        XCTAssertEqual(nNString.match("/4/31.1/uptown")?.0, 4)
        XCTAssertEqual(nNString.match("/4/31.1/uptown")?.1, 31.1)
        XCTAssertEqual(nNString.match("/4/31.1/uptown")?.2, "uptown")
    }
    
    func testEveryOther() {
        let evenOddEvenOdd = /integer/"odd"/double/"odd"
        
        XCTAssertEqual(evenOddEvenOdd.match("/2/odd/4.0/odd")?.0, 2)
        XCTAssertEqual(evenOddEvenOdd.match("/2/odd/4.0/odd")?.1, 4.0)
    }
    
    func testIntComponents() {
        let someDate = /2016/12/1
        
        XCTAssertNotNil(someDate.match("/2016/12/1"))
    }
    
    func testACoupleOfStrings() {
        let catsAndDogs = /"cats"/"dogs"
        
        XCTAssertNotNil(catsAndDogs.match("/cats/dogs"))
        XCTAssertNil(catsAndDogs.match("/cats/frogs"))
    }

    
    func testLotsAndLots() {
        // for some reason Swift 3 beta 3 has a problem with /integer/integer/integer, but if you break it out it's fine with it.
        let lots = /integer/integer
        let lotsAndLots = lots/integer
        
        XCTAssertEqual(lots.match("/1/2")?.0, 1)
        XCTAssertEqual(lotsAndLots.match("/1/2/3")?.2, 3)
    }
    
    
    func testLargish() {
        let course = /"api"/"v1"/"courses"/integer
        let submission = course/"assignments"/integer/"submissions"/integer
        
        let path = "/api/v1/courses/341/assignments/99/submissions/57"
        XCTAssertEqual(submission.match(path)?.0, 341)
        XCTAssertEqual(submission.match(path)?.1, 99)
        XCTAssertEqual(submission.match(path)?.2, 57)
    }
    
    func testYMD() {
        let year = /"y"/integer
        let dateComponents = year/"m"/integer/"d"/integer
        
        let datePath: PathTemplate<Date> = dateComponents.map { (y, m, d) in
            var components = DateComponents()
            components.year = y
            components.month = m
            components.day = d
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(secondsFromGMT: 0)!
            return cal.date(from: components)
        }
        
        let d = Date(timeIntervalSinceReferenceDate: 0)
        XCTAssertEqual(datePath.match("/y/2001/m/1/d/1"), d)
    }
    
    
    func testOptionalRoot() {
        let optRoot = /?"cats"
        
        XCTAssertNotNil(optRoot.match("cats"))
        XCTAssertNotNil(optRoot.match("/cats"))
        XCTAssertNil(optRoot.match("dogs"))
        
        let optDouble = /?double
        
        XCTAssertEqual(optDouble.match("/3.14159"), 3.14159)
        XCTAssertEqual(optDouble.match("3.14159"), 3.14159)
    }
    
    
    func testOptionalLongish() {
        let courses = /?"api"/"v1"/?"courses"
        let course = courses/integer
        let assignments = course/"assignments"/integer

        XCTAssertNotNil(courses.match("/api/v1/courses"))
        XCTAssertNotNil(courses.match("api/v1/courses"))
        XCTAssertNotNil(courses.match("/courses"))
        XCTAssertNotNil(courses.match("courses"))
        XCTAssertNil(courses.match("cookies"))
        
        let optionalWithParam = /"api"/"v1"/?integer
        XCTAssertEqual(optionalWithParam.match("/12"), 12)
        XCTAssertEqual(optionalWithParam.match("24"), 24)
        
        
        let submissionAPIURL = URL(string: "https://mobiledev.instructure.com/api/v1/courses/32/assignments/55")!
        XCTAssertEqual(assignments.match(submissionAPIURL.path)?.0, 32)
        XCTAssertEqual(assignments.match(submissionAPIURL.path)?.1, 55)

        let submissionURL = URL(string: "https://mobiledev.instructure.com/courses/11/assignments/19")!
        XCTAssertEqual(assignments.match(submissionURL.path)?.0, 11)
        XCTAssertEqual(assignments.match(submissionURL.path)?.1, 19)
        
        let hardKnocks = (0..<5000).map { _ in URL(string: "https://hardknocks.instructure.com/api/v1/courses/\(arc4random())/assignments/\(arc4random())")! }
        
        measure {
            for url in hardKnocks {
                let (_, _) = assignments.match(url.path)!
            }
        }
    }

    
    func testTheLimits() {
        let abcd = /"a"/"b"/"c"/"d"/"e"/"f"/"g"/"h"
        
        XCTAssertNotNil(abcd.match("/a/b/c/d/e/f/g/h"))
        
        let x6 = /integer/integer/double/double/string/string
        XCTAssertEqual(x6.match("/1/2/3.14/1.8/cat/cow")?.0, 1)
        XCTAssertEqual(x6.match("/1/2/3.14/1.8/cat/cow")?.1, 2)
        XCTAssertEqual(x6.match("/1/2/3.14/1.8/cat/cow")?.2, 3.14)
        XCTAssertEqual(x6.match("/1/2/3.14/1.8/cat/cow")?.3, 1.8)
        XCTAssertEqual(x6.match("/1/2/3.14/1.8/cat/cow")?.4, "cat")
        XCTAssertEqual(x6.match("/1/2/3.14/1.8/cat/cow")?.5, "cow")
    }
}
