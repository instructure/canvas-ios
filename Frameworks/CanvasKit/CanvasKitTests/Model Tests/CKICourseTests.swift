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

import UIKit
import XCTest

class CKICourseTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        
        XCTAssertEqual(course.id!, "1", "course id was not parsed correctly")
        XCTAssertEqual(course.name!, "Beginning iOS Development", "course name was not parsed correctly")
        XCTAssertEqual(course.sisCourseID!, "2", "course sisCourseID was not parsed correctly")
        XCTAssertEqual(course.workflowState!, "available", "course workflowState was not parsed correctly")
        XCTAssertEqual(course.courseCode!, "iOS_101", "course courseCode was not parsed correctly")
        XCTAssertEqual(course.accountID!, "1", "course accountID was not parsed correctly")
        
        var formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2010-12-02T00:00:00-07:00")
        XCTAssertEqual(course.startAt!, date, "course startAt was not parsed correctly")
        
        date = formatter.dateFromString("2010-14-02T00:00:00-07:00")
        XCTAssertEqual(course.endAt!, date, "course endAt was not parsed correctly")
        XCTAssertNil(course.enrollments, "course enrollments was not parsed correctly")
        XCTAssertNil(course.term, "course term was not parsed correctly")
        
        let url = NSURL(string:"https://mobiledev.instructure.com/feeds/calendars/course_56093f00-e060-012d-6ee9-4040654c8f83.ics")
        XCTAssertEqual(course.calendar!, url!, "course calendar was not parsed correctly")
        XCTAssertEqual(course.defaultView!, "wiki", "course defaultView was not parsed correctly")
        XCTAssertEqual(course.syllabusBody!, "<p>syllabus html goes here</p>", "course syllabusBody was not parsed correctly")
        XCTAssertEqual(course.needsGradingCount, 17, "course needsGradingCount was not parsed correctly")
        XCTAssert(course.applyAssignmentGroupWeights, "course applyAssignmentGroupWeights was not parsed correctly")
        XCTAssert(course.publicSyllabus, "course publicSyllabus was not parsed correctly")
        XCTAssert(course.canCreateDiscussionTopics, "course canCreateDiscussionTopics was not parsed correctly")
        XCTAssertFalse(course.hideFinalGrades, "course hideFinalGrades was not parsed correctly")

        XCTAssertEqual(course.path!, "/api/v1/courses/1", "course path was not parsed correctly")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
