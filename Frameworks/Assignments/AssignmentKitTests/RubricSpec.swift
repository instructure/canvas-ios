//
//  RubricTests.swift
//  Assignments
//
//  Created by Nathan Lambson on 6/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import AssignmentKit
import SoAutomated
import Quick
import Nimble
import Marshal
import TooLegit

class RubricSpec: QuickSpec {
    override func spec() {
        describe("Rubric") {
            var session: Session!
            beforeEach {
                session = User(credentials: .user1).session
            }
            
            describe("updateValues") {
                var rubric: Rubric!
                beforeEach {
                    rubric = Rubric.create(inContext: session.managedObjectContext(Rubric.self))
                }
                
                it("updates values") {
                    try! rubric.updateValues([], rubricSettingsJSON: rubricJSON, assignmentID: "1", inContext: session.managedObjectContext(Rubric.self))
                    expect(rubric.assignmentID) == "1"
                    expect(rubric.title) == "Food Network Cooking"
                    expect(rubric.pointsPossible) == 1900
                    expect(rubric.freeFormCriterionComments) == false
                }
            }
        }
    }
}
