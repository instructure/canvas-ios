//
//  AssignmentsAPISpec.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 10/11/16.
//  Copyright © 2016 instructure. All rights reserved.
//

@testable import AssignmentKit
import Quick
import Nimble
import SoAutomated
import TooLegit
import ReactiveCocoa
import Result
import Marshal

let assignment: JSONShape = [
    "id",
    "course_id",
    "name",
    "html_url",
    "submission_types",
    "points_possible",
    "grading_type",
]

class AssignmentAPISpec: QuickSpec {
    override func spec() {
        describe("Assignments API") {
            let courseID = "1867097"
            let assignmentID = "9599332"
            
            var session: Session!
            beforeEach {
                session = .user1
            }
            
            describe("get assignments") {
                it("should render assignments") {
                    let response = try! Assignment.getAssignments(session, courseID: courseID).waitUntilFirst()
                    expect(response).to(beShapedLike(assignment))
                }
            }

            describe("get assignment") {
                it("should render assignment") {
                    let response = try! Assignment.getAssignment(session, courseID: courseID, assignmentID: assignmentID).waitUntilFirst()
                    expect(response).to(beShapedLike(assignment))
                }
            }
        }
    }
}
