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
