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
    
    

@testable import SoEdventurous
import Quick
import Nimble
import SoAutomated
import SoPersistent
import CoreData
import AVFoundation
import WebKit
import TooLegit
import Result
import Marshal
import ReactiveCocoa

class ModuleSpec: QuickSpec {
    override func spec() {
        describe("Module") {
            context("init") {
                var module: Module!
                var moc: NSManagedObjectContext!
                beforeEach {
                    moc = try! User(credentials: .user1).session.soEdventurousManagedObjectContext()
                    module = Module(inContext: moc)
                }

                it("gets inserted") {
                    expect(moc.insertedObjects.contains(module)) == true
                }

                it("has a default position") {
                    expect(module.position) == 1
                }

                it("has a default item count") {
                    expect(module.itemCount) == 0
                }
            }
        }

        describe("updateValues") {
            var module: Module!
            var session: Session!
            var moc: NSManagedObjectContext!
            beforeEach {
                session = .user1
                moc = try! session.soEdventurousManagedObjectContext()
                module = Module(inContext: moc)
            }

            it("updates prerequisiteModuleIDs") {
                module.prerequisiteModuleIDs = []
                var json = Module.validJSON
                json["prerequisite_module_ids"] = [1, 2, 3]
                try! module.updateValues(json, inContext: module.managedObjectContext!)
                expect(module.prerequisiteModuleIDs).to(contain("1"))
                expect(module.prerequisiteModuleIDs).to(contain("2"))
                expect(module.prerequisiteModuleIDs).to(contain("3"))

                json["prerequisite_module_ids"] = []
                try! module.updateValues(json, inContext: module.managedObjectContext!)
                expect(module.prerequisiteModuleIDs).to(beEmpty())
                expect(module.hasPrerequisites) == false
            }

            it("should update the state") {
                module.state = .locked
                var json = Module.validJSON
                json["state"] = "unlocked"

                try! module.updateValues(json, inContext: moc)

                expect(module.state) == .unlocked
            }

            it("should set state to nil if it is completed and there are no items") {
                module.state = .completed
                var json = Module.validJSON
                json["state"] = "completed"
                json["items"] = []

                try! module.updateValues(json, inContext: moc)

                expect(module.state).to(beNil())
            }

            it("should set state to nil if it is completed and items is nil") {
                module.state = .completed
                var json = Module.validJSON
                json["state"] = "completed"
                json["items"] = nil

                try! module.updateValues(json, inContext: moc)

                expect(module.state).to(beNil())
            }

            it("should set state to nil if it is completed and no items have completion requirements") {
                module.state = .completed
                var json = Module.validJSON
                json["state"] = "completed"
                var itemJSON = ModuleItem.validJSON
                itemJSON["completion_requirement"] = nil
                json["items"] = [itemJSON]

                try! module.updateValues(json, inContext: moc)

                expect(module.state).to(beNil())
            }
        }

        describe("refreshers") {
            describe("collection refresher") {
                it("syncs modules") {
                    let session = User(credentials: .user1).session
                    let count = Module.observeCount(inSession: session)

                    let refresher = try! Module.refresher(session, courseID: "1867097")
                    expect {
                        refresher.playback("RefreshModules", in: .soAutomated, with: session)
                    }.to(change({ count.currentCount }, from: 0, to: 2))
                }
            }

            describe("details refresher") {
                it("should not clear module states") {
                    let session = User(credentials: .s4Beta).session

                    let moduleID = "3060274"
                    let courseID = "2045792"
                    let module = Module.build(inSession: session) {
                        $0.id = moduleID
                        $0.courseID = courseID
                        $0.state = .completed
                    }

                    let refresher = try! Module.refresher(session, courseID: courseID, moduleID: moduleID)

                    refresher.playback("RefreshModule", in: .soAutomated, with: session)

                    expect(module.reload().state) == .completed
                }
            }
        }
    }
}
