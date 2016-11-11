//
//  ModuleItemDetailViewControllerSpec.swift
//  Canvas
//
//  Created by Nathan Armstrong on 10/19/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import Canvas
import Quick
import Nimble
import SoAutomated
import TechDebt
@testable import SoEdventurous
import Marshal

class ModuleItemDetailViewControllerSpec: QuickSpec {
    override func spec() {
        describe("ModuleItemDetailViewController") {
            it("should have next and previous buttons") {
                let vc = try! ModuleItemDetailViewController(session: currentSession, courseID: "1", moduleID: "1", moduleItemID: "1", route: ignoreRouteAction)
                _ = vc.view

                let next = vc.nextButton
                expect(next.title) == "Next"
                expect(next.accessibilityIdentifier).toNot(beNil())

                let previous = vc.previousButton
                expect(previous.title) == "Previous"
                expect(previous.accessibilityIdentifier).toNot(beNil())
            }

            context("with mark as done requirement") {
                var vc: ModuleItemDetailViewController!
                var markAsDoneButton: UIBarButtonItem?
                beforeEach {
                    login()
                    let item = ModuleItem.build {
                        $0.completed = false
                        $0.completionRequirement = .MarkDone
                    }
                    vc = try! ModuleItemDetailViewController(session: currentSession, courseID: item.courseID, moduleID: item.moduleID, moduleItemID: item.id, route: ignoreRouteAction)
                    _ = vc.view

                    markAsDoneButton = vc.navigationItem.rightBarButtonItems?.first!
                }

                it("should add mark as done button") {
                    expect(markAsDoneButton).toNot(beNil())
                }

                it("should set mark as done accessibility identifier") {
                    expect(markAsDoneButton?.accessibilityIdentifier).toNot(beNil())
                }
            }

            describe("embed") {
                var item: ModuleItem!
                var vc: ModuleItemDetailViewController!
                var route: NSURL!
                beforeEach {
                    class Embedded: UIViewController {
                        override func viewDidLoad() {
                            super.viewDidLoad()
                            navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Foo", style: .Plain, target: nil, action: nil)]
                        }
                    }
                    login()

                    route = currentSession.baseURL / "unit-test/module-item-detail-vc-embedded-vc"
                    Router.sharedRouter().addRoute(route.path!) { _ in Embedded() }
                    
                    item = ModuleItem.build {
                        $0.url = route.absoluteString
                    }

                    vc = try! ModuleItemDetailViewController(session: currentSession, courseID: item.courseID, moduleID: item.moduleID, moduleItemID: item.id, route: ignoreRouteAction)
                    _ = vc.view
                    waitUntil { done in
                        if vc.isViewLoaded() { done() }
                    }
                }

                afterEach {
                    Router.sharedRouter().removeRoute(route.path!)
                }

                it("should display the module item view controller") {
                    expect(vc.view.subviews.count).toEventually(equal(2)) // toolbar + embedded view
                    expect(vc.navigationItem.rightBarButtonItems?.count).toEventually(equal(1))
                }

                it("should append mark done button") {
                    item.completionRequirement = .MarkDone
                    item.completed = false
                    expect(vc.navigationItem.rightBarButtonItems?.count).toEventually(equal(2))
                }
            }
        }
    }
}
