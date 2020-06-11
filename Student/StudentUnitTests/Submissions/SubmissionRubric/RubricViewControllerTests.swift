//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import XCTest
import UIKit
@testable import Student
@testable import Core
@testable import TestsFoundation

class RubricViewControllerTests: StudentTestCase {
    let courseID = "1"
    let assignmentID = "1"
    let userID = "1"
    var vc: RubricViewController!

    override func setUp() {
        super.setUp()
        vc = RubricViewController.create(courseID: courseID, assignmentID: assignmentID, userID: userID)
    }

    func loadView() {
        vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 800)
        vc.view.layoutIfNeeded()
    }

    func testRenderWithNoRubricSettings() {
        api.mock(vc.presenter!.colors, value: APICustomColors(custom_colors: [ "course_1": "#f00" ]))
        api.mock(vc.presenter!.courses, value: .make())

        let ratings: [APIRubricRating] = [
            APIRubricRating.make(id: "1", points: 10, description: "A", long_description: "this is A", assignmentID: "1", position: 0),
            APIRubricRating.make(id: "2", points: 20, description: "B", long_description: "this is B", assignmentID: "1", position: 1),
            APIRubricRating.make(id: "3", points: 30, description: "C", long_description: "this is C", assignmentID: "1", position: 2),
        ]
        let rubric = APIRubric.make(ratings: ratings)

        let assessment = APIRubricAssessment.make(submissionID: "1", points: 30, comments: "meh", rating_id: "3")
        let map: [String: APIRubricAssessment] = [rubric.id.value: assessment]
        let s = APISubmission.make(rubric_assessment: map)

        let a = APIAssignment.make(submission: s, rubric: [rubric])
        api.mock(vc.presenter!.assignments, value: a)

        loadView()

        let stack: UIStackView = vc.contentStackView
        let ratingContainer = stack.viewWithTag(vc.ratingContainerTag)
        let circleView = stack.viewWithTag(vc.circleViewTag) as? RubricCircleView
        XCTAssertTrue(ratingContainer?.isHidden == false)
        XCTAssertEqual(3, circleView?.subviews.count)
    }

    func testRenderWithHidesPointsAndFreeformComments() {
        api.mock(vc.presenter!.colors, value: APICustomColors(custom_colors: [ "course_1": "#f00" ]))
        api.mock(vc.presenter!.courses, value: .make())

        let ratings: [APIRubricRating] = [
            APIRubricRating.make(id: "1", points: 10, description: "A", long_description: "this is A", assignmentID: "1", position: 0),
            APIRubricRating.make(id: "2", points: 20, description: "B", long_description: "this is B", assignmentID: "1", position: 1),
            APIRubricRating.make(id: "3", points: 30, description: "C", long_description: "this is C", assignmentID: "1", position: 2),
        ]
        let rubric = APIRubric.make(ratings: ratings)

        let s = APISubmission.make()
        let rubricSettings: APIRubricSettings = .make(hides_points: true, free_form_criterion_comments: true)
        let a = APIAssignment.make(submission: s, rubric: [rubric], rubric_settings: rubricSettings)

        api.mock(vc.presenter!.assignments, value: a)

        loadView()

        let stack: UIStackView = vc.contentStackView
        let ratingContainer = stack.viewWithTag(vc.ratingContainerTag)
        let circleView = stack.viewWithTag(vc.circleViewTag) as? RubricCircleView
        XCTAssertFalse(ratingContainer?.isHidden == false)
        XCTAssertEqual(0, circleView?.subviews.count)
    }
}
