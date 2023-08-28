//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Core
import XCTest
@testable import TestsFoundation
import Combine

class ModuleItemDetailsViewControllerTests: CoreTestCase {
    class DetailViewController: UIViewController {}

    var subscriptions = Set<AnyCancellable>()
    lazy var controller = ModuleItemDetailsViewController.create(courseID: "1", moduleID: "2", itemID: "3")

    override func tearDown() {
        super.tearDown()
        subscriptions.removeAll()
    }

    func testLayout() {
        router.mock("/courses/1/files/2?origin=module_item_details") {
            FileDetailsViewController.create(context: .course("1"), fileID: "2")
        }
        api.mock(controller.store, value: .make(
            id: "3",
            content: .file("2"),
            url: URL(string: "/courses/1/files/2")!
        ))
        api.mock(controller.course, value: .make(id: "1", name: "Course One"))
        api.mock(controller.colors, value: APICustomColors(custom_colors: [ "course_1": "#f00" ]))
        controller.view.layoutIfNeeded()
        XCTAssertTrue(controller.errorView.isHidden)
        XCTAssertTrue(controller.lockedView.isHidden)
        XCTAssertFalse(controller.container.isHidden)
        XCTAssertNotNil(controller.children.first as? FileDetailsViewController)
        XCTAssertEqual(controller.titleSubtitleView.title, "File Details")
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Course One")
    }

    func testError() {
        router.mock("/?origin=module_item_details") { DetailViewController() }
        api.mock(controller.store, error: NSError.internalError())
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.errorView.isHidden)
        XCTAssertTrue(controller.container.isHidden)

        api.mock(controller.store, value: .make(id: "3", url: URL(string: "/")))
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(controller.errorView.isHidden)
        XCTAssertFalse(controller.container.isHidden)
    }

    func testExternalURL() {
        api.mock(controller.store, value: .make(
            id: "3",
            title: "URL Item Title",
            content: .externalURL(URL(string: "https://apple.com")!)
        ))
        controller.view.layoutIfNeeded()
        let details = controller.children.first as! ExternalURLViewController
        XCTAssertEqual(details.name, "URL Item Title")
        XCTAssertEqual(details.url, URL(string: "https://apple.com"))
        XCTAssertEqual(details.courseID, "1")
    }

    func testExternalTool() {
        api.mock(controller.store, value: .make(
            id: "3",
            title: "LTI Item Title",
            content: .externalTool("5", URL(string: "https://lti.app")!)
        ))
        controller.view.layoutIfNeeded()
        let details = controller.children.first as! LTIViewController
        XCTAssertEqual(details.tools.context.contextType, .course)
        XCTAssertEqual(details.tools.context.id, "1")
        XCTAssertEqual(details.tools.id, "5")
        XCTAssertEqual(details.tools.launchType, .module_item)
        XCTAssertEqual(details.tools.moduleID, "2")
        XCTAssertEqual(details.tools.moduleItemID, "3")
        XCTAssertEqual(details.name, "LTI Item Title")
    }

    func testLockedForUser() {
        api.mock(controller.store, value: .make(
            id: "3",
            title: "This is a page",
            content: .page("1"),
            content_details: .make(locked_for_user: true, lock_explanation: "Locked for reasons")
        ))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.children.count, 0)
        XCTAssertFalse(controller.lockedView.isHidden)
        XCTAssertEqual(controller.lockedTitleLabel.text, "This is a page")
    }

    func testLockedForUserTeacherApp() {
        environment.app = .teacher
        router.mock("/courses/1/quizzes/2?origin=module_item_details") {
            DetailViewController()
        }
        api.mock(controller.store, value: .make(
            id: "3",
            title: "Discuss this thing!",
            content: .quiz("2"),
            url: URL(string: "/courses/1/quizzes/2")!,
            content_details: .make(locked_for_user: true, lock_explanation: "Locked for reasons")
        ))
        controller.view.layoutIfNeeded()
        XCTAssertNotNil(controller.children.first as? DetailViewController)
        XCTAssertTrue(controller.lockedView.isHidden)
    }

    func testAssignmentLockedForUser() {
        router.mock("/courses/1/assignments/2?origin=module_item_details") {
            DetailViewController()
        }
        api.mock(controller.store, value: .make(
            id: "3",
            title: "Submit this thing!",
            content: .assignment("2"),
            url: URL(string: "/courses/1/assignments/2")!,
            content_details: .make(locked_for_user: true, lock_explanation: "Locked for reasons")
        ))
        controller.view.layoutIfNeeded()
        XCTAssertNotNil(controller.children.first as? DetailViewController)
        XCTAssertTrue(controller.lockedView.isHidden)
    }

    func testDiscussionLockedForUser() {
        router.mock("/courses/1/discussions/2?origin=module_item_details") {
            DetailViewController()
        }
        api.mock(controller.store, value: .make(
            id: "3",
            title: "Submit this thing!",
            content: .discussion("2"),
            url: URL(string: "/courses/1/discussions/2")!,
            content_details: .make(locked_for_user: true, lock_explanation: "Locked for reasons")
        ))
        controller.view.layoutIfNeeded()
        XCTAssertNotNil(controller.children.first as? DetailViewController)
        XCTAssertTrue(controller.lockedView.isHidden)
    }

    func testQuizzesLockedForUser() {
        router.mock("/courses/1/quizzes/2?origin=module_item_details") {
            DetailViewController()
        }
        api.mock(controller.store, value: .make(
            id: "3",
            title: "Submit this thing!",
            content: .quiz("2"),
            url: URL(string: "/courses/1/quizzes/2")!,
            content_details: .make(locked_for_user: true, lock_explanation: "Locked for reasons")
        ))
        controller.view.layoutIfNeeded()
        XCTAssertNotNil(controller.children.first as? DetailViewController)
        XCTAssertTrue(controller.lockedView.isHidden)
    }

    func testMarkAsDone() {
        let expectation = XCTestExpectation(description: "notification sent")

        NotificationCenter.default.publisher(for: .moduleItemRequirementCompleted)
            .first()
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        api.mock(controller.store, value: .make(
            id: "3",
            completion_requirement: .make(type: .must_mark_done, completed: false)
        ))
        let task = api.mock(PutMarkModuleItemDone(courseID: "1", moduleID: "2", moduleItemID: "3", done: true), value: APINoContent())
        task.suspend()
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.navigationItem.rightBarButtonItems?.count, 1)
        let options = controller.navigationItem.rightBarButtonItems!.first!
        XCTAssertNoThrow(options.target!.perform(options.action, with: [options]))
        let alert = router.presented as! UIAlertController
        let markAsDone = alert.actions.first as! AlertAction
        XCTAssertEqual(markAsDone.title, "Mark as Done")
        markAsDone.handler?(markAsDone)
        router.dismiss()
        XCTAssertFalse(controller.spinnerView.isHidden)
        task.resume()
        XCTAssertTrue(controller.spinnerView.isHidden)
        wait(for: [expectation], timeout: 1)
    }

    func testMarkAsViewed() {
        router.mock("/?origin=module_item_details") { DetailViewController() }
        let expectation = XCTestExpectation(description: "notification sent")

        NotificationCenter.default.publisher(for: .moduleItemRequirementCompleted)
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        api.mock(controller.store, value: .make(
            id: "3",
            url: URL(string: "/")!,
            completion_requirement: .make(type: .must_view, completed: false)
        ))
        controller.view.layoutIfNeeded()
        wait(for: [expectation], timeout: 1)
    }

    func testMarkAsViewedWhenCompletedNilDoesNotPostNotification() {
        router.mock("/?origin=module_item_details") { DetailViewController() }
        let expectation = XCTestExpectation(description: "notification was sent when it should not have been")
        expectation.isInverted = true

        NotificationCenter.default.publisher(for: .moduleItemRequirementCompleted)
            .sink { _ in expectation.fulfill() }
            .store(in: &subscriptions)

        api.mock(controller.store, value: .make(
            id: "3",
            url: URL(string: "/")!,
            completion_requirement: .make(type: .must_view, completed: nil)
        ))
        controller.view.layoutIfNeeded()
        wait(for: [expectation], timeout: 0.1)
    }

    func testReportsScreenViewForLoadedChildViewController() {
        let mockAnalyticsHandler = MockAnalyticsHandler()
        Analytics.shared.handler = mockAnalyticsHandler
        router.mock("/courses/1/assignments/2?origin=module_item_details") {
            DetailViewController()
        }
        router.mockTemplate(for: URL(string: "/courses/1/assignments/2?origin=module_item_details")!, template: "/courses/:courseId")
        api.mock(controller.store,
                 value: .make(
                    id: "3",
                    title: "Submit this thing!",
                    content: .assignment("2"),
                    url: URL(string: "/courses/1/assignments/2")!,
                    content_details: .make())
        )
        controller.view.layoutIfNeeded()

        XCTAssertEqual(mockAnalyticsHandler.lastEventName, "screen_view")
        XCTAssertEqual(mockAnalyticsHandler.lastEventParameters?["screen_name"] as? String, "/courses/:courseId")
        XCTAssertEqual(mockAnalyticsHandler.lastEventParameters?["screen_class"] as? String, "DetailViewController")
    }
}
