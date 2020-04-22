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
    class MockSplitViewController: UISplitViewController {
        var mockCollapsed: Bool?
        override var isCollapsed: Bool {
            return mockCollapsed ?? super.isCollapsed
        }
    }

    lazy var viewController = ModuleListViewController.create(courseID: "1")
    var save: XCTestExpectation?

    override func setUp() {
        super.setUp()
        environment.mockStore = false
        PublishedIconView.isAutohideEnabled = false
        api.mock(viewController.courses, value: .make(id: "1", name: "Course 1"))
        UIView.setAnimationsEnabled(false)
    }

    func moduleItemCell(at indexPath: IndexPath) -> ModuleItemCell {
        return viewController.tableView.cellForRow(at: indexPath) as! ModuleItemCell
    }

    func header(forSection section: Int) -> ModuleSectionHeaderView {
        return viewController.tableView(viewController.tableView, viewForHeaderInSection: section) as! ModuleSectionHeaderView
    }

    func testViewDidLoad() throws {
        api.mock(viewController.colors, value: APICustomColors(custom_colors: ["course_1": "#fff"]))
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [
            .make(id: "1", items: [
                .make(
                    id: "1",
                    position: 0,
                    title: "Item 1",
                    content_details: .make(
                        due_at: Date(fromISOString: "2019-12-25T14:24:37Z")!,
                        points_possible: 10
                    ),
                    completion_requirement: .make(type: .min_score, completed: false, min_score: 8.0)
                ),
                .make(
                    id: "2",
                    position: 1,
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
                ),
            ]),
        ])
        let nav = UINavigationController(rootViewController: viewController)
        viewController.view.layoutIfNeeded()
        let item1 = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(item1.nameLabel.text, "Item 1")
        XCTAssertEqual(item1.dueLabel.text, "Dec 25, 2019 | 10 pts | Score at least 8")
        let item2 = moduleItemCell(at: IndexPath(row: 1, section: 0))
        XCTAssertEqual(item2.dueLabel.text, "10 pts")
        XCTAssertFalse(item2.isUserInteractionEnabled)
        XCTAssertFalse(item2.nameLabel.isEnabled)
        let item3 = moduleItemCell(at: IndexPath(row: 2, section: 0))
        XCTAssertEqual(item3.dueLabel.text, "View")
        let item4 = moduleItemCell(at: IndexPath(row: 3, section: 0))
        XCTAssertEqual(item4.dueLabel.text, "Submitted")
        XCTAssertNotNil(nav.viewControllers.first)
        let footer = try XCTUnwrap(viewController.tableView.tableFooterView as? UILabel)
        XCTAssertEqual(footer.text, "Loading more modules...")
        XCTAssertTrue(footer.isHidden)
        XCTAssertEqual(viewController.titleSubtitleView.title, "Modules")
        XCTAssertEqual(viewController.titleSubtitleView.subtitle, "Course 1")
        XCTAssertEqual(viewController.navigationController?.navigationBar.barTintColor, UIColor(hexString: "#fff"))
    }

    func testTableViewSort() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [
            .make(id: "1", name: "B", position: 2, published: true, items: [
                .make(id: "1", position: 1, title: "B1"),
                .make(id: "2", position: 2, title: "B2", published: true),
            ]),
            .make(id: "2", name: "A", position: 1, published: false, items: [
                .make(id: "3", position: 3, title: "A1", published: false),
            ]),
        ])
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(header(forSection: 0).titleLabel.text, "A")
        XCTAssertEqual(header(forSection: 0).publishedIconView.published, false)
        XCTAssertEqual(header(forSection: 0).accessibilityLabel, "A, unpublished, expanded")
        XCTAssert(header(forSection: 0).accessibilityTraits.contains(.button))
        XCTAssertEqual(moduleItemCell(at: IndexPath(row: 0, section: 0)).nameLabel.text, "A1")
        XCTAssertEqual(moduleItemCell(at: IndexPath(row: 0, section: 0)).accessibilityLabel, "A1, unpublished")
        XCTAssertEqual(header(forSection: 1).titleLabel.text, "B")
        XCTAssertEqual(header(forSection: 1).publishedIconView.published, true)
        XCTAssertEqual(header(forSection: 1).accessibilityLabel, "B, published, expanded")
        XCTAssertEqual(moduleItemCell(at: IndexPath(row: 0, section: 1)).nameLabel.text, "B1")
        XCTAssertEqual(moduleItemCell(at: IndexPath(row: 1, section: 1)).nameLabel.text, "B2")
        XCTAssertEqual(moduleItemCell(at: IndexPath(row: 1, section: 1)).accessibilityLabel, "B2, published")
    }

    func testLoadingItems() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [.make(id: "1", items: nil)])
        let task = api.mock(GetModuleItemsRequest(courseID: "1", moduleID: "1", include: [.content_details]), value: [.make()])
        task.paused = true
        viewController.view.layoutIfNeeded()
        XCTAssertNotNil(viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LoadingCell)
        task.paused = false
        XCTAssertNotNil(viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ModuleItemCell)
    }

    func testEmptyItems() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [.make(id: "1", items: [])])
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(viewController.emptyView.isHidden, true)
        XCTAssertNotNil(viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ModuleListViewController.EmptyCell)
    }

    func testNoModules() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [])
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(viewController.emptyView.isHidden, false)
        XCTAssertEqual(viewController.emptyTitleLabel.text, "No Modules")
        XCTAssertEqual(viewController.emptyMessageLabel.text, "There are no modules to display yet.")
    }

    func testError() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), error: NSError.internalError())
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(viewController.errorView.isHidden, false)
        XCTAssertEqual(viewController.errorView.messageLabel.text, "There was an error loading modules. Pull to refresh to try again.")

        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [])
        viewController.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(viewController.errorView.isHidden, true)
        XCTAssertEqual(viewController.emptyView.isHidden, false)
    }

    func testDoesNotScrollWithoutModuleID() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [
            .make(id: "1", position: 1),
            .make(id: "2", position: 2),
            .make(id: "3", position: 3),
            .make(id: "4", position: 4),
            .make(id: "5", position: 5),
            .make(id: "6", position: 6),
            .make(id: "7", position: 7),
            .make(id: "8", position: 8),
            .make(id: "9", position: 9),
            .make(id: "10", position: 10),
        ])
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(viewController.tableView.numberOfSections, 10)
        XCTAssertEqual(viewController.tableView.contentOffset.y, 0)
    }

    func testScrollsToModule() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [
            .make(id: "1", position: 1),
            .make(id: "2", position: 2),
            .make(id: "3", position: 3),
            .make(id: "4", position: 4),
            .make(id: "5", position: 5),
            .make(id: "6", position: 6),
            .make(id: "7", position: 7),
            .make(id: "8", position: 8),
            .make(id: "9", position: 9),
            .make(id: "10", position: 10),
        ])
        let viewController = ModuleListViewController.create(courseID: "1", moduleID: "10")
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(viewController.tableView.numberOfSections, 10)
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 9), 1)
        XCTAssertGreaterThan(viewController.tableView.contentOffset.y, 0)

        let cached = ModuleListViewController.create(courseID: "1", moduleID: "10")
        cached.view.layoutIfNeeded()
        XCTAssertGreaterThan(cached.tableView.contentOffset.y, 0)
    }

    func testScrollsToPaginatedModule() {
        let link = "https://canvas.instructure.com/courses/1/modules?page=2"
        let next = HTTPURLResponse(next: link)
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [
            .make(id: "1", position: 1),
            .make(id: "2", position: 2),
            .make(id: "3", position: 3),
            .make(id: "4", position: 4),
            .make(id: "5", position: 5),
        ], response: next)
        api.mock(GetNextRequest<[APIModule]>(path: link), value: [
            .make(id: "6", position: 6),
            .make(id: "7", position: 7),
            .make(id: "8", position: 8),
            .make(id: "9", position: 9),
            .make(id: "10", position: 10),
        ])
        let viewController = ModuleListViewController.create(courseID: "1", moduleID: "10")
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(viewController.tableView.numberOfSections, 10)
        XCTAssertGreaterThan(viewController.tableView.contentOffset.y, 0)
    }

    func testModuleWithTooManyItems() {
        let module = APIModule.make(id: "1", items: nil)
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [module])
        let item = APIModuleItem.make(title: "Item 1 of many")
        api.mock(GetModuleItemsRequest(courseID: "1", moduleID: "1", include: [.content_details]), value: [item])
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
        let cell = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.nameLabel.text, "Item 1 of many")
        XCTAssertEqual(viewController.tableView.contentOffset.y, 0)
    }

    func testGetNextPageOfItems() throws {
        let link = "https://canvas.instructure.com/courses/1/modules/1/items?page=2"
        let next = HTTPURLResponse(next: link)
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [.make(id: "1", items: nil)])
        api.mock(GetModuleItemsRequest(courseID: "1", moduleID: "1", include: [.content_details]), value: [.make(id: "1")], response: next)
        let task = api.mock(GetNextRequest<[APIModuleItem]>(path: link), value: [.make(id: "2")])
        task.paused = true
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 2)
        XCTAssertNotNil(viewController.tableView.cellForRow(at: IndexPath(row: 1, section: 0)))
        task.paused = false
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 2)
        XCTAssertNotNil(viewController.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ModuleItemCell)
    }

    func testLoadingFirstPage() {
        let task = api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [])
        task.paused = true
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(viewController.spinnerView.isHidden, false)
        task.paused = false
        XCTAssertEqual(viewController.spinnerView.isHidden, true)
    }

    func testLoadingNextPage() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [])
        let link = "https://canvas.instructure.com/courses/1/modules?page=2"
        let next = HTTPURLResponse(next: link)
        let one = APIModule.make(id: "1", items: [])
        let two = APIModule.make(id: "2", items: [])
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [one], response: next)
        let task = api.mock(GetNextRequest<[APIModule]>(path: link), value: [two])
        task.paused = true
        viewController.view.layoutIfNeeded()
        XCTAssertEqual(viewController.tableView.numberOfSections, 1)
        XCTAssertEqual(viewController.tableView.tableFooterView?.isHidden, false)
        XCTAssertEqual(viewController.tableView.contentInset.bottom, 0)
        task.paused = false
        XCTAssertEqual(viewController.tableView.numberOfSections, 2)
        XCTAssertEqual(viewController.tableView.tableFooterView?.isHidden, true)
        XCTAssertEqual(viewController.tableView.contentInset.bottom, -20)
    }

    func testGetNextPageWithTooManyItems() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [])
        viewController.view.layoutIfNeeded()
        let link = "https://canvas.instructure.com/courses/1/modules?page=2"
        let next = HTTPURLResponse(next: link)
        let one = APIModule.make(id: "1", position: 1, items: [.make()])
        let two = APIModule.make(id: "2", position: 2, items: nil)
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [one], response: next)
        api.mock(GetNextRequest<[APIModule]>(path: link), value: [two])
        api.mock(GetModuleItemsRequest(courseID: "1", moduleID: "2", include: [.content_details]), value: [.make()])
        viewController.tableView.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertEqual(viewController.tableView.numberOfSections, 2)
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
    }

    func testCollapsingSections() throws {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [.make(id: "3453243", name: "Module 1")])
        viewController.view.layoutIfNeeded()
        let before = header(forSection: 0)
        XCTAssertTrue(before.isExpanded)
        XCTAssertEqual(before.accessibilityLabel, "Module 1, published, expanded")
        before.handleTap()
        let after = header(forSection: 0)
        XCTAssertFalse(after.isExpanded)
        XCTAssertEqual(before.accessibilityLabel, "Module 1, published, expanded")

        let viewController = ModuleListViewController.create(courseID: "1")
        viewController.view.layoutIfNeeded()
        let later = viewController.tableView.headerView(forSection: 0) as! ModuleSectionHeaderView
        XCTAssertFalse(later.isExpanded)
        header(forSection: 0).handleTap()
        XCTAssertTrue(header(forSection: 0).isExpanded)
    }

    func testSubHeaders() throws {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [
            .make(items: [
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
                ),
            ]),
        ])
        viewController.view.layoutIfNeeded()
        let cell = try XCTUnwrap(viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ModuleItemSubHeaderCell)
        XCTAssertEqual(cell.label.text, "I am a sub header")
        XCTAssertEqual(cell.indentConstraint.constant, 20)
        XCTAssertEqual(cell.publishedIconView.published, true)
        XCTAssertFalse(cell.isUserInteractionEnabled)
        XCTAssertEqual(cell.accessibilityLabel, "I am a sub header, published")
        let other = try XCTUnwrap(viewController.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ModuleItemSubHeaderCell)
        XCTAssertEqual(other.accessibilityLabel, "other subheader, unpublished")

    }

    func testSelectItem() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [
            .make(id: "1", items: [
                .make(id: "1", content: .assignment("1"), html_url: URL(string: "/courses/1/modules/items/1")!),
                .make(id: "2", content: .page("2")),
            ]),
        ])
        viewController.view.layoutIfNeeded()
        viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(router.lastRoutedTo(URL(string: "/courses/1/modules/items/1")!, withOptions: .detail))
        XCTAssertNoThrow(viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 99)))
        XCTAssertNoThrow(viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 99, section: 0)))
    }

    func testAutomaticallyChangesSelectionInSplitView() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [
            .make(id: "1", items: [
                .make(id: "1", position: 1, content: .assignment("1"), html_url: URL(string: "/courses/1/modules/items/1")!),
                .make(id: "2", position: 2, content: .page("2")),
            ]),
        ])
        let svc = MockSplitViewController()
        svc.mockCollapsed = false
        svc.viewControllers = [viewController]
        viewController.view.layoutIfNeeded()
        viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNoThrow(viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 99)))
        viewController.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        XCTAssertEqual(viewController.tableView.indexPathForSelectedRow, IndexPath(row: 0, section: 0))
        NotificationCenter.default.post(name: .moduleItemViewDidLoad, object: nil, userInfo: ["moduleID": "1", "itemID": "2"])
        XCTAssertEqual(viewController.tableView.indexPathForSelectedRow, IndexPath(row: 1, section: 0))
    }

    func testViewWillAppearDeselectsSelectedRow() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [.make(items: [.make(content: .assignment("1"))])])
        viewController.view.layoutIfNeeded()
        viewController.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        XCTAssertNotNil(viewController.tableView.indexPathForSelectedRow)
        viewController.viewWillAppear(false)
        XCTAssertNil(viewController.tableView.indexPathForSelectedRow)
    }

    func testModuleItemRequirementCompleted() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [
            .make(id: "1", items: [
                .make(id: "1", completion_requirement: .make(type: .must_view, completed: false)),
            ]),
        ])
        viewController.view.layoutIfNeeded()
        var cell = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.dueLabel.text, "View")
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [
            .make(id: "1", items: [
                .make(id: "1", completion_requirement: .make(type: .must_view, completed: true)),
            ]),
        ])
        NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
        cell = moduleItemCell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.dueLabel.text, "Viewed")
        XCTAssertTrue(viewController.errorView.isHidden)
    }
}
