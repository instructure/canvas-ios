//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import UIKit
import XCTest
@testable import Student
@testable import Core
import TestsFoundation

class AssignmentListViewControllerTests: StudentTestCase {

    var vc: AssignmentListViewController!
    let courseID = "1"
    let baseURL = URL(string: "https://canvas.instructure.com/")!
    var req: AssignmentListRequestable!
    var gradingPeriods: [APIGradingPeriod] = []
    var groups: [APIAssignmentListGroup] = []

    override func setUp() {
        env.mockStore = false
        vc = AssignmentListViewController.create(env: env, courseID: courseID)
        gradingPeriods = []
        groups = []
    }

    func mockNetwork() {
        api.mock(GetGradingPeriods(courseID: courseID), value: gradingPeriods)
        api.mock(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [ "course_\(courseID)": "#008EE2", ]))
        api.mock(GetCourseRequest(courseID: courseID), value: .make())
        api.mock(req, data: data(groups: groups) )
    }

    func data(groups: [APIAssignmentListGroup]) -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let response = APIAssignmentListResponse(data:
            APIAssignmentListResponse.Data(course:
                APIAssignmentListResponse.Course(
                    groups: APIAssignmentListResponse.GroupNodes(nodes: groups))))

        let data = try! encoder.encode(response)
        return data
    }

    func loadView() {
        vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 800)
        vc.view.layoutIfNeeded()
    }

    func testGeneralViewSetup() {
        //  given
        gradingPeriods = [ .make(title: "grading period a") ]

        var assignmentsGroupA = [
            APIAssignmentListAssignment.make(id: "1", name: "ios 101", dueAt: Date().addDays(1)),
        ]

        var assignmentsGroupB = [
            APIAssignmentListAssignment.make(id: "2", name: "how to cook pizza"),
        ]

        groups = [
            APIAssignmentListGroup.make(id: "1", name: "GroupA", assignments: assignmentsGroupA),
            APIAssignmentListGroup.make(id: "2", name: "GroupB", assignments: assignmentsGroupB),
        ]

        req = AssignmentListRequestable(courseID: courseID, filter: .allGradingPeriods)
        mockNetwork()

        //  when
        loadView()

        //  then
        XCTAssertEqual( vc.gradingPeriodLabel.text, "grading period a" )
        XCTAssertEqual( vc.filterButton.title(for: .normal), "Clear filter" )

        var header: SectionHeaderView? = vc.tableView.headerView(forSection: 0) as? SectionHeaderView
        XCTAssertEqual(header?.titleLabel?.text, "GroupA")

        header = vc.tableView.headerView(forSection: 1) as? SectionHeaderView
        XCTAssertEqual(header?.titleLabel?.text, "GroupB")

        var cell: AssignmentListViewController.ListCell? = vc.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AssignmentListViewController.ListCell
        XCTAssertEqual(cell?.textLabel?.text, "ios 101")

        cell = vc.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? AssignmentListViewController.ListCell
        XCTAssertEqual(cell?.textLabel?.text, "how to cook pizza")

        //  prep for clear filter button push

        assignmentsGroupA = [
            APIAssignmentListAssignment.make(id: "3", name: "ios 202", dueAt: Date().addDays(1)),
        ]

        assignmentsGroupB = [
            APIAssignmentListAssignment.make(id: "4", name: "how to BBQ"),
        ]

        groups = [
            APIAssignmentListGroup.make(id: "3", name: "GroupC", assignments: assignmentsGroupA),
            APIAssignmentListGroup.make(id: "4", name: "GroupD", assignments: assignmentsGroupB),
        ]

        req = AssignmentListRequestable(courseID: courseID, filter: .allGradingPeriods)
        mockNetwork()

        //  clear filter
        XCTAssertNotNil(vc.selectedGradingPeriod)
        vc.filterButton?.sendActions(for: .touchUpInside)
        vc.view.layoutIfNeeded()

        header = vc.tableView.headerView(forSection: 0) as? SectionHeaderView
        XCTAssertEqual(header?.titleLabel?.text, "GroupC")

        header = vc.tableView.headerView(forSection: 1) as? SectionHeaderView
        XCTAssertEqual(header?.titleLabel?.text, "GroupD")

        cell = vc.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AssignmentListViewController.ListCell
        XCTAssertEqual(cell?.textLabel?.text, "ios 202")

        cell = vc.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? AssignmentListViewController.ListCell
        XCTAssertEqual(cell?.textLabel?.text, "how to BBQ")

        XCTAssertEqual( vc.gradingPeriodLabel.text, "All Grading Periods" )
        XCTAssertEqual( vc.filterButton.title(for: .normal), "Filter" )

        //  prep for filter button push

        assignmentsGroupA = [
            APIAssignmentListAssignment.make(id: "7", name: "ios 301", dueAt: Date().addDays(1)),
        ]

        assignmentsGroupB = [
            APIAssignmentListAssignment.make(id: "8", name: "how to test"),
        ]

        groups = [
            APIAssignmentListGroup.make(id: "5", name: "GroupE", assignments: assignmentsGroupA),
            APIAssignmentListGroup.make(id: "6", name: "GroupF", assignments: assignmentsGroupB),
        ]

        req = AssignmentListRequestable(courseID: courseID, filter: .allGradingPeriods)
        mockNetwork()

        // filter by grading period

        vc.filterButton?.sendActions(for: .touchUpInside)
        vc.view.layoutIfNeeded()

        wait(for: [router.showExpectation], timeout: 0.5)

        XCTAssert(router.presented is UIAlertController)

        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Filter by:")

        let alert: UIAlertController? = router.presented as? UIAlertController

        guard let action: AlertAction = alert?.actions.filter({ $0.title == "grading period a" }).first as? AlertAction else { XCTFail("could not get alert action or is nil")
            return
        }

        XCTAssertNotNil(action.handler)
        action.handler?(action)

        vc.view.layoutIfNeeded()

        header = vc.tableView.headerView(forSection: 0) as? SectionHeaderView
        XCTAssertEqual(header?.titleLabel?.text, "GroupE")

        header = vc.tableView.headerView(forSection: 1) as? SectionHeaderView
        XCTAssertEqual(header?.titleLabel?.text, "GroupF")

        cell = vc.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AssignmentListViewController.ListCell
        XCTAssertEqual(cell?.textLabel?.text, "ios 301")

        cell = vc.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? AssignmentListViewController.ListCell
        XCTAssertEqual(cell?.textLabel?.text, "how to test")

        XCTAssertEqual( vc.gradingPeriodLabel.text, "grading period a" )
        XCTAssertEqual( vc.filterButton.title(for: .normal), "Clear filter" )
    }

    func testSelectFirstOnIpad() {
        vc = AssignmentListViewController.create(env: env, courseID: courseID, appTraitCollection: UITraitCollection(horizontalSizeClass: .regular))
        let svc = UISplitViewController(nibName: nil, bundle: nil)
        let nav = UINavigationController(rootViewController: vc)
        svc.viewControllers = [nav, UIViewController()]

        gradingPeriods = [ .make(title: "grading period a") ]

        let assignmentsGroupA = [
            APIAssignmentListAssignment.make(id: "1", name: "ios 101", dueAt: Date().addDays(1)),
        ]

        let assignmentsGroupB = [
            APIAssignmentListAssignment.make(id: "2", name: "how to cook pizza"),
        ]

        groups = [
            APIAssignmentListGroup.make(id: "1", name: "GroupA", assignments: assignmentsGroupA),
            APIAssignmentListGroup.make(id: "2", name: "GroupB", assignments: assignmentsGroupB),
        ]

        req = AssignmentListRequestable(courseID: courseID, filter: .allGradingPeriods)
        mockNetwork()

        loadView()

        let expected = IndexPath(row: 0, section: 0)
        let cell = vc.tableView.cellForRow(at: expected) as? AssignmentListViewController.ListCell
        XCTAssertTrue(cell?.isSelected ?? false)
        XCTAssertEqual(expected, vc.tableView.indexPathForSelectedRow)
    }

    func testDoesNotSelectFirstUnlessInSplitView() {
        vc = AssignmentListViewController.create(env: env, courseID: courseID, appTraitCollection: UITraitCollection(horizontalSizeClass: .regular))
        gradingPeriods = [.make(title: "grading period a")]
        groups = [.make(id: "1", name: "GroupA", assignments: [.make()])]
        req = AssignmentListRequestable(courseID: courseID, filter: .allGradingPeriods)
        mockNetwork()
        loadView()
        let expected = IndexPath(row: 0, section: 0)
        let cell = vc.tableView.cellForRow(at: expected) as! AssignmentListViewController.ListCell
        XCTAssertFalse(cell.isSelected)
    }

    func testPaging() {
        gradingPeriods = [ .make(title: "grading period a") ]
        var assignmentsGroupA1 = [APIAssignmentListAssignment]()
        var assignmentsGroupA2 = [APIAssignmentListAssignment]()

        var count = 5
        for i in 0..<count {
            let a = APIAssignmentListAssignment.make(id: ID("\(i)"), name: "\(i)")
            assignmentsGroupA1.append(a)
        }

        count = 6
        for i in 0..<count {
            let a = APIAssignmentListAssignment.make(id: ID("10\(i)"), name: "\(5+i)")
            assignmentsGroupA2.append(a)
        }

        groups = [
            APIAssignmentListGroup.make(id: "1", name: "GroupA", assignments: assignmentsGroupA1, pageInfo: APIPageInfo(endCursor: "MQ", hasNextPage: true)),
        ]

        req = AssignmentListRequestable(courseID: courseID, filter: .allGradingPeriods)

        let d1 = data(groups: groups)

        groups = [
            APIAssignmentListGroup.make(id: "1", name: "GroupA", assignments: assignmentsGroupA2),
        ]
        let d2 = data(groups: groups)
        var data: [Data] = [d2, d1]
        api.mock(req, data: nil, response: nil, error: nil, dataHandler: { () -> MockURLSession.UrlResponseTuple in
            guard let d = data.popLast() else {
                XCTFail()
                return (nil, nil, nil)
            }
            return (d, nil, nil)
        })
        api.mock(GetGradingPeriods(courseID: courseID), value: gradingPeriods)
        api.mock(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [ "course_\(courseID)": "#008EE2", ]))
        api.mock(GetCourseRequest(courseID: courseID), value: .make())

        loadView()

        XCTAssertEqual( vc.gradingPeriodLabel.text, "grading period a" )
        XCTAssertEqual( vc.filterButton.title(for: .normal), "Clear filter" )

        let rows =  vc.tableView(vc.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rows, 11)

        for i in 0..<rows - 1 {
            let cell = vc.tableView(vc.tableView, cellForRowAt: IndexPath(row: i, section: 0))
            XCTAssertEqual(cell.textLabel?.text, "\(i)")
        }
    }

    func testPaging2() {
        gradingPeriods = [ .make(title: "grading period a") ]
        var assignmentsGroupA1 = [APIAssignmentListAssignment]()
        var assignmentsGroupA2 = [APIAssignmentListAssignment]()

        var assignmentsGroupB1 = [APIAssignmentListAssignment]()
        var assignmentsGroupB2 = [APIAssignmentListAssignment]()

        let firstCount = 5
        for i in 0..<firstCount {
            let a = APIAssignmentListAssignment.make(id: ID("\(i)"), name: "\(i)")
            assignmentsGroupA1.append(a)

            let b = APIAssignmentListAssignment.make(id: ID("20\(i)"), name: "\(i)B")
            assignmentsGroupB1.append(b)
        }

        let count = 6
        for i in 0..<count {
            let a = APIAssignmentListAssignment.make(id: ID("10\(i)"), name: "\(firstCount+i)")
            assignmentsGroupA2.append(a)

            let b = APIAssignmentListAssignment.make(id: ID("300\(i)"), name: "\(firstCount+i)B")
            assignmentsGroupB2.append(b)
        }

        groups = [
            APIAssignmentListGroup.make(id: "1", name: "GroupA", assignments: assignmentsGroupA1, pageInfo: APIPageInfo(endCursor: "MQ", hasNextPage: true)),
            APIAssignmentListGroup.make(id: "2", name: "GroupB", assignments: assignmentsGroupB1, pageInfo: APIPageInfo(endCursor: "MQ", hasNextPage: true)),
        ]

        req = AssignmentListRequestable(courseID: courseID, filter: .allGradingPeriods)

        let d1 = data(groups: groups)

        groups = [
            APIAssignmentListGroup.make(id: "1", name: "GroupA", assignments: assignmentsGroupA2),
            APIAssignmentListGroup.make(id: "2", name: "GroupB", assignments: assignmentsGroupB2),
        ]
        let d2 = data(groups: groups)
        var data: [Data] = [d2, d1]
        let expect = XCTestExpectation(description: "")
        expect.expectedFulfillmentCount = 2

        api.mock(req, data: nil, response: nil, error: nil, dataHandler: { () -> MockURLSession.UrlResponseTuple in
            guard let d = data.popLast() else { XCTFail(); return (nil, nil, nil) }

            return (d, nil, nil)
        })
        api.mock(GetGradingPeriods(courseID: courseID), value: gradingPeriods)
        api.mock(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [ "course_\(courseID)": "#008EE2", ]))
        api.mock(GetCourseRequest(courseID: courseID), value: .make())

        loadView()

        XCTAssertEqual( vc.gradingPeriodLabel.text, "grading period a" )
        XCTAssertEqual( vc.filterButton.title(for: .normal), "Clear filter" )

        var rows =  vc.tableView(vc.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rows, 11)

        for i in 0..<rows - 1 {
            let cell = vc.tableView(vc.tableView, cellForRowAt: IndexPath(row: i, section: 0))
            print(cell.textLabel?.text ?? "")
            XCTAssertEqual(cell.textLabel?.text, "\(i)")
        }

        rows = vc.tableView(vc.tableView, numberOfRowsInSection: 1)
        for i in 0..<rows - 1 {
            let cell = vc.tableView(vc.tableView, cellForRowAt: IndexPath(row: i, section: 1))
            print(cell.textLabel?.text ?? "")
            XCTAssertEqual(cell.textLabel?.text, "\(i)B")
        }
        XCTAssertEqual(rows, 12)
    }

    func testAssignmentForIndexPath() {
        gradingPeriods = [ .make(title: "grading period a") ]

        let assignmentsGroupA = [
            APIAssignmentListAssignment.make(id: "1", name: "ios 101", dueAt: Date().addDays(1)),
        ]

        let assignmentsGroupB = [
            APIAssignmentListAssignment.make(id: "2", name: "how to cook pizza"),
        ]

        groups = [
            APIAssignmentListGroup.make(id: "1", name: "GroupA", assignments: assignmentsGroupA),
            APIAssignmentListGroup.make(id: "2", name: "GroupB", assignments: assignmentsGroupB),
        ]

        req = AssignmentListRequestable(courseID: courseID, filter: .allGradingPeriods)
        mockNetwork()

        loadView()
        vc.viewDidLoad()

        var ip = IndexPath(row: 0, section: 0)
        XCTAssertNotNil( vc.model.assignment(for: ip) )

        ip = IndexPath(row: 100, section: 100)
        XCTAssertNil( vc.model.assignment(for: ip) )
    }
}
