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
import FileKit
import SoLazy
import MobileCoreServices
import Result

class AssignmentSpec: QuickSpec {
    override func spec() {
        describe("assignment model") {
            var assignment: Assignment!
            var session: Session!
            beforeEach {
                session = .user1
                assignment = Assignment(inContext: session.managedObjectContext(Assignment.self))
            }

            describe("grade") {
                it("should change based on grading type") {
                    assignment.gradingType = .notGraded
                    assignment.currentGrade = ""
                    expect(assignment.grade) == "n/a"

                    assignment.gradingType = .letterGrade
                    assignment.currentGrade = "A-"
                    expect(assignment.grade) == "A-"
                    assignment.currentGrade = ""
                    expect(assignment.grade) == "-"

                    assignment.gradingType = .gpaScale
                    assignment.currentGrade = "3.7"
                    expect(assignment.grade) == "3.7"
                    assignment.currentGrade = ""
                    expect(assignment.grade) == "-"

                    assignment.gradingType = .passFail
                    assignment.currentGrade = "P"
                    expect(assignment.grade) == "P"
                    assignment.currentGrade = ""
                    expect(assignment.grade) == "-"

                    assignment.gradingType = .percent
                    assignment.currentGrade = "90%"
                    expect(assignment.grade) == "90%"
                    assignment.currentGrade = ""
                    expect(assignment.grade) == "-"

                    assignment.gradingType = .points
                    assignment.currentGrade = ""
                    assignment.pointsPossible = 100
                    expect(assignment.grade) == "-/100"
                    assignment.currentGrade = "10"
                    expect(assignment.grade) == "10/100"
                    assignment.currentGrade = "Not a number"
                    expect(assignment.grade) == "-/100"

                    assignment.gradingType = .error
                    assignment.currentGrade = ""
                    expect(assignment.grade) == "-"
                }
            }

            describe("due status") {
                context("when the assignment is submitted online and is past due") {
                    beforeEach {
                        var json = assignmentJSON
                        let due = Date(year: 2000, month: 1, day: 1)
                        json["due_at"] = jsonify(date: due)
                        json["submission_types"] = ["external_tool"]
                        json["has_submitted_submissions"] = false
                        json["locked_for_user"] = false
                        Clock.timeTravel(to: Date(year: 2000, month: 1, day: 2)) {
                            try! assignment.updateValues(json, inContext: assignment.managedObjectContext!)
                        }
                    }

                    it("should be Overdue") {
                        expect(assignment.rawDueStatus) == DueStatus.Overdue.rawValue
                    }
                }

                context("when the submission type is not online and due date is in the past") {
                    it("should be past due") {
                        var json = assignmentJSON
                        let due = Date(year: 2000, month: 1, day: 1)
                        json["submission_types"] = ["on_paper"]
                        json["due_at"] = jsonify(date: due)
                        Clock.timeTravel(to: Date(year: 2000, month: 1, day: 2)) {
                            try! assignment.updateValues(json, inContext: assignment.managedObjectContext!)
                        }
                        expect(assignment.rawDueStatus) == DueStatus.Past.rawValue
                    }
                }

                context("when the assignment has been graded and it is past due with no submission") {
                    it("should be marked as Past, not Overdue") {
                        var json = assignmentJSON
                        let due = Date(year: 2016, month: 9, day: 1)
                        json["due_at"] = jsonify(date: due)
                        let graded = Date(year: 2016, month: 10, day: 1)
                        json["submission"] = ["graded_at": jsonify(date: graded), "workflow_state": "graded", "grade": "A"]
                        Clock.timeTravel(to: Date(year: 2016, month: 10, day: 2)) {
                            try! assignment.updateValues(json, inContext: assignment.managedObjectContext!)
                        }
                        expect(assignment.rawDueStatus) == DueStatus.Past.rawValue
                    }
                }

                context("when the assignment is upcoming") {
                    beforeEach {
                        var json = assignmentJSON
                        let due = Date(year: 2000, month: 1, day: 1)
                        json["due_at"] = jsonify(date: due)
                        Clock.timeTravel(to: Date(year: 1999, month: 12, day: 1)) {
                            try! assignment.updateValues(json, inContext: assignment.managedObjectContext!)
                        }
                    }
                    
                    it("should be upcoming") {
                        expect(assignment.rawDueStatus) == DueStatus.Upcoming.rawValue
                    }
                }
            }

            describe("submission types") {
                it("should convert from json") {
                    var json = assignmentJSON
                    json["submission_types"] = [
                        "external_tool",
                        "discussion_topic",
                        "online_quiz"
                    ]
                    try! assignment.updateValues(json, inContext: assignment.managedObjectContext!)
                    expect(assignment.submissionTypes.contains(.externalTool)) == true
                    expect(assignment.submissionTypes.contains(.discussionTopic)) == true
                    expect(assignment.submissionTypes.contains(.quiz)) == true
                }

                it("should not allow an empty html url with quiz type") {
                    var json = assignmentJSON
                    json["submission_types"] = ["online_quiz"]
                    json["html_url"] = ""
                    expect {
                        try assignment.updateValues(json, inContext: assignment.managedObjectContext!)
                    }.to(throwError())
                }
            }

            describe("assignment refreshers") {
                describe("refresher(session:courseID:gradingPeriodID:)") {
                    var session: Session!
                    beforeEach {
                        session = User(credentials: .user4).session
                    }
                    
                    it("should create assignments") {
                        let count = Assignment.observeCount(inSession: session)
                        let refresher = try! Assignment.refresher(session, courseID: "1867097", gradingPeriodID: nil)
                        expect {
                            refresher.playback("assignment-grades", with: session)
                        }.to(change({ count.currentCount }, from: 0, to: 14))
                    }

                    it("should create assignment groups") {
                        let count = AssignmentGroup.observeCount(inSession: session)
                        let refresher = try! Assignment.refresher(session, courseID: "1867097", gradingPeriodID: nil)
                        expect {
                            refresher.playback("assignment-grades", in: currentBundle, with: session)
                        }.to(change({ count.currentCount }, from: 0, to: 3))
                    }

                    it("should link assignments to their assignment group") {
                        let assignment = Assignment.build(inSession: session) {
                            $0.id = "9599332"
                            $0.courseID = "1867097"
                            $0.assignmentGroup = nil
                        }

                        let refresher = try! Assignment.refresher(session, courseID: "1867097", gradingPeriodID: nil)
                        
                        refresher.playback("assignment-grades", in: currentBundle, with: session)
                        expect(assignment.reload().assignmentGroup?.name).to(equal("Group 1"))
                    }

                    context("with multiple grading periods") {
                        beforeEach {
                            session = User(credentials: .mgpUser1).session
                        }

                        it("should update assignment grading period id") {
                            let assignment = Assignment.build(inSession: session) {
                                $0.id = "1"
                                $0.gradingPeriodID = nil
                            }

                            let refresher = try! Assignment.refresher(session, courseID: "1", gradingPeriodID: "1")

                            refresher.playback("assignment-grades-mgp", in: currentBundle, with: session)
                            expect(assignment.reload().gradingPeriodID) == "1"
                        }
                    }
                }
            }
        }
    }
}
