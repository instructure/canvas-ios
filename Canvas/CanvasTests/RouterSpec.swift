//
//  RouterSpec.swift
//  Canvas
//
//  Created by Nathan Armstrong on 9/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
            let router = Router.sharedRouter()

            it("should route to modules") {
                let url = baseURL.URLByAppendingPathComponent("/courses/1/modules")
                let modules = router.controllerForHandlingURL(url) as? ModulesTableViewController
                expect(modules).toNot(beNil())
            }

            it("should allow modules to become master") {
                let url = baseURL.URLByAppendingPathComponent("/courses/1/modules")
                let modules = router.controllerForHandlingURL(url) as? ModulesTableViewController
                expect(modules?.cbi_canBecomeMaster) == true
            }

            it("should route to module from modules") {
                let url = baseURL.URLByAppendingPathComponent("/courses/1/modules")
                let modules = router.controllerForHandlingURL(url) as? ModulesTableViewController
                expect(modules).toNot(beNil())
                guard let vc = modules else { return }

                let nav = embedInNavigationController(vc)

                // add a module
                Module.build { $0.courseID = "1" }
                vc.tableView.reloadData()
                expect(vc.tableView.numberOfRowsInSection(0)).toEventually(equal(1))

                // select module
                vc.tableView(vc.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                expect(nav.topViewController).to(beAnInstanceOf(ModuleDetailsViewController.self))
            }

            it("should route to module item detail") {
                ModuleItem.build { $0.title = "Item 1"; $0.id = "3"; $0.moduleID = "2" }
                let url = baseURL.URLByAppendingPathComponent("/courses/1/modules/2/items/3")
                let vc = router.controllerForHandlingURL(url) as? ModuleItemDetailViewController
                _ = vc?.view
                expect(vc).toNot(beNil())
                expect(vc?.title).toEventually(equal("Item 1"))
            }

            it("should route to module item from module items") {
                let url = baseURL.URLByAppendingPathComponent("/courses/1/modules/2")
                let moduleItems = router.controllerForHandlingURL(url) as? ModuleDetailsViewController
                expect(moduleItems).toNot(beNil())
                guard let vc = moduleItems else { return }

                let nav = embedInNavigationController(vc)

                // add a module item
                ModuleItem.build {
                    $0.courseID = "1"
                    $0.moduleID = "2"
                }
                vc.tableView.reloadData()
                expect(vc.tableView.numberOfRowsInSection(1)).toEventually(equal(1))

                // select module item
                vc.tableView(vc.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 1))
                expect(nav.topViewController).to(beAnInstanceOf(ModuleItemDetailViewController.self))
            }
        }
    }

    func addRoutes() {
        login()
        Router.sharedRouter().addCanvasRoutes {
            fatalError($0.localizedDescription)
        }
    }
}
