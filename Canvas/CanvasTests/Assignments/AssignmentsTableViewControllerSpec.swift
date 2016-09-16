//
//  AssignmentsTableViewControllerSpec.swift
//  Canvas
//
//  Created by Nathan Armstrong on 7/27/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import Canvas
import Quick
import Nimble
import SoAutomated
import SoPersistent
import EnrollmentKit

class AssignmentsTableViewControllerSpec: QuickSpec {
    override func spec() {
        describe("AssignmentsTableViewController") {
            context("with mgp") {
                var assignments: AssignmentsTableViewController!
                beforeEach {
                    let courseID = "1811031"
                    let user = User(credentials: .user1)
                    let session = user.session
                    let managedObjectContext = try! session.enrollmentManagedObjectContext()
                    let course = Course.build(managedObjectContext, id: courseID)
                    assignments = try! AssignmentsTableViewController(session: session, courseID: course.id) { _ in }
                }

                describe(".viewWillAppear") {
                    context("when header has been selected") {
                        beforeEach {
                            assignments.header.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .None)
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
