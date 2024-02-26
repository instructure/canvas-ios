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

@available(iOS 16.0, *)
class ModulePublishMenuTests: XCTestCase {
    var hostView: UIViewController!
    var router: TestRouter!

    override func setUp() {
        super.setUp()
        hostView = UIViewController()
        router = TestRouter()
    }

    func testPublishAllModulesAndItems() {
        let testee = UIMenu.modulePublishOnNavBar(host: hostView, router: router)
        let publishMenu = testee.children[0] as! UIMenu
        let publishAll = publishMenu.children[0] as! UIAction

        publishAll.performWithSender(nil, target: nil)

        XCTAssertEqual(publishAll.image, .completeLine)
        XCTAssertEqual(publishAll.title, "Publish All Modules And Items")
        let alert = router.lastViewController as! UIAlertController
        let routerCall = router.viewControllerCalls.last!
        XCTAssertEqual(routerCall.0, alert)
        XCTAssertEqual(routerCall.1, hostView)
        XCTAssertEqual(routerCall.2, .modal())
        XCTAssertEqual(alert.title, "Publish?")
        XCTAssertEqual(alert.message, "This will make all modules and items visible to students.")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, "Publish")
        XCTAssertEqual(alert.actions[0].style, .default)
        XCTAssertEqual(alert.actions[1].title, "Cancel")
        XCTAssertEqual(alert.actions[1].style, .cancel)
    }

    func testPublishModulesOnly() {
        let testee = UIMenu.modulePublishOnNavBar(host: hostView, router: router)
        let publishMenu = testee.children[0] as! UIMenu
        let publishModules = publishMenu.children[1] as! UIAction

        publishModules.performWithSender(nil, target: nil)

        XCTAssertEqual(publishModules.image, .completeLine)
        XCTAssertEqual(publishModules.title, "Publish Modules Only")
        let alert = router.lastViewController as! UIAlertController
        let routerCall = router.viewControllerCalls.last!
        XCTAssertEqual(routerCall.0, alert)
        XCTAssertEqual(routerCall.1, hostView)
        XCTAssertEqual(routerCall.2, .modal())
        XCTAssertEqual(alert.title, "Publish?")
        XCTAssertEqual(alert.message, "This will make only the modules visible to students.")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, "Publish")
        XCTAssertEqual(alert.actions[0].style, .default)
        XCTAssertEqual(alert.actions[1].title, "Cancel")
        XCTAssertEqual(alert.actions[1].style, .cancel)
    }

    func testUnpublishAllModulesAndItems() {
        let testee = UIMenu.modulePublishOnNavBar(host: hostView, router: router)
        let unpublishMenu = testee.children[1] as! UIMenu
        let unpublishAll = unpublishMenu.children[0] as! UIAction

        unpublishAll.performWithSender(nil, target: nil)

        XCTAssertEqual(unpublishAll.image, .noLine)
        XCTAssertEqual(unpublishAll.title, "Unpublish All Modules And Items")
        let alert = router.lastViewController as! UIAlertController
        let routerCall = router.viewControllerCalls.last!
        XCTAssertEqual(routerCall.0, alert)
        XCTAssertEqual(routerCall.1, hostView)
        XCTAssertEqual(routerCall.2, .modal())
        XCTAssertEqual(alert.title, "Unpublish?")
        XCTAssertEqual(alert.message, "This will make all modules and items invisible to students.")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, "Unpublish")
        XCTAssertEqual(alert.actions[0].style, .default)
        XCTAssertEqual(alert.actions[1].title, "Cancel")
        XCTAssertEqual(alert.actions[1].style, .cancel)
    }

    func testPublishModuleAndAllItems() {
        let testee = UIMenu.modulePublishOnModule(host: hostView, router: router)
        let publishMenu = testee.children[0] as! UIMenu
        let publishModule = publishMenu.children[0] as! UIAction

        publishModule.performWithSender(nil, target: nil)

        XCTAssertEqual(publishModule.image, .completeLine)
        XCTAssertEqual(publishModule.title, "Publish Module And All Items")
        let alert = router.lastViewController as! UIAlertController
        let routerCall = router.viewControllerCalls.last!
        XCTAssertEqual(routerCall.0, alert)
        XCTAssertEqual(routerCall.1, hostView)
        XCTAssertEqual(routerCall.2, .modal())
        XCTAssertEqual(alert.title, "Publish?")
        XCTAssertEqual(alert.message, "This will make the module and all items visible to students.")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, "Publish")
        XCTAssertEqual(alert.actions[0].style, .default)
        XCTAssertEqual(alert.actions[1].title, "Cancel")
        XCTAssertEqual(alert.actions[1].style, .cancel)
    }

    func testPublishModuleOnly() {
        let testee = UIMenu.modulePublishOnModule(host: hostView, router: router)
        let publishMenu = testee.children[0] as! UIMenu
        let publishModule = publishMenu.children[1] as! UIAction

        publishModule.performWithSender(nil, target: nil)

        XCTAssertEqual(publishModule.image, .completeLine)
        XCTAssertEqual(publishModule.title, "Publish Module Only")
        let alert = router.lastViewController as! UIAlertController
        let routerCall = router.viewControllerCalls.last!
        XCTAssertEqual(routerCall.0, alert)
        XCTAssertEqual(routerCall.1, hostView)
        XCTAssertEqual(routerCall.2, .modal())
        XCTAssertEqual(alert.title, "Publish?")
        XCTAssertEqual(alert.message, "This will make only the module visible to students.")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, "Publish")
        XCTAssertEqual(alert.actions[0].style, .default)
        XCTAssertEqual(alert.actions[1].title, "Cancel")
        XCTAssertEqual(alert.actions[1].style, .cancel)
    }

    func testUnpublishModule() {
        let testee = UIMenu.modulePublishOnModule(host: hostView, router: router)
        let publishMenu = testee.children[1] as! UIMenu
        let publishModule = publishMenu.children[0] as! UIAction

        publishModule.performWithSender(nil, target: nil)

        XCTAssertEqual(publishModule.image, .noLine)
        XCTAssertEqual(publishModule.title, "Unpublish Module And All Items")
        let alert = router.lastViewController as! UIAlertController
        let routerCall = router.viewControllerCalls.last!
        XCTAssertEqual(routerCall.0, alert)
        XCTAssertEqual(routerCall.1, hostView)
        XCTAssertEqual(routerCall.2, .modal())
        XCTAssertEqual(alert.title, "Unpublish?")
        XCTAssertEqual(alert.message, "This will make the module and all items invisible to students.")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, "Unpublish")
        XCTAssertEqual(alert.actions[0].style, .default)
        XCTAssertEqual(alert.actions[1].title, "Cancel")
        XCTAssertEqual(alert.actions[1].style, .cancel)
    }

    func testPublishItem() {
        let testee = UIMenu.modulePublishOnItem(action: .publish, host: hostView, router: router)
        let publishItem = testee.children[0] as! UIAction

        publishItem.performWithSender(nil, target: nil)

        XCTAssertEqual(publishItem.image, .completeLine)
        XCTAssertEqual(publishItem.title, "Publish")
        let alert = router.lastViewController as! UIAlertController
        let routerCall = router.viewControllerCalls.last!
        XCTAssertEqual(routerCall.0, alert)
        XCTAssertEqual(routerCall.1, hostView)
        XCTAssertEqual(routerCall.2, .modal())
        XCTAssertEqual(alert.title, "Publish?")
        XCTAssertEqual(alert.message, "This will make only this item visible to students.")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, "Publish")
        XCTAssertEqual(alert.actions[0].style, .default)
        XCTAssertEqual(alert.actions[1].title, "Cancel")
        XCTAssertEqual(alert.actions[1].style, .cancel)
    }

    func testUnpublishItem() {
        let testee = UIMenu.modulePublishOnItem(action: .unpublish, host: hostView, router: router)
        let publishItem = testee.children[0] as! UIAction

        publishItem.performWithSender(nil, target: nil)

        XCTAssertEqual(publishItem.image, .noLine)
        XCTAssertEqual(publishItem.title, "Unpublish")
        let alert = router.lastViewController as! UIAlertController
        let routerCall = router.viewControllerCalls.last!
        XCTAssertEqual(routerCall.0, alert)
        XCTAssertEqual(routerCall.1, hostView)
        XCTAssertEqual(routerCall.2, .modal())
        XCTAssertEqual(alert.title, "Unpublish?")
        XCTAssertEqual(alert.message, "This will make only this item invisible to students.")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, "Unpublish")
        XCTAssertEqual(alert.actions[0].style, .default)
        XCTAssertEqual(alert.actions[1].title, "Cancel")
        XCTAssertEqual(alert.actions[1].style, .cancel)
    }
}
