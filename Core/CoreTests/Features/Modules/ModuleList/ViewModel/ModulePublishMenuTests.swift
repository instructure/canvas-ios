//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@testable import Core
import TestsFoundation
import XCTest

class ModulePublishMenuTests: XCTestCase {
    var hostView: UIViewController!
    var router: TestRouter!

    override func setUp() {
        super.setUp()
        hostView = UIViewController()
        router = TestRouter()
    }

    // MARK: - All Modules Actions

    func testPublishAllModulesAndItems() {
        let testee = UIMenu.makePublishAllModulesMenu(host: hostView, router: router) { _ in }
        let publishMenu = testee.children[0] as! UIMenu
        let publishAll = publishMenu.children[0] as! UIAction

        publishAll.performWithSender(nil, target: nil)

        XCTAssertEqual(publishAll.image, .completeLine)
        XCTAssertEqual(publishAll.title, "Publish All Modules And Items")
        checkAlert(title: "Publish?",
                   message: "This will make all modules and items visible to students.",
                   defaultActionTitle: "Publish")
    }

    func testPublishAllModulesOnly() {
        let testee = UIMenu.makePublishAllModulesMenu(host: hostView, router: router) { _ in }
        let publishMenu = testee.children[0] as! UIMenu
        let publishModules = publishMenu.children[1] as! UIAction

        publishModules.performWithSender(nil, target: nil)

        XCTAssertEqual(publishModules.image, .completeLine)
        XCTAssertEqual(publishModules.title, "Publish Modules Only")
        checkAlert(title: "Publish?",
                   message: "This will make only the modules visible to students.",
                   defaultActionTitle: "Publish")
    }

    func testUnpublishAllModulesAndItems() {
        let testee = UIMenu.makePublishAllModulesMenu(host: hostView, router: router) { _ in }
        let unpublishMenu = testee.children[1] as! UIMenu
        let unpublishAll = unpublishMenu.children[0] as! UIAction

        unpublishAll.performWithSender(nil, target: nil)

        XCTAssertEqual(unpublishAll.image, .noLine)
        XCTAssertEqual(unpublishAll.title, "Unpublish All Modules And Items")
        checkAlert(title: "Unpublish?",
                   message: "This will make all modules and items invisible to students.",
                   defaultActionTitle: "Unpublish")
    }

    // MARK: - Module Actions

    func testPublishModuleAndAllItems() {
        let testee = UIMenu.makePublishModuleMenu(host: hostView, router: router) { _ in }
        let publishMenu = testee.children[0] as! UIMenu
        let publishModule = publishMenu.children[0] as! UIAction

        publishModule.performWithSender(nil, target: nil)

        XCTAssertEqual(publishModule.image, .completeLine)
        XCTAssertEqual(publishModule.title, "Publish Module And All Items")
        checkAlert(title: "Publish?",
                   message: "This will make the module and all items visible to students.",
                   defaultActionTitle: "Publish")
    }

    func testPublishModuleAndAllItemsA11yAction() {
        let testee = [UIAccessibilityCustomAction].makePublishModuleA11yActions(host: hostView, router: router) { _ in }
        let action = testee[0]

        _ = action.actionHandler!(action)

        XCTAssertEqual(action.name, "Publish Module And All Items")
        checkAlert(title: "Publish?",
                   message: "This will make the module and all items visible to students.",
                   defaultActionTitle: "Publish")
    }

    func testPublishModuleOnly() {
        let testee = UIMenu.makePublishModuleMenu(host: hostView, router: router) { _ in }
        let publishMenu = testee.children[0] as! UIMenu
        let publishModule = publishMenu.children[1] as! UIAction

        publishModule.performWithSender(nil, target: nil)

        XCTAssertEqual(publishModule.image, .completeLine)
        XCTAssertEqual(publishModule.title, "Publish Module Only")
        checkAlert(title: "Publish?",
                   message: "This will make only the module visible to students.",
                   defaultActionTitle: "Publish")
    }

    func testPublishModuleOnlyA11yAction() {
        let testee = [UIAccessibilityCustomAction].makePublishModuleA11yActions(host: hostView, router: router) { _ in }
        let action = testee[1]

        _ = action.actionHandler!(action)

        XCTAssertEqual(action.name, "Publish Module Only")
        checkAlert(title: "Publish?",
                   message: "This will make only the module visible to students.",
                   defaultActionTitle: "Publish")
    }

    func testUnpublishModule() {
        let testee = UIMenu.makePublishModuleMenu(host: hostView, router: router) { _ in }
        let publishMenu = testee.children[1] as! UIMenu
        let publishModule = publishMenu.children[0] as! UIAction

        publishModule.performWithSender(nil, target: nil)

        XCTAssertEqual(publishModule.image, .noLine)
        XCTAssertEqual(publishModule.title, "Unpublish Module And All Items")
        checkAlert(title: "Unpublish?",
                   message: "This will make the module and all items invisible to students.",
                   defaultActionTitle: "Unpublish")
    }

    func testUnpublishModuleA11yAction() {
        let testee = [UIAccessibilityCustomAction].makePublishModuleA11yActions(host: hostView, router: router) { _ in }
        let action = testee[2]

        _ = action.actionHandler!(action)

        XCTAssertEqual(action.name, "Unpublish Module And All Items")
        checkAlert(title: "Unpublish?",
                   message: "This will make the module and all items invisible to students.",
                   defaultActionTitle: "Unpublish")
    }

    // MARK: - Item Actions

    func testPublishItem() {
        let actionExpectation = expectation(description: "Action performed")
        let testee = UIMenu.makePublishModuleItemMenu(action: .publish,
                                                      host: hostView,
                                                      router: router,
                                                      actionDidPerform: { actionExpectation.fulfill() })
        let publishItem = testee.children[0] as! UIAction

        publishItem.performWithSender(nil, target: nil)

        XCTAssertEqual(publishItem.image, .completeLine)
        XCTAssertEqual(publishItem.title, "Publish")
        checkAlert(title: "Publish?",
                   message: "This will make only this item visible to students.",
                   defaultActionTitle: "Publish")
        waitForExpectations(timeout: 0.1)
    }

    func testPublishItemA11yAction() {
        let actionExpectation = expectation(description: "Action performed")
        let testee = [UIAccessibilityCustomAction].makePublishModuleItemA11yActions(action: .publish,
                                                                                    host: hostView,
                                                                                    router: router,
                                                                                    actionDidPerform: { actionExpectation.fulfill() })[0]

        _ = testee.actionHandler!(testee)

        XCTAssertEqual(testee.name, "Publish")
        checkAlert(title: "Publish?",
                   message: "This will make only this item visible to students.",
                   defaultActionTitle: "Publish")
        waitForExpectations(timeout: 0.1)
    }

    func testUnpublishItem() {
        let actionExpectation = expectation(description: "Action performed")
        let testee = UIMenu.makePublishModuleItemMenu(action: .unpublish,
                                      		          host: hostView,
	                                                  router: router,
      		                                          actionDidPerform: { actionExpectation.fulfill() })
        let publishItem = testee.children[0] as! UIAction

        publishItem.performWithSender(nil, target: nil)

        XCTAssertEqual(publishItem.image, .noLine)
        XCTAssertEqual(publishItem.title, "Unpublish")
        checkAlert(title: "Unpublish?",
                   message: "This will make only this item invisible to students.",
                   defaultActionTitle: "Unpublish")
        waitForExpectations(timeout: 0.1)
    }

    func testUnpublishItemA11yAction() {
        let actionExpectation = expectation(description: "Action performed")
        let testee = [UIAccessibilityCustomAction].makePublishModuleItemA11yActions(action: .unpublish,
                                                                                    host: hostView,
                                                                                    router: router,
                                                                                    actionDidPerform: { actionExpectation.fulfill() })[0]

        _ = testee.actionHandler!(testee)

        XCTAssertEqual(testee.name, "Unpublish")
        checkAlert(title: "Unpublish?",
                   message: "This will make only this item invisible to students.",
                   defaultActionTitle: "Unpublish")
        waitForExpectations(timeout: 0.1)
    }

    // MARK: - Private

    private func checkAlert(
        title: String,
        message: String,
        defaultActionTitle: String
    ) {
        guard let alert = router.lastViewController as? UIAlertController else {
            XCTFail("Alert not found")
            return
        }

        let routerCall = router.viewControllerCalls.last!
        XCTAssertEqual(routerCall.0, alert)
        XCTAssertEqual(routerCall.1, hostView)
        XCTAssertEqual(routerCall.2, .modal())
        XCTAssertEqual(alert.title, title)
        XCTAssertEqual(alert.message, message)
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, defaultActionTitle)
        XCTAssertEqual(alert.actions[0].style, .default)
        XCTAssertEqual(alert.actions[1].title, "Cancel")
        XCTAssertEqual(alert.actions[1].style, .cancel)
        (alert.actions[0] as? AlertAction)?.handler?(alert.actions[0])
    }
}
