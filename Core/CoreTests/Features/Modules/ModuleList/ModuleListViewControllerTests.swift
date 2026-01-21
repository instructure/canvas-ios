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

import Foundation
import CoreData
import SafariServices
import XCTest
@testable import Core
import TestsFoundation

class ModuleListViewControllerTests: CoreTestCase {

    private static let testData = (
        date1: Date.make(year: 2019, month: 12, day: 25, hour: 14, minute: 24, second: 37),
        date2: Date.make(year: 2021, month: 5, day: 6),
        date3: Date.make(year: 2021, month: 11, day: 24)
    )
    private lazy var testData = Self.testData

    private lazy var viewController = ModuleListViewController.create(env: environment, courseID: "1")
    private var save: XCTestExpectation?

    override func setUp() {
        super.setUp()
        PublishedIconView.isAutohideEnabled = false
        api.mock(viewController.courses, value: .make(id: "1", name: "Course 1", default_view: .modules))
        api.mock(viewController.tabs, value: [.make(id: "modules")])
        UIView.setAnimationsEnabled(false)
    }

    func testViewDidLoad() throws {
        api.mock(viewController.colors, value: APICustomColors(custom_colors: ["course_1": "#fff"]))
        mockRequests(
            modules: [.make(id: "1", items: nil)],
            moduleItems: [
                "1": [
                    .make(
                        id: "1",
                        position: 0,
                        title: "Item 1",
                        content_details: .make(
                            due_at: testData.date1,
                            points_possible: 10
                        ),
                        completion_requirement: .make(type: .min_score, completed: false, min_score: 8.0)
                    ),
                    .make(
                        id: "2",
                        position: 1,
                        content: .file("2"),
                        content_details: .make(
                            due_at: nil,
                            points_possible: 10,
                            locked_for_user: true,
                            lock_explanation: "Reasons"
                        ),
                        completion_requirement: nil
                    ),
                    .make(
                        id: "3",
                        position: 2,
                        content_details: nil,
                        completion_requirement: .make(type: .must_view, completed: false)
                    ),
                    .make(
                        id: "4",
                        content_details: nil,
                        completion_requirement: .make(type: .must_submit, completed: true)
                    )
                ]
            ],
            discussionCheckpoints: [
                "2": .make(checkpoints: [
                    .make(tag: "reply_to_topic", dueAt: testData.date2),
                    .make(tag: "reply_to_entry", dueAt: testData.date3)
                ]),
                "3": .make(checkpoints: [
                    .make(tag: "reply_to_topic", dueAt: nil),
                    .make(tag: "reply_to_entry", dueAt: testData.date1)
                ])
            ]
        )
        let nav = UINavigationController(rootViewController: viewController)
        loadView()

        let item1 = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(item1.nameLabel.text, "Item 1")
        XCTAssertEqual(item1.dueDateLabel1.text, testData.date1.dateTimeString)
        XCTAssertEqual(item1.dueDateLabel2.text, nil)
        XCTAssertEqual(item1.miscSubtitleLabel.text, "10 pts | Score at least 8")
        XCTAssertContains(item1.accessibilityLabel, "10 points, Score at least 8")
        XCTAssertFalse(item1.completedStatusView.isHidden)
        XCTAssertEqual(item1.completedStatusView.image, .emptyLine)
        let item2 = moduleItemCell(at: IndexPath(row: 1, section: 0))
        XCTAssertEqual(item2.dueDateLabel1.text, testData.date2.dateTimeString)
        XCTAssertEqual(item2.dueDateLabel2.text, testData.date3.dateTimeString)
        XCTAssertEqual(item2.miscSubtitleLabel.text, "10 pts")
        XCTAssertContains(item2.accessibilityLabel, "10 points")
        XCTAssertFalse(item2.isUserInteractionEnabled)
        XCTAssertFalse(item2.nameLabel.isEnabled)
        XCTAssertTrue(item2.completedStatusView.isHidden)
        let item3 = moduleItemCell(at: IndexPath(row: 2, section: 0))
        XCTAssertEqual(item3.dueDateLabel1.text, DueDateFormatter.noDueDateText)
        XCTAssertEqual(item3.dueDateLabel2.text, testData.date1.dateTimeString)
        XCTAssertEqual(item3.miscSubtitleLabel.text, "View")
        XCTAssertContains(item3.accessibilityLabel, "View")
        let item4 = moduleItemCell(at: IndexPath(row: 3, section: 0))
        XCTAssertEqual(item4.miscSubtitleLabel.text, "Submitted")
        XCTAssertContains(item4.accessibilityLabel, "Submitted")
        XCTAssertFalse(item4.completedStatusView.isHidden)
        XCTAssertEqual(item4.completedStatusView.image, .checkLine)

        XCTAssertNotNil(nav.viewControllers.first)

        if #available(iOS 26, *) {
            XCTAssertEqual(viewController.navigationItem.title, "Modules")
            XCTAssertEqual(viewController.navigationItem.subtitle, "Course 1")
        } else {
            XCTAssertEqual(viewController.titleSubtitleView.title, "Modules")
            XCTAssertEqual(viewController.titleSubtitleView.subtitle, "Course 1")
            XCTAssertEqual(
                viewController.navigationController?.navigationBar.barTintColor!.hexString,
                UIColor(hexString: "#fff")!.darkenToEnsureContrast(against: .textLightest.variantForLightMode).hexString)
        }
    }

    func testLockedForUserDoesNotApplyToTeachers() {
        environment.app = .teacher
        mockRequests(
            modules: [.make(id: "1", items: nil)],
            moduleItems: [
                "1": [
                    .make(
                        id: "1",
                        position: 1,
                        content_details: .make(
                            due_at: nil,
                            points_possible: 10,
                            locked_for_user: true,
                            lock_explanation: "Reasons"
                        ),
                        completion_requirement: nil
                    )
                ]
            ]
        )
        loadView()
        let item1 = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertTrue(item1.isUserInteractionEnabled)
        XCTAssertTrue(item1.nameLabel.isEnabled)
    }

    func testLockedForUserDisablesCell() {
        environment.app = .student
        mockRequests(
            modules: [.make(id: "1", items: nil)],
            moduleItems: [
                "1": [
                    .make(
                        id: "1",
                        position: 1,
                        content: .file("1"),
                        content_details: .make(
                            due_at: nil,
                            points_possible: 10,
                            locked_for_user: true,
                            lock_explanation: "Reasons"
                        ),
                        completion_requirement: nil
                    )
                ]
            ]
        )
        loadView()
        let item1 = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertFalse(item1.isUserInteractionEnabled)
        XCTAssertFalse(item1.nameLabel.isEnabled)
    }

    func testTableViewSort() {
        mockRequests(
            modules: [
                .make(id: "1", name: "B", position: 2, published: true, items: nil),
                .make(id: "2", name: "A", position: 1, published: false, items: nil)
            ],
            moduleItems: [
                "1": [
                    .make(id: "1", position: 1, title: "B1"),
                    .make(id: "2", position: 2, title: "B2", published: true)
                ],
                "2": [
                    .make(id: "3", position: 3, title: "A1", published: false)
                ]
            ]
        )
        loadView()
        // published/unpublished is not included because dependency is not injected
        XCTAssertEqual(header(forSection: 0).titleLabel.text, "A")
        XCTAssertEqual(header(forSection: 0).accessibilityLabel, "A, expanded")
        XCTAssert(header(forSection: 0).accessibilityTraits.contains(.button))
        XCTAssertEqual(moduleItemCell(at: IndexPath(row: 0, section: 0)).nameLabel.text, "A1")
        XCTAssertEqual(moduleItemCell(at: IndexPath(row: 0, section: 0)).accessibilityLabel, "assignment, A1")
        XCTAssertEqual(header(forSection: 1).titleLabel.text, "B")
        XCTAssertEqual(header(forSection: 1).accessibilityLabel, "B, expanded")
        XCTAssertEqual(moduleItemCell(at: IndexPath(row: 0, section: 1)).nameLabel.text, "B1")
        XCTAssertEqual(moduleItemCell(at: IndexPath(row: 1, section: 1)).nameLabel.text, "B2")
        XCTAssertEqual(moduleItemCell(at: IndexPath(row: 1, section: 1)).accessibilityLabel, "assignment, B2")
    }

    func testEmptyItems() {
        mockRequests(
            modules: [.make(id: "1")],
            moduleItems: ["1": []]
        )
        loadView()
        XCTAssert(viewController.emptyView.isHidden)
        let emptyCell = viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ModuleListViewController.EmptyCell
        XCTAssertFalse(emptyCell.isUserInteractionEnabled)
    }

    func testNoModules() {
        mockRequests(modules: [])
        loadView()
        XCTAssertEqual(viewController.emptyView.isHidden, false)
        XCTAssertEqual(viewController.emptyTitleLabel.text, "No Modules")
        XCTAssertEqual(viewController.emptyMessageLabel.text, "There are no modules to display yet.")
    }

    func testError() {
        api.mock(GetModulesRequest(courseID: "1", include: []), error: NSError.internalError())
        loadView()
        XCTAssertEqual(viewController.errorView.isHidden, false)
        XCTAssertEqual(viewController.errorView.messageLabel.text, "There was an error loading modules.")

        mockRequests(modules: [])
        viewController.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        drainMainQueue()
        XCTAssertEqual(viewController.errorView.isHidden, true)
        XCTAssertEqual(viewController.emptyView.isHidden, false)
    }

    func testScrollsToModule() {
        mockRequests(
            modules: [
                .make(id: "1", position: 1),
                .make(id: "2", position: 2),
                .make(id: "3", position: 3),
                .make(id: "4", position: 4),
                .make(id: "5", position: 5),
                .make(id: "6", position: 6),
                .make(id: "7", position: 7)
            ],
            moduleItems: [
                "1": [.make(id: "1")],
                "2": [.make(id: "2")],
                "3": [.make(id: "3")],
                "4": [.make(id: "4")],
                "5": [.make(id: "5")],
                "6": [.make(id: "6")],
                "7": [.make(id: "7")]
            ]
        )
        let viewController = ModuleListViewController.create(env: environment, courseID: "1", moduleID: "5")
        viewController.view.layoutIfNeeded()
        drainMainQueue()
        XCTAssertEqual(viewController.tableView.numberOfSections, 7)
        XCTAssertGreaterThan(viewController.tableView.contentOffset.y, 0)
    }

    func testGetNextPageOfItems() throws {
        let link = "https://canvas.instructure.com/courses/1/modules/1/items?page=2"
        let next = HTTPURLResponse(next: link)
        api.mock(GetModulesRequest(courseID: "1", include: []), value: [.make(id: "1", items: nil)])
        api.mock(GetModuleItemsRequest(courseID: "1", moduleID: "1", include: [.content_details, .mastery_paths]), value: [.make(id: "1")], response: next)
        api.mock(GetNextRequest<[APIModuleItem]>(path: link), value: [.make(id: "2")])
        api.mock(GetModuleItemsDiscussionCheckpointsRequest(courseId: "1"), value: .make())
        loadView()
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 2)
        XCTAssertNotNil(viewController.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ModuleItemCell)
    }

    func testLoadingFirstPage() {
        let task = api.mock(GetModulesRequest(courseID: "1", include: []), value: [])
        api.mock(GetModuleItemsDiscussionCheckpointsRequest(courseId: "1"), value: .make())
        task.suspend()
        loadView()
        XCTAssertEqual(viewController.spinnerView.isHidden, false)
        XCTAssertEqual(viewController.errorView.isHidden, true)
        task.resume()
        drainMainQueue()
        XCTAssertEqual(viewController.spinnerView.isHidden, true)
    }

    func testGetNextPage() {
        mockRequests(modules: [])
        loadView()
        let link = "https://canvas.instructure.com/courses/1/modules?page=2"
        let next = HTTPURLResponse(next: link)
        let one = APIModule.make(id: "1", position: 1, items: nil)
        let two = APIModule.make(id: "2", position: 2, items: nil)
        api.mock(GetModulesRequest(courseID: "1", include: []), value: [one], response: next)
        api.mock(GetNextRequest<[APIModule]>(path: link), value: [two])
        api.mock(GetModuleItemsRequest(courseID: "1", moduleID: "1", include: [.content_details, .mastery_paths]), value: [])
        api.mock(GetModuleItemsRequest(courseID: "1", moduleID: "2", include: [.content_details, .mastery_paths]), value: [.make()])
        api.mock(GetModuleItemsDiscussionCheckpointsRequest(courseId: "1"), value: .make())
        viewController.tableView.refreshControl?.sendActions(for: .valueChanged)
        drainMainQueue()
        XCTAssertEqual(viewController.tableView.numberOfSections, 2)
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
    }

    func testCollapsingSections() throws {
        mockRequests(
            modules: [.make(id: "3453243", name: "Module 1")],
            moduleItems: ["3453243": []]
        )
        loadView()
        drainMainQueue()
        let before = header(forSection: 0)
        XCTAssertTrue(before.isExpanded)
        XCTAssertEqual(before.accessibilityLabel, "Module 1, expanded")
        before.handleTap()
        let after = header(forSection: 0)
        XCTAssertFalse(after.isExpanded)
        XCTAssertEqual(before.accessibilityLabel, "Module 1, expanded")

        let viewController = ModuleListViewController.create(env: environment, courseID: "1")
        viewController.view.layoutIfNeeded()
        drainMainQueue()
        let later = viewController.tableView.headerView(forSection: 0) as! ModuleSectionHeaderView
        XCTAssertFalse(later.isExpanded)
        header(forSection: 0).handleTap()
        XCTAssertTrue(header(forSection: 0).isExpanded)
    }

    func testSubHeaders() throws {
        mockRequests(
            modules: [.make(id: "1")],
            moduleItems: [
                "1": [
                    .make(
                        id: "1",
                        title: "I am a sub header",
                        indent: 2,
                        content: .subHeader,
                        published: true
                    ),
                    .make(
                        id: "2",
                        title: "other subheader",
                        indent: 2,
                        content: .subHeader,
                        published: false
                    )
                ]
            ]
        )
        loadView()
        // published/unpublished is not included because dependency is not injected
        let cell = try XCTUnwrap(viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ModuleItemCell)
        XCTAssertEqual(cell.nameLabel.text, "I am a sub header")
        XCTAssertEqual(cell.indentConstraint.constant, 20)
        XCTAssertTrue(cell.isUserInteractionEnabled)
        XCTAssertEqual(cell.accessibilityLabel, "I am a sub header")
        let other = try XCTUnwrap(viewController.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ModuleItemCell)
        XCTAssertEqual(other.accessibilityLabel, "other subheader")

    }

    func testCellPointsLabelWhenQuantitativeDataEnabled() {
        // Given
        mockCourseAndModuleItemWith(restrict_quantitative_data: true)

        // When
        loadView()

        // Then
        let cell = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertTrue(cell.miscSubtitleLabel.isHidden)
        XCTAssertNotContains(cell.accessibilityLabel, "10 points")
    }

    func testCellPointsLabelWhenQuantitativeDataDisabled() {
        // Given
        mockCourseAndModuleItemWith(restrict_quantitative_data: false)

        // When
        loadView()

        // Then
        let cell = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.miscSubtitleLabel.text, "10 pts")
        XCTAssertContains(cell.accessibilityLabel, "10 points")
    }

    func testCellPointsLabelWhenQuantitativeDataNotSpecified() {
        // Given
        mockCourseAndModuleItemWith(restrict_quantitative_data: nil)

        // When
        loadView()

        // Then
        let cell = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.miscSubtitleLabel.text, "10 pts")
        XCTAssertContains(cell.accessibilityLabel, "10 points")
    }

    func testSelectItem() {
        mockRequests(
            modules: [.make(id: "1")],
            moduleItems: [
                "1": [
                    .make(id: "1", content: .assignment("1"), html_url: URL(string: "/courses/1/modules/items/1")!),
                    .make(id: "2", content: .page("2"))
                ]
            ]
        )
        loadView()
        viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(router.lastRoutedTo(URL(string: "/courses/1/modules/items/1")!, withOptions: .detail))
        XCTAssertNoThrow(viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 99)))
        XCTAssertNoThrow(viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 99, section: 0)))
    }

    func testAutomaticallyChangesSelectionInSplitView() {
        mockRequests(
            modules: [.make(id: "1")],
            moduleItems: [
                "1": [
                    .make(id: "1", position: 1, content: .assignment("1"), html_url: URL(string: "/courses/1/modules/items/1")!),
                    .make(id: "2", position: 2, content: .page("2"))
                ]
            ]
        )
        let svc = MockSplitViewController()
        svc.mockCollapsed = false
        svc.viewControllers = [viewController]
        svc.addChild(viewController)
        loadView()
        viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNoThrow(viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 99)))
        viewController.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        XCTAssertEqual(viewController.tableView.indexPathForSelectedRow, IndexPath(row: 0, section: 0))
        NotificationCenter.default.post(name: .moduleItemViewDidLoad, object: nil, userInfo: ["moduleID": "1", "itemID": "2"])
        XCTAssertEqual(viewController.tableView.indexPathForSelectedRow, IndexPath(row: 1, section: 0))
    }

    func testViewWillAppearDeselectsSelectedRow() {
        mockRequests(
            modules: [.make(id: "1")],
            moduleItems: [
                "1": [
                    .make(content: .assignment("1"))
                ]
            ]
        )
        loadView()
        viewController.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        XCTAssertNotNil(viewController.tableView.indexPathForSelectedRow)
        viewController.viewWillAppear(false)
        XCTAssertNil(viewController.tableView.indexPathForSelectedRow)
    }

    func testModuleItemRequirementCompleted() {
        mockRequests(
            modules: [.make(id: "1")],
            moduleItems: [
                "1": [
                    .make(id: "1", completion_requirement: .make(type: .must_view, completed: false))
                ]
            ]
        )
        loadView()
        var cell = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.miscSubtitleLabel.text, "View")
        mockRequests(
            modules: [.make(id: "1")],
            moduleItems: [
                "1": [
                    .make(id: "1", completion_requirement: .make(type: .must_view, completed: true))
                ]
            ]
        )
        NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
        drainMainQueue()
        cell = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.miscSubtitleLabel.text, "Viewed")
        XCTAssertTrue(viewController.errorView.isHidden)
    }

    func testLockedMasteryPath() {
        mockRequests(
            modules: [.make(id: "1")],
            moduleItems: [
                "1": [
                    .make(id: "1", title: "Unlockable", mastery_paths: .make(locked: true))
                ]
            ]
        )
        loadView()
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 2)
        let item = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(item.nameLabel.text, "Unlockable")
        let path = moduleItemCell(at: IndexPath(row: 1, section: 0))
        XCTAssertEqual(path.nameLabel.text, "Locked until \"Unlockable\" is graded")
        XCTAssertTrue(path.miscSubtitleLabel.isHidden)
    }

    func testMasteryPath() {
        mockRequests(
            modules: [.make(id: "1")],
            moduleItems: [
                "1": [
                    .make(id: "1", title: "Unlockable", mastery_paths: .make(locked: false, assignment_sets: [
                        .make(assignments: [.make(model: .make())])
                    ]))
                ]
            ]
        )
        let task = api.mock(
            PostSelectMasteryPath(courseID: "1", moduleID: "1", moduleItemID: "1", assignmentSetID: "1"),
            value: APINoContent()
        )
        task.suspend()
        loadView()
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 2)
        let item = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(item.nameLabel.text, "Unlockable")
        let path = moduleItemCell(at: IndexPath(row: 1, section: 0))
        XCTAssertEqual(path.nameLabel.text, "Select a Path")
        XCTAssertEqual(path.miscSubtitleLabel.text, "1 Option")
        XCTAssertContains(path.accessibilityLabel, "1 Option")
        XCTAssertEqual((path.accessoryView as? UIImageView)?.image, UIImage.masteryPathsLine)
        viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        mockRequests(
            modules: [.make(id: "1")],
            moduleItems: [
                "1": [
                    .make(id: "1", title: "Unlocked", mastery_paths: nil)
                ]
            ]
        )
        let masteryPath = router.last as! MasteryPathViewController
        XCTAssertTrue(viewController.spinnerView.isHidden)
        masteryPath.delegate?.didSelectMasteryPath(id: "1", inModule: "1", item: "1")
        XCTAssertFalse(viewController.spinnerView.isHidden)
        task.resume()
        drainMainQueue()
        XCTAssertTrue(viewController.spinnerView.isHidden)
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
    }

    func testLockedByPrerequisiteModule() {
        mockRequests(
            modules: [
                .make(id: "1", name: "Module 1", position: 0, state: .unlocked),
                .make(id: "2", position: 1, prerequisite_module_ids: ["1"], state: .locked)
            ],
            moduleItems: [
                "1": [.make(id: "1")],
                "2": [.make(id: "2")]
            ]
        )
        loadView()
        let header1 = header(forSection: 0)
        XCTAssertTrue(header1.lockedButton.isHidden)
        let header2 = header(forSection: 1)
        XCTAssertFalse(header2.lockedButton.isHidden)
        header2.lockedButton.sendActions(for: .primaryActionTriggered)
        let alert = router.presented as! UIAlertController
        XCTAssertEqual(alert.title, "Locked")
        XCTAssertEqual(alert.message, "Prerequisite: Module 1")
    }

    func testLockedByDate() {
        let now = DateComponents(calendar: .current, year: 2020, month: 9, day: 14).date!
        Clock.mockNow(now)
        mockRequests(
            modules: [
                .make(id: "1", name: "Module 1", position: 0, state: .unlocked),
                .make(id: "2", position: 1, state: .locked, unlock_at: now.addDays(1))
            ],
            moduleItems: [
                "1": [.make(id: "1")],
                "2": [.make(id: "2")]
            ]
        )
        loadView()
        let header1 = header(forSection: 0)
        XCTAssertTrue(header1.lockedButton.isHidden)
        let header2 = header(forSection: 1)
        XCTAssertFalse(header2.lockedButton.isHidden)
        header2.lockedButton.sendActions(for: .primaryActionTriggered)
        let alert = router.presented as! UIAlertController
        XCTAssertEqual(alert.title, "Locked")
        XCTAssertEqual(alert.message, "Will unlock " + now.addDays(1).dateTimeString)
        Clock.reset()
    }

    func testQuizLTIIcon() {
        mockRequests(
            modules: [.make(id: "1")],
            moduleItems: [
                "1": [
                    .make(id: "1", title: "", content: .assignment("1"), quiz_lti: false),
                    .make(id: "2", title: "", content: .assignment("2"), quiz_lti: true)
                ]
            ]
        )
        loadView()
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 2)
        let cell0 = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell0.iconView.image, .assignmentLine)
        let cell1 = moduleItemCell(at: IndexPath(row: 1, section: 0))
        XCTAssertEqual(cell1.iconView.image, .quizLine)
    }

    func testModulesPageDisabled() {
        api.mock(viewController.courses, value: .make(id: "1", name: "Course 1", default_view: .assignments))
        api.mock(viewController.tabs, value: [.make(id: "assignments")])
        mockRequests(
            modules: [.make(id: "1")],
            moduleItems: [
                "1": [
                    .make(content: .assignment("1"))
                ]
            ]
        )
        loadView()
        XCTAssertFalse(viewController.errorView.isHidden)
        XCTAssertTrue(viewController.emptyView.isHidden)
        XCTAssertEqual(viewController.errorView.messageLabel.text, "This page has been disabled for this course.")
        XCTAssertEqual(viewController.tableView!.dataSource!.numberOfSections?(in: viewController.tableView!), 0)
    }

    // MARK: - Private helpers

    private func mockRequests(
        courseId: String = "1",
        modules: [APIModule],
        moduleItems: [String: [APIModuleItem]] = [:],
        discussionCheckpoints: [String: APIModuleItemsDiscussionCheckpoints.Data] = [:]
    ) {
        api.mock(GetModulesRequest(courseID: courseId, include: []), value: modules)

        for module in modules {
            let items = moduleItems[module.id.value] ?? []
            api.mock(
                GetModuleItemsRequest(courseID: courseId, moduleID: module.id.value, include: [.content_details, .mastery_paths]),
                value: items
            )
        }

        api.mock(
            GetModuleItemsDiscussionCheckpointsRequest(courseId: courseId),
            value: .make(dataPerModuleItemId: discussionCheckpoints)
        )
    }

    private func mockCourseAndModuleItemWith(restrict_quantitative_data: Bool?) {
        api.mock(
            GetCourse(courseID: "1"),
            value: .make(
                settings: APICourseSettings(
                    usage_rights_required: nil,
                    syllabus_course_summary: nil,
                    restrict_quantitative_data: restrict_quantitative_data,
                    hide_final_grade: nil
                )
            )
        )
        mockRequests(
            courseId: "1",
            modules: [.make(id: "1", items: nil)],
            moduleItems: [
                "1": [
                    .make(
                        id: "1",
                        position: 1,
                        content: .file("1"),
                        content_details: .make(
                            due_at: nil,
                            points_possible: 10,
                            locked_for_user: true,
                            lock_explanation: "Reasons"
                        ),
                        completion_requirement: nil
                    )
                ]
            ]
        )
    }

    private func loadView() {
        viewController.view.layoutIfNeeded()
        drainMainQueue() // needed for DispatchGroup.notify in GetModules
    }

    private func moduleItemCell(at indexPath: IndexPath) -> ModuleItemCell {
        viewController.tableView.cellForRow(at: indexPath) as! ModuleItemCell
    }

    private func header(forSection section: Int) -> ModuleSectionHeaderView {
        viewController.tableView(viewController.tableView, viewForHeaderInSection: section) as! ModuleSectionHeaderView
    }
}

private class MockSplitViewController: UISplitViewController {
    var mockCollapsed: Bool?
    override var isCollapsed: Bool {
        return mockCollapsed ?? super.isCollapsed
    }
}
