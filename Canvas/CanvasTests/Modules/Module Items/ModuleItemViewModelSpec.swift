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
import ReactiveCocoa
@testable import SoEdventurous
import SoPersistent
import TooLegit
import TechDebt
@testable import PageKit

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

                context("when the module item is locked") {
                    beforeEach {
                        item.lockedForUser = true
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

                var embedded: UIViewController?
                vm.embeddedViewController.ignoreNil().take(1).startWithNext { embedded = $0 }
                expect(embedded).toEventuallyNot(beNil())
                expect(embedded).toEventually(beAnInstanceOf(EmbeddedViewController.self))

                Router.sharedRouter().removeRoute(route.path!)
            }

            it("should embed external urls in a web view controller") {
                item.content = .ExternalURL(url: NSURL(string: "https://google.com")!)
                var embedded: UIViewController?
                vm.embeddedViewController.take(1).startWithNext { embedded = $0 }
                expect(embedded).toNot(beNil())
                expect(embedded).to(beAnInstanceOf(WebBrowserViewController.self))
            }

            it("should mark external urls as viewed with embedded web browser") {
                login(.user1)
                ModuleItem.beginObservingProgress(currentSession)
                let url = NSURL(string: "https://google.com")!
                let item = ModuleItem.build {
                    $0.id = "25915393"
                    $0.moduleID = "3001848"
                    $0.courseID = "1867097"
                    $0.content = .ExternalURL(url: url)
                    $0.completionRequirement = .MustView
                    $0.completed = false
                }
                let vm = try! ModuleItemViewModel(session: currentSession, moduleItem: item)
                expect(vm.markAsViewedAction.enabled.value) == true
                let browserStub = WebBrowserViewController(URL: url)
                currentSession.playback("ModuleItemMarkRead", in: .soAutomated) {
                    waitUntil(timeout: 5) { done in
                        currentSession.progressDispatcher
                            .onProgress
                            .assumeNoErrors()
                            .filter {
                                $0.itemType == .ModuleItem
                            }
                            .observeNext {
                                if $0.itemID == item.id {
                                    done()
                                }
                            }
                        vm.webBrowser(browserStub, didFinishLoadingWebView: UIWebView())
                    }
                }
                expect(item.reload().completed) == true
            }

            it("should invalidate pages cache when a page becomes unlocked") {
                item.lockedForUser = true
                item.content = .Page(url: "page-1")

                let contextID = ContextID(id: "1", context: .Course)
                var pagesCacheInvalidated: Bool {
                    let pagesMoc = try! currentSession.pagesManagedObjectContext()
                    return currentSession.cacheInvalidated(Page.collectionCacheKey(pagesMoc, contextID: contextID)) &&
                        currentSession.cacheInvalidated(Page.detailCacheKey(pagesMoc, contextID: contextID, url: "page-1"))
                }

                expect(pagesCacheInvalidated) == false
                item.lockedForUser = false
                expect(pagesCacheInvalidated).toEventually(beTrue())
            }

            it("should embed a special mastery paths view controller for mastery paths items") {
                let masteryPathsItem = MasteryPathsItem.factory(inSession: currentSession) {
                    $0.id = "mastery-paths-item"
                    $0.moduleID = item.moduleID
                    $0.moduleItemID = item.id
                    $0.content = .MasteryPaths
                }
                let masteryPathVM = try! ModuleItemViewModel(session: currentSession, moduleID: masteryPathsItem.moduleID, moduleItemID: masteryPathsItem.id)
                var embedded: UIViewController?
                masteryPathVM.embeddedViewController.take(1).startWithNext { embedded = $0 }
                expect(embedded).toNot(beNil())
                expect(embedded).to(beAnInstanceOf(MasteryPathSelectOptionViewController.self))
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
                        $0.lockedForUser = false
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

                it("should disable next Action if the next item is locked for user") {
                    item.position = 1
                    item.completed = false
                    let nextItem = ModuleItem.build {
                        $0.id = "2"
                        $0.moduleID = item.moduleID
                        $0.position = 2
                    }
                    expect(vm.nextAction.enabled.value).toEventually(equal(true))

                    nextItem.lockedForUser = true

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
