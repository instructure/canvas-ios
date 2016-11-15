//
//  ModuleItemViewModelSpec.swift
//  Canvas
//
//  Created by Nathan Armstrong on 9/23/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import Canvas
import Quick
import Nimble
import SoAutomated
import ReactiveCocoa
@testable import SoEdventurous
import SoPersistent
import TooLegit
import TechDebt

class ModuleItemViewModelSpec: QuickSpec {
    override func spec() {
        describe("ModuleItemViewModel") {
            var vm: ModuleItemViewModel!
            var item: ModuleItem!
            var module: Module!
            beforeEach {
                login()
                module = Module.build(inSession: currentSession) {
                    $0.state = nil
                }
                item = ModuleItem.build {
                    $0.id = "10"
                    $0.moduleID = module.id
                }
                vm = try! ModuleItemViewModel(session: currentSession, moduleItem: item)
            }

            describe("table view cell") {
                let tableView = UITableView()
                var cell: UITableViewCell!
                beforeEach {
                    ModuleItemViewModel.tableViewDidLoad(tableView)
                    cell = vm.cellForTableView(tableView, indexPath: NSIndexPath(forRow: 0, inSection: 0))
                }

                context("when the module is locked") {
                    beforeEach {
                        module.state = .locked
                    }

                    it("should disable selection") {
                        expect(cell.userInteractionEnabled).toEventually(beFalse())
                    }

                    it("should lighten the title text color") {
                        expect(cell.textLabel!.textColor).toEventually(equal(UIColor.lightGrayColor()))
                    }

                    it("should VO locked status") {
                        item.title = "Assignment 1"
                        item.completionRequirement = nil
                        item.content = .Assignment(id: "1")
                        expect(cell.accessibilityLabel).toEventually(equal("Assignment 1. Type: Assignment. Status: Locked"))
                    }
                }

                it("should have an accessoryView if the item has a completionRequirement other than MustChoose") {
                    item.completionRequirement = nil
                    expect(cell.accessoryView).toEventually(beNil())
                    item.completionRequirement = .MustView
                    expect(cell.accessoryView).toEventuallyNot(beNil())
                    item.completionRequirement = .MustChoose
                    expect(cell.accessoryView).toEventually(beNil())
                }

                it("should have an accessibility label") {
                    Module.build { $0.id = item.moduleID }
                    item.title = "Assignment 1"
                    item.completionRequirement = .MustView
                    item.content = .Assignment(id: "1")
                    item.completed = false
                    expect(cell.accessibilityLabel).toEventually(equal("Assignment 1. Must view. Type: Assignment. Status: Incomplete"))

                    item.completed = true
                    expect(cell.accessibilityLabel).toEventually(equal("Assignment 1. Must view. Type: Assignment. Status: Completed"))

                    item.content = .MasteryPaths
                    item.completionRequirement = .MustChoose
                    expect(cell.accessibilityLabel).toEventually(equal("Assignment 1. Type: Mastery Path"))

                    item.completionRequirement = .MarkDone
                    item.content = .Quiz(id: "1")
                    expect(cell.accessibilityLabel).toEventually(equal("Assignment 1. Must mark as done. Type: Quiz. Status: Completed"))

                    item.completionRequirement = nil
                    item.completed = false
                    item.content = .ExternalURL(url: NSURL(string: "")!)
                    item.title = "Go here"
                    expect(cell.accessibilityLabel).toEventually(equal("Go here. Type: Link"))

                    item.lockedForUser = true
                    expect(cell.accessibilityLabel).toEventually(equal("Go here. Type: Link. Status: Locked"))
                }

                context("when sequential progress required") {
                    beforeEach {
                        module.requireSequentialProgress = true
                    }

                    var disabled: Bool {
                        return cell.selectionStyle ==  .None &&
                        !cell.userInteractionEnabled &&
                        cell.textLabel!.textColor == UIColor.lightGrayColor()
                    }
                    var enabled: Bool {
                        return cell.selectionStyle ==  .Default &&
                        cell.userInteractionEnabled &&
                        cell.textLabel!.textColor == UIColor.blackColor()
                    }

                    it("should be disabled if any previous items are incomplete") {
                        item.completed = true
                        item.position = 5
                        expect(enabled).toEventually(beTrue())

                        let one = ModuleItem.build {
                            $0.moduleID = module.id
                            $0.completed = false
                            $0.position = 4
                        }

                        expect(disabled).toEventually(beTrue())

                        one.completed = true
                        expect(enabled).toEventually(beTrue())

                        ModuleItem.build {
                            $0.moduleID = module.id
                            $0.completed = false
                            $0.position = 3
                        }

                        expect(disabled).toEventually(beTrue())
                    }

                    it("should be disabled if any items in prerequisite modules are incomplete") {
                        module.requireSequentialProgress = true
                        let prerequisiteModule = Module.build {
                            $0.id = "20"
                            $0.requireSequentialProgress = true
                        }
                        module.prerequisiteModuleIDs = [prerequisiteModule.id]
                        ModuleItem.build {
                            $0.id = "30"
                            $0.moduleID = prerequisiteModule.id
                            $0.completed = false
                        }

                        expect(disabled).toEventually(beTrue())
                    }
                }
            }

            it("should track the module item title") {
                item.title = "Mercury"
                expect(vm.title.value).toEventually(equal("Mercury"))

                item.title = "Venus"
                expect(vm.title.value).toEventually(equal("Venus"))

                Module.build {
                    $0.id = item.moduleID
                }

                let next = ModuleItem.build {
                    $0.id = "2"
                    $0.moduleID = item.moduleID
                    $0.courseID = item.courseID
                    $0.position = item.position + 1
                    $0.title = "Other"
                }

                expect(vm.nextAction.enabled.value).toEventually(beTrue())
                vm.nextAction.apply(()).start()
                expect(vm.title.value).toEventually(equal("Other"))
                next.title = "Other Changed"
                expect(vm.title.value).toEventually(equal("Other Changed"))
            }

            it("should provide the view controller to embed") {
                class EmbeddedViewController: UIViewController {}
                let route = currentSession.baseURL / "unit-test/module-item-detail-vm-embed-vc"
                Router.sharedRouter().addRoute(route.path!) { _ in EmbeddedViewController() }

                item.url = route.absoluteString

                expect(vm.embeddedViewController.value).toEventually(beAnInstanceOf(EmbeddedViewController.self))

                Router.sharedRouter().removeRoute(route.path!)
            }

            it("should embed external urls in a web view controller") {
                item.content = .ExternalURL(url: NSURL(string: "https://google.com")!)
                expect(vm.embeddedViewController.value).toEventually(beAnInstanceOf(WebBrowserViewController.self))
            }

            it("should embed a special mastery paths view controller for mastery paths items") {
                let masteryPathsItem = MasteryPathsItem.factory(inSession: currentSession) {
                    $0.id = "mastery-paths-item"
                    $0.moduleID = item.moduleID
                    $0.moduleItemID = item.id
                    $0.content = .MasteryPaths
                }
                let masteryPathVM = try! ModuleItemViewModel(session: currentSession, moduleID: masteryPathsItem.moduleID, moduleItemID: masteryPathsItem.id)
                expect(masteryPathVM.embeddedViewController.value).toEventually(beAnInstanceOf(MasteryPathSelectOptionViewController.self))
            }

            describe("next/previous Actions") {
                beforeEach {
                    module.prerequisiteModuleIDs = []
                    module.requireSequentialProgress = false

                    expect(vm.nextAction.enabled.value) == false
                    expect(vm.previousAction.enabled.value) == false
                }

                it("should be enabled if there are next/previous items") {
                    item.position = 2
                    ModuleItem.build {
                        $0.id = "2"
                        $0.moduleID = item.moduleID
                        $0.position = 3
                    }

                    expect(vm.nextAction.enabled.value).toEventually(equal(true))
                    expect(vm.previousAction.enabled.value) == false

                    ModuleItem.build {
                        $0.id = "3"
                        $0.moduleID = item.moduleID
                        $0.position = 1
                    }
                    expect(vm.previousAction.enabled.value).toEventually(equal(true))
                }

                it("should disable next Action if the next item is locked by sequential progress") {
                    item.position = 1
                    item.completed = false
                    ModuleItem.build {
                        $0.id = "2"
                        $0.moduleID = item.moduleID
                        $0.position = 2
                    }
                    expect(vm.nextAction.enabled.value).toEventually(equal(true))

                    module.requireSequentialProgress = true

                    expect(vm.nextAction.enabled.value).toEventually(equal(false))
                }
            }

            describe("markAsDoneAction") {
                it("should require a MarkDone completionRequirement") {
                    item.completed = false
                    item.completionRequirement = .MarkDone
                    expect(vm.markAsDoneAction.enabled.value).toEventually(beTrue())
                    
                    item.completionRequirement = nil
                    expect(vm.markAsDoneAction.enabled.value).toEventually(beFalse())
                }

                it("should require that the item not be completed") {
                    item.completed = false
                    item.completionRequirement = .MarkDone
                    expect(vm.markAsDoneAction.enabled.value).toEventually(beTrue())

                    item.completed = true
                    expect(vm.markAsDoneAction.enabled.value).toEventually(beFalse())
                }
            }

            describe("markAsViewedAction") {
                it("should require a MustView completionRequirement") {
                    item.completed = false
                    item.completionRequirement = .MustView
                    expect(vm.markAsViewedAction.enabled.value).toEventually(beTrue())
                    
                    item.completionRequirement = nil
                    expect(vm.markAsViewedAction.enabled.value).toEventually(beFalse())
                }

                it("should require that the item not be completed") {
                    item.completionRequirement = .MustView
                    item.completed = false
                    expect(vm.markAsViewedAction.enabled.value).toEventually(beTrue())

                    item.completed = true
                    expect(vm.markAsViewedAction.enabled.value).toEventually(beFalse())
                }
            }
        }
    }
}
