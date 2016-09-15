//
//  Assignment+DetailsTests.swift
//  Assignments
//
//  Created by Nathan Lambson on 6/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import CoreData
@testable import AssignmentKit
import SoAutomated
import TooLegit
import DoNotShipThis
import SoPersistent
import ReactiveCocoa

class AssignmentDetailsTests: UnitTestCase {
    let session = Session.ns
    var context: NSManagedObjectContext!
    var vc: Assignment.DetailViewController!
    var assignment: Assignment!
    var observer: ManagedObjectObserver<Assignment>!
    let detailsFactory: Assignment->[SimpleAssignmentDVM] = { return [SimpleAssignmentDVM(title: $0.name)] }

    override func setUp() {
        super.setUp()
        attempt {
            context = try session.assignmentsManagedObjectContext()
            assignment = Assignment.build(context, id: "9091235", courseID: "1140383", name: "Assignment Detail View Controller Test")
            try! context.save()
            
            observer = try Assignment.observer(session, courseID: "1140383", assignmentID: "9091235")
            
            let dataSource = try! Assignment.detailsTableViewDataSource(session, courseID: assignment.courseID, assignmentID: assignment.id, detailsFactory: detailsFactory)
            vc = Assignment.DetailViewController(dataSource: dataSource, refresher: nil)
            
            let _ = vc.view // trigger viewDidLoad
            vc.prepare(observer, refresher: nil, detailsFactory: detailsFactory)
        }
    }
    
    func test_itDisplaysLocalDetails() {
        let tableView = vc.tableView
        let titleCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual("Assignment Detail View Controller Test", titleCell?.textLabel?.text)
    }
    
    func test_itRefreshesDetails() {
        stub(session, "assignment-details") { expectation in
            let refresher = try! Assignment.refresher(self.session, courseID: self.assignment.courseID, assignmentID: self.assignment.id)
            self.vc.refresher = refresher

            refresher.refreshingCompleted.observeNext { [weak self] error in
                self?.refreshCompletedWithExpectation(expectation)(error)
            }
            refresher.refresh(true)
        }
        
        if #available(iOS 8.3, *) {
            context.refreshAllObjects()
        } else {
            // Fallback on earlier versions
        }
        let titleCell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertNotEqual("Assignment Detail View Controller Test", titleCell?.textLabel?.text)
        XCTAssertNotEqual("Assignment Detail View Controller Test", assignment.name)
    }
}
