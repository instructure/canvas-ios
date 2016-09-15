//
//  RubricDetailsSpec.swift
//  Assignments
//
//  Created by Ben Kraus on 7/29/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import AssignmentKit
import XCTest
import CoreData
import SoAutomated
import TooLegit
import DoNotShipThis
import SoPersistent
import Quick
import Nimble

class RubricDetailsSpec: QuickSpec {
    override func spec() {
        describe("Rubric Details") {
            let session = Session.ns
            var context: NSManagedObjectContext!
            var rubric: Rubric!
            var vc: Rubric.DetailViewController!
            var observer: ManagedObjectObserver<Rubric>!
            let detailsFactory: Rubric->[SimpleRubricDVM] = { return [SimpleRubricDVM(title: $0.title, pointsPossible: $0.pointsPossible)] }

            beforeEach {
                context = try! session.assignmentsManagedObjectContext()
                rubric = Rubric.build(inContext: context, courseID: "1140383", assignmentID: "9091235", title: "Rubric Detail View Controller Test", pointsPossible: NSNumber(int: 10))
                try! context.save()

                observer = try! Rubric.observer(session, courseID: "1140383", assignmentID: "9091235")

                let dataSource = try! Rubric.detailsTableViewDataSource(session, courseID: rubric.courseID!, assignmentID: rubric.assignmentID, detailsFactory: detailsFactory)
                vc = Rubric.DetailViewController(dataSource: dataSource)

                let _ = vc.view
                vc.prepare(observer, refresher: nil, detailsFactory: detailsFactory)
            }

            it("displays local details") {
                let tableView = vc.tableView
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                expect(cell?.textLabel?.text) == "Rubric Detail View Controller Test - 10 points possible"
            }
        }
    }
}