//
//  ModuleDetailsViewControllerSpec.swift
//  Canvas
//
//  Created by Nathan Armstrong on 10/29/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import Canvas
import Quick
import Nimble
import SoAutomated
import TooLegit
@testable import SoEdventurous
import TechDebt

class ModuleDetailsViewControllerSpec: QuickSpec {
    override func spec() {
        describe("ModuleDetailsViewController") {
            it("should keep selected cell in sync with module item detail progression") {
                login()
                let route = currentSession.baseURL / "unit-test/module-details-vc-selected-progress"
                Router.sharedRouter().addRoute(route.path!) { _ in UIViewController() }

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

                expect(vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))!.textLabel!.text).toEventually(equal(one.title))
                expect(vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))!.textLabel!.text).toEventually(equal(two.title))
                expect(vc.tableView.indexPathsForSelectedRows).to(beNil())

                let detail = try! ModuleItemDetailViewController(session: currentSession, courseID: module.courseID, moduleID: module.id, moduleItemID: one.id, route: ignoreRouteAction)
                _ = detail.view

                expect(vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))!.selected).toEventually(beTrue())

                detail.next()
                expect(vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))!.selected).toEventually(beTrue())
                expect(vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))!.selected).toEventually(beFalse())

                detail.previous()
                expect(vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))!.selected).toEventually(beTrue())
                expect(vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))!.selected).toEventually(beFalse())

                Router.sharedRouter().removeRoute(route.path!)
            }
        }

        describe("didSelectRowAtIndexPath") {
            it("should route to mastery path options path") {
                login()
                Router.sharedRouter().addCanvasRoutes { fatalError($0.localizedDescription) }
                var route: NSURL?

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
                masteryPathsItem.locked = false
                masteryPathsItem.courseID = item.courseID
                masteryPathsItem.position = 1.5

                let vc = try! ModuleDetailsViewController(session: currentSession, courseID: item.courseID, moduleID: item.moduleID) { _, url in
                    route = url
                }

                expect(vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))!.textLabel!.text).toEventually(equal("Item 1"))
                expect(vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1))!.textLabel!.text).toEventually(equal("Choose option"))

                vc.tableView(vc.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))

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
