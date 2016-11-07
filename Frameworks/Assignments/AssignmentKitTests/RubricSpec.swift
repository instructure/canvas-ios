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
