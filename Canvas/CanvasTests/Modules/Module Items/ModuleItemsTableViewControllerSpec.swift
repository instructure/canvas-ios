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
@testable import SoEdventurous
import SoPersistent
import CoreData
import SoLazy

class ModuleItemsTableViewControllerSpec: QuickSpec {
    override func spec() {
        describe("ModuleItemsTableViewController") {
            beforeEach { login() }

            it("updates the collection when the module changes") {
                let vc = try! ModuleItemsTableViewController(session: currentSession, courseID: "1", moduleID: "1", route: ignoreRouteAction)
                expect(vc.collection).to(beNil())
                Module.build() { $0.courseID = "1"; $0.id = "1" }
                expect(vc.collection).toEventuallyNot(beNil())
            }

            it("updates the title when the module changes") {
                let module = Module.build { $0.name = "CHANGE ME" }
                let vc = try! ModuleItemsTableViewController(session: currentSession, courseID: module.courseID, moduleID: module.id, route: ignoreRouteAction)
                expect(vc.title) == "CHANGE ME"

                module.name = "CHANGED"

                expect(vc.title).toEventually(equal("CHANGED"))
            }

            it("has a refresher") {
                let vc = try! ModuleItemsTableViewController(session: currentSession, courseID: "1", moduleID: "1", route: ignoreRouteAction)
                expect(vc.refresher).toNot(beNil())
            }
        }
    }
}

class ModuleItemCollectionsSpec: QuickSpec {
    override func spec() {
        describe("module items collection") {
            beforeEach { login() }

            it("has 2 sections") {
                let collection = try! ModuleItem.collection(currentSession, module: Module.build())
                expect(collection.numberOfSections()) == 2
            }

            it("has prerequisite modules in the first section") {
                Module.build {
                    $0.id = "1"
                    $0.position = 1
                }
                Module.build {
                    $0.id = "2"
                    $0.position = 2
                }
                let module = Module.build {
                    $0.id = "3"
                    $0.prerequisiteModuleIDs = ["1", "2"]
                }
                let collection = try! ModuleItem.collection(currentSession, module: module)

                expect(collection.numberOfItemsInSection(0)) == 2
                expect((collection[NSIndexPath(forRow: 0, inSection: 0)] as? Module)?.id) == "1"
                expect((collection[NSIndexPath(forRow: 1, inSection: 0)] as? Module)?.id) == "2"
            }

            it("has module items in the second section") {
                let module = Module.build { $0.id = "1" }
                ModuleItem.build {
                    $0.id = "1"
                    $0.moduleID = module.id
                    $0.position = 1
                }
                ModuleItem.build {
                    $0.id = "2"
                    $0.moduleID = module.id
                    $0.position = 2
                }
                let collection = try! ModuleItem.collection(currentSession, module: module)

                expect(collection.numberOfItemsInSection(1)) == 2
                expect((collection[NSIndexPath(forRow: 0, inSection: 1)] as? ModuleItem)?.id) == "1"
                expect((collection[NSIndexPath(forRow: 1, inSection: 1)] as? ModuleItem)?.id) == "2"
            }

            it("excludes module items in other modules") {
                let module = Module.build { $0.id = "1" }
                ModuleItem.build {
                    $0.moduleID = "2"
                }
                let collection = try! ModuleItem.collection(currentSession, module: module)
                expect(collection.numberOfItemsInSection(1)) == 0
            }

            it("excludes modules not in prerequisiteModuleIDs array") {
                let module = Module.build {
                    $0.id = "1"
                    $0.courseID = "1"
                    $0.prerequisiteModuleIDs = ["2"]
                }
                Module.build {
                    $0.id = "3"
                    $0.courseID = "1"
                }
                let collection = try! ModuleItem.collection(currentSession, module: module)
                expect(collection.numberOfItemsInSection(0)) == 0
            }

            it("excludes prerequiste modules not in the same course") {
                let module = Module.build {
                    $0.id = "1"
                    $0.courseID = "1"
                    $0.prerequisiteModuleIDs = ["2"]
                }
                Module.build {
                    $0.id = "2"
                    $0.courseID = "2"
                }
                let collection = try! ModuleItem.collection(currentSession, module: module)
                expect(collection.numberOfItemsInSection(0)) == 0
            }
        }
    }
}
