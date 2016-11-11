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
