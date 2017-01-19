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
    
    

@testable import Canvas
import Quick
import Nimble
import SoAutomated
import SoPersistent
@testable import EnrollmentKit

class AssignmentsTableViewControllerSpec: QuickSpec {
    override func spec() {
        describe("AssignmentsTableViewController") {
            context("with mgp") {
                var assignments: AssignmentsTableViewController!
                beforeEach {
                    let courseID = "1811031"
                    let user = User(credentials: .user1)
                    let session = user.session
                    let course = Course.build(inSession: session) { $0.id = courseID }
                    assignments = try! AssignmentsTableViewController(session: session, courseID: course.id) { _ in }
                }

                describe(".viewWillAppear") {
                    context("when header has been selected") {
                        beforeEach {
                            assignments.header.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
                            expect(assignments.header.tableView.indexPathsForSelectedRows).toNot(beEmpty())
                        }

                        it("it clears selection") {
                            assignments.viewWillAppear(false)
                            expect(assignments.header.tableView.indexPathsForSelectedRows).toEventually(beNil())
                        }
                    }

                }
            }
        }
    }
}
