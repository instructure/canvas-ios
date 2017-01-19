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

import Foundation
@testable import Canvas
import TechDebt
import Quick
import Nimble
import SoAutomated
import TooLegit
import CanvasKeymaster
@testable import SoEdventurous
import DVR

class RouterSpec: QuickSpec {
    override func spec() {
        beforeEach {
            self.addRoutes()
        }

        describe("Router") {
            let baseURL = NSURL(string: "https://mobiledev.instructure.com")!
            let router = Router.shared()

            it("should route to modules") {
                let url = baseURL.appendingPathComponent("/courses/1/modules")
                let modules = router?.controller(forHandling: url) as? ModulesTableViewController
                expect(modules).toNot(beNil())
            }

            it("should route to module from modules") {
                let url = baseURL.appendingPathComponent("/courses/1/modules")
                let modules = router?.controller(forHandling: url) as? ModulesTableViewController
                expect(modules).toNot(beNil())
                guard let vc = modules else { return }
                guard let tableView = vc.tableView else { return }
                
                let nav = embedInNavigationController(vc)
                
                // add a module
                _ = Module.build { $0.courseID = "1" }
                tableView.reloadData()
                expect(tableView.numberOfRows(inSection: 0)).toEventually(equal(1))

                // select module
                vc.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
                expect(nav.topViewController).to(beAnInstanceOf(ModuleDetailsViewController.self))
            }

            it("should route to module item detail") {
                _ = ModuleItem.build { $0.title = "Item 1"; $0.id = "3"; $0.moduleID = "2" }
                let url = baseURL.appendingPathComponent("/courses/1/modules/2/items/3")
                let vc = router?.controller(forHandling: url) as? ModuleItemDetailViewController
                _ = vc?.view
                expect(vc).toNot(beNil())
                expect(vc?.title).toEventually(equal("Item 1"))
            }

            it("should route to module item from module items") {
                let url = baseURL.appendingPathComponent("/courses/1/modules/2")
                let moduleItems = router?.controller(forHandling: url) as? ModuleDetailsViewController
                expect(moduleItems).toNot(beNil())
                guard let vc = moduleItems else { return }
                guard let tableView = vc.tableView else { return }
                
                let nav = embedInNavigationController(vc)

                // add a module item
                _ = ModuleItem.build {
                    $0.courseID = "1"
                    $0.moduleID = "2"
                }
                tableView.reloadData()
                expect(tableView.numberOfRows(inSection: 1)).toEventually(equal(1))

                // select module item
                vc.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 1))
                expect(nav.topViewController).to(beAnInstanceOf(ModuleItemDetailViewController.self))
            }
        }
    }

    func addRoutes() {
        _ = login()
        Router.shared().addCanvasRoutes {
            fatalError($0.localizedDescription)
        }
    }
}
