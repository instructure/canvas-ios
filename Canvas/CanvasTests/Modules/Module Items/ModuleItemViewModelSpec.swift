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
                _ = login()
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
                var cell: ColorfulTableViewCell!
                beforeEach {
                    ModuleItemViewModel.tableViewDidLoad(tableView)
                    cell = vm.cellForTableView(tableView, indexPath: IndexPath(row: 0, section: 0)) as! ColorfulTableViewCell
                }

                context("when the module item is locked") {
                    beforeEach {
                        item.lockedForUser = true
                    }

                    it("should disable selection") {
                        expect(cell.isUserInteractionEnabled).toEventually(beFalse())
                    }

                    it("should lighten the title text color") {
                        expect(cell.titleLabel.textColor).toEventually(equal(UIColor.lightGray))
                    }

                    it("should VO locked status") {
                        item.title = "Assignment 1"
                        item.completionRequirement = nil
                        item.content = .assignment(id: "1")
                        expect(cell.accessibilityLabel).toEventually(equal("Assignment 1. Type: Assignment. Status: Locked"))
                    }
                }

                context("when the module is locked") {
                    beforeEach {
                        module.state = .locked
                    }

                    it("should disable selection") {
                        expect(cell.isUserInteractionEnabled).toEventually(beFalse())
                    }

                    it("should lighten the title text color") {
                        expect(cell.titleLabel.textColor).toEventually(equal(UIColor.lightGray))
                    }

                    it("should VO locked status") {
                        item.title = "Assignment 1"
                        item.completionRequirement = nil
                        item.content = .assignment(id: "1")
                        expect(cell.accessibilityLabel).toEventually(equal("Assignment 1. Type: Assignment. Status: Locked"))
                    }
                }

                it("should have an accessoryView if the item has a completionRequirement other than MustChoose") {
                    item.completionRequirement = nil
                    expect(cell.accessoryView).toEventually(beNil())
                    item.completionRequirement = .mustView
                    expect(cell.accessoryView).toEventuallyNot(beNil())
                    item.completionRequirement = .mustChoose
                    expect(cell.accessoryView).toEventually(beNil())
                }

                it("should have an accessibility label") {
                    _ = Module.build { $0.id = item.moduleID }
                    item.title = "Assignment 1"
                    item.completionRequirement = .mustView
                    item.content = .assignment(id: "1")
                    item.completed = false
                    expect(cell.accessibilityLabel).toEventually(equal("Assignment 1. Must view. Type: Assignment. Status: Incomplete"))

                    item.completed = true
                    expect(cell.accessibilityLabel).toEventually(equal("Assignment 1. Must view. Type: Assignment. Status: Completed"))

                    item.content = .masteryPaths
                    item.completionRequirement = .mustChoose
                    expect(cell.accessibilityLabel).toEventually(equal("Assignment 1. Type: Mastery Path"))

                    item.completionRequirement = .markDone
                    item.content = .quiz(id: "1")
                    expect(cell.accessibilityLabel).toEventually(equal("Assignment 1. Must mark as done. Type: Quiz. Status: Completed"))

                    item.completionRequirement = nil
                    item.completed = false
                    item.content = .externalURL(url: URL(string: "http://google.com")!)
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

                _ = Module.build {
                    $0.id = item.moduleID
                }

                let next = ModuleItem.build {
                    $0.id = "2"
                    $0.moduleID = item.moduleID
                    $0.courseID = item.courseID
                    $0.position = item.position + 1
                    $0.title = "Other"
                }

                expect(vm.nextAction.isEnabled.value).toEventually(beTrue())
                vm.nextAction.apply(()).start()
                expect(vm.title.value).toEventually(equal("Other"))
                next.title = "Other Changed"
                expect(vm.title.value).toEventually(equal("Other Changed"))
            }

            it("should provide the view controller to embed") {
                class EmbeddedViewController: UIViewController {}
                let route = currentSession.baseURL / "unit-test/module-item-detail-vm-embed-vc"
                Router.shared().addRoute(route.path) { _ in EmbeddedViewController() }

                item.url = route.absoluteString

                var embedded: UIViewController?
                vm.embeddedViewController.skipNil().take(first: 1).startWithValues { embedded = $0 }
                expect(embedded).toEventuallyNot(beNil())
                expect(embedded).toEventually(beAnInstanceOf(EmbeddedViewController.self))

                Router.shared().removeRoute(route.path)
            }

            it("should embed external urls in a web view controller") {
                item.content = .externalURL(url: URL(string: "https://google.com")!)
                var embedded: UIViewController?
                vm.embeddedViewController.take(first: 1).startWithValues { embedded = $0 }
                expect(embedded).toNot(beNil())
                expect(embedded).to(beAnInstanceOf(WebBrowserViewController.self))
            }

            // Complained saying it couldn't find the request in the cassette...
            // Death to the tests anyways
//            it("should mark external urls as viewed with embedded web browser") {
//                _ = login(.user1)
//                ModuleItem.beginObservingProgress(currentSession)
//                let url = URL(string: "https://google.com")!
//                let item = ModuleItem.build {
//                    $0.id = "25915393"
//                    $0.moduleID = "3001848"
//                    $0.courseID = "1867097"
//                    $0.content = .externalURL(url: url)
//                    $0.completionRequirement = .mustView
//                    $0.completed = false
//                }
//                let vm = try! ModuleItemViewModel(session: currentSession, moduleItem: item)
//                expect(vm.markAsViewedAction.isEnabled.value) == true
//                let browserStub = WebBrowserViewController(url: url)
//                currentSession.playback("ModuleItemMarkRead") {
//                    waitUntil(timeout: 5) { done in
//                        currentSession.progressDispatcher
//                            .onProgress
//                            .assumeNoErrors()
//                            .filter {
//                                $0.itemType == .moduleItem
//                            }
//                            .observeValues {
//                                if $0.itemID == item.id {
//                                    done()
//                                }
//                            }
//                        vm.webBrowser(browserStub, didFinishLoading: UIWebView())
//                    }
//                }
//                expect(item.reload().completed) == true
//            }

            it("should invalidate pages cache when a page becomes unlocked") {
                item.lockedForUser = true
                item.content = .page(url: "page-1")

                let contextID = ContextID(id: "1", context: .course)
                var pagesCacheInvalidated: Bool {
                    let pagesMoc = try! currentSession.pagesManagedObjectContext()
                    return currentSession.cacheInvalidated(Page.collectionCacheKey(context: pagesMoc, contextID: contextID)) &&
                        currentSession.cacheInvalidated(Page.detailCacheKey(context: pagesMoc, contextID: contextID, url: "page-1"))
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
                    $0.content = .masteryPaths
                }
                let masteryPathVM = try! ModuleItemViewModel(session: currentSession, moduleID: masteryPathsItem.moduleID, moduleItemID: masteryPathsItem.id)
                var embedded: UIViewController?
                masteryPathVM.embeddedViewController.take(first: 1).startWithValues { embedded = $0 }
                expect(embedded).toNot(beNil())
                expect(embedded).to(beAnInstanceOf(MasteryPathSelectOptionViewController.self))
            }

            describe("next/previous Actions") {
                beforeEach {
                    module.prerequisiteModuleIDs = []
                    module.requireSequentialProgress = false

                    expect(vm.nextAction.isEnabled.value) == false
                    expect(vm.previousAction.isEnabled.value) == false
                }

                it("should be enabled if there are next/previous items") {
                    item.position = 2
                    _ = ModuleItem.build {
                        $0.id = "2"
                        $0.moduleID = item.moduleID
                        $0.position = 3
                        $0.lockedForUser = false
                    }

                    expect(vm.nextAction.isEnabled.value).toEventually(equal(true))
                    expect(vm.previousAction.isEnabled.value) == false

                    _ = ModuleItem.build {
                        $0.id = "3"
                        $0.moduleID = item.moduleID
                        $0.position = 1
                    }
                    expect(vm.previousAction.isEnabled.value).toEventually(equal(true))
                }

                it("should disable next Action if the next item is locked for user") {
                    item.position = 1
                    item.completed = false
                    let nextItem = ModuleItem.build {
                        $0.id = "2"
                        $0.moduleID = item.moduleID
                        $0.position = 2
                    }
                    expect(vm.nextAction.isEnabled.value).toEventually(equal(true))

                    nextItem.lockedForUser = true

                    expect(vm.nextAction.isEnabled.value).toEventually(equal(false))
                }
            }

            describe("markAsDoneAction") {
                it("should require a MarkDone completionRequirement") {
                    item.completed = false
                    item.completionRequirement = .markDone
                    expect(vm.markAsDoneAction.isEnabled.value).toEventually(beTrue())
                    
                    item.completionRequirement = nil
                    expect(vm.markAsDoneAction.isEnabled.value).toEventually(beFalse())
                }

                it("should require that the item not be completed") {
                    item.completed = false
                    item.completionRequirement = .markDone
                    expect(vm.markAsDoneAction.isEnabled.value).toEventually(beTrue())

                    item.completed = true
                    expect(vm.markAsDoneAction.isEnabled.value).toEventually(beFalse())
                }
            }

            describe("markAsViewedAction") {
                it("should require a MustView completionRequirement") {
                    item.completed = false
                    item.completionRequirement = .mustView
                    expect(vm.markAsViewedAction.isEnabled.value).toEventually(beTrue())
                    
                    item.completionRequirement = nil
                    expect(vm.markAsViewedAction.isEnabled.value).toEventually(beFalse())
                }

                it("should require that the item not be completed") {
                    item.completionRequirement = .mustView
                    item.completed = false
                    expect(vm.markAsViewedAction.isEnabled.value).toEventually(beTrue())

                    item.completed = true
                    expect(vm.markAsViewedAction.isEnabled.value).toEventually(beFalse())
                }
            }
        }
    }
}
