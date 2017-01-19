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
@testable import Canvas
import Quick
import Nimble
import SoAutomated
import TooLegit
@testable import SoEdventurous
import TechDebt
import SoPersistent

class ModuleDetailsViewControllerSpec: QuickSpec {
    override func spec() {
        describe("ModuleDetailsViewController") {
            it("should keep selected cell in sync with module item detail progression") {
                _ = login()
                let route = currentSession.baseURL / "unit-test/module-details-vc-selected-progress"
                Router.shared().addRoute(route.path) { _ in UIViewController() }

                let module = Module.build()

                let one = ModuleItem.build {
                    $0.id = "1"
                    $0.moduleID = module.id
                    $0.courseID = module.courseID
                    $0.url = route.absoluteString
                    $0.position = 1
                }
                let two = ModuleItem.build {
                    $0.id = "2"
                    $0.moduleID = module.id
                    $0.courseID = module.courseID
                    $0.url = route.absoluteString
                    $0.position = 2
                }

                let vc = try! ModuleDetailsViewController(session: currentSession, courseID: module.courseID, moduleID: module.id, route: ignoreRouteAction)
                _ = vc.view

                let row0 = IndexPath(row: 0, section: 1)
                let row1 = IndexPath(row: 1, section: 1)

                expect((vc.tableView.cellForRow(at: row0)! as! ColorfulTableViewCell).titleLabel.text).toEventually(equal(one.title))
                expect((vc.tableView.cellForRow(at: row1)! as! ColorfulTableViewCell).titleLabel.text).toEventually(equal(two.title))
                expect(vc.tableView.indexPathsForSelectedRows).to(beNil())

                let detail = try! ModuleItemDetailViewController(session: currentSession, courseID: module.courseID, moduleID: module.id, moduleItemID: one.id, route: ignoreRouteAction)
                _ = detail.view

                expect(vc.tableView.indexPathForSelectedRow).toEventually(equal(row0))

                detail.next()
                expect(vc.tableView.indexPathForSelectedRow).toEventually(equal(row1))
                expect(vc.tableView.indexPathsForSelectedRows).toNot(contain(row0))

                detail.previous()
                expect(vc.tableView.indexPathForSelectedRow).toEventually(equal(row0))
                expect(vc.tableView.indexPathsForSelectedRows).toNot(contain(row1))

                Router.shared().removeRoute(route.path)
            }
        }

        describe("didSelectRowAtIndexPath") {
            it("should route to mastery path options path") {
                _ = login()
                Router.shared().addCanvasRoutes { fatalError($0.localizedDescription) }
                var route: URL?

                let module = Module.build()
                module.id = "1"
                module.courseID = "1"

                let item = ModuleItem.build()
                item.id = "1"
                item.moduleID = module.id
                item.courseID = module.courseID
                item.title = "Item 1"
                item.position = 1

                let masteryPathsItem = MasteryPathsItem.factory(inSession: currentSession)
                masteryPathsItem.id = "123-456"
                masteryPathsItem.moduleItemID = item.id
                masteryPathsItem.moduleID = item.moduleID
                masteryPathsItem.lockedForUser = false
                masteryPathsItem.courseID = item.courseID
                masteryPathsItem.position = 1.5

                let vc = try! ModuleDetailsViewController(session: currentSession, courseID: item.courseID, moduleID: item.moduleID) { _, url in
                    route = url
                }

                expect((vc.tableView.cellForRow(at: IndexPath(row: 0, section: 1))! as! ColorfulTableViewCell).titleLabel.text).toEventually(equal("Item 1"))
                expect((vc.tableView.cellForRow(at: IndexPath(row: 1, section: 1))! as! ColorfulTableViewCell).titleLabel.text).toEventually(equal("Choose option"))

                vc.tableView(vc.tableView, didSelectRowAt: IndexPath(row: 1, section: 1))

                expect(route).toNot(beNil())
                expect(route?.path) == "courses/1/modules/1/items/123-456"
            }
        }
    }
}

extension ModuleItemDetailViewController {
    func next() {
        viewModel.nextAction.apply(()).start()
    }
    
    func previous() {
        viewModel.previousAction.apply(()).start()
    }
}
