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

class CKIAssignmentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let assignmentDictionary = Helpers.loadJSONFixture("assignment") as NSDictionary
        let assignment = CKIAssignment(fromJSONDictionary: assignmentDictionary)
        
        XCTAssertEqual(assignment.id!, "4", "Assignment id did not parse correctly")
        XCTAssertEqual(assignment.name!, "some assignment", "Assignment name did not parse correctly")
        XCTAssertEqual(assignment.position, 1, "Assignment position did not parse correctly")
        XCTAssertEqual(assignment.descriptionHTML!, "<p>Do the following:</p>...", "Assignment descriptionHTML did not parse correctly")
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2012-07-01T23:59:00-06:00")
        XCTAssertEqual(assignment.dueAt!, date, "Assignment dueAt did not parse correctly")
        XCTAssertEqual(assignment.lockAt!, date, "Assignment lockAt did not descriptionHTML correctly")
        XCTAssertEqual(assignment.unlockAt!, date, "Assignment unlockAt did not parse correctly")
        XCTAssertEqual(assignment.courseID!, "123", "Assignment courseID did not parse correctly")
        
        var url = NSURL(string:"http://canvas.example.com/courses/123/assignments/4")
        XCTAssertEqual(assignment.htmlURL!, url!, "Assignment htmlURL did not parse correctly")
        XCTAssertEqual(assignment.allowedExtensions.count, 2, "Assignment allowedExtensions did not parse correctly")
        XCTAssertEqual(assignment.assignmentGroupID!, "2", "Assignment assignmentGroupID did not parse correctly")
        XCTAssertEqual(assignment.groupCategoryID!, "1", "Assignment groupCategoryID did not parse correctly")
        XCTAssert(assignment.muted, "Assignment muted did not parse correctly")
        XCTAssert(assignment.published, "Assignment published did not parse correctly")
        XCTAssertEqual(assignment.pointsPossible, 12, "Assignment pointsPossible did not parse correctly")
        XCTAssert(assignment.gradeGroupStudentsIndividually, "Assignment gradeGroupStudentsIndividually did not parse correctly")
        XCTAssertEqual(assignment.gradingType!, "points", "Assignment gradingType did not parse correctly")
        XCTAssertEqual(assignment.scoringType, CKIAssignmentScoringType.Points, "Assignment scoringType did not parse correctly")
        XCTAssertEqual(assignment.submissionTypes.count, 1, "Assignment submissionTypes did not parse correctly")
        XCTAssert(assignment.lockedForUser, "Assignment lockedForUser did not parse correctly")
        XCTAssertEqual(assignment.needsGradingCount, UInt(17), "Assignment needsGradingCount did not parse correctly")
        XCTAssertNotNil(assignment.rubric, "Assignment rubric did not parse correctly")
        XCTAssert(assignment.peerReviewRequired, "Assignment peerReviewRequired did not parse correctly")
        XCTAssert(assignment.peerReviewsAutomaticallyAssigned, "Assignment peerReviewsAutomaticallyAssigned did not parse correctly")
        XCTAssertEqual(assignment.peerReviewsAutomaticallyAssignedCount, 2, "Assignment peerReviewsAutomaticallyAssignedCount did not parse correctly")
        XCTAssertEqual(assignment.peerReviewDueDate!, date, "Assignment peerReviewDueDate did not parse correctly")
        XCTAssertEqual(assignment.path!, "/api/v1/assignments/4", "Assignment path did not parse correctly")
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
