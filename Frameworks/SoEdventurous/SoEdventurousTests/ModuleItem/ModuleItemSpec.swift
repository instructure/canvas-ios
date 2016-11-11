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
@testable import SoPersistent
import CoreData
import Marshal
import SoIconic
import TooLegit
import ReactiveCocoa
import SoProgressive
import Result

class ModuleItemSpec: QuickSpec {
    override func spec() {
        describe("ModuleItem") {
            var session: Session!
            var moc: NSManagedObjectContext!
            beforeEach {
                session = User(credentials: .user1).session
                moc = try! session.soEdventurousManagedObjectContext()
            }

            describe("lockedBySequentialProgress") {
                it("should be true if its position is greater than or equal to the lowest incomplete item") {
                    let module = Module.build(inSession: session) { $0.requireSequentialProgress = true }
                    let complete = ModuleItem.build(inSession: session) {
                        $0.moduleID = module.id
                        $0.completed = true
                        $0.position = 1
                    }
                    expect(try! complete.lockedBySequentialProgress(session)) == false

                    let incomplete = ModuleItem.build(inSession: session) {
                        $0.moduleID = module.id
                        $0.completed = false
                        $0.position = 0
                    }

                    expect(try! incomplete.lockedBySequentialProgress(session)) == false
                    expect(try! complete.lockedBySequentialProgress(session)) == true

                    let otherIncomplete = ModuleItem.build(inSession: session) {
                        $0.moduleID = module.id
                        $0.completed = false
                        $0.position = 2
                    }
                    expect(try! otherIncomplete.lockedBySequentialProgress(session)) == true
                }

                it("should be true if a prerequiste module requires sequential progress with incomplete items") {
                    let sequential = Module.build(inSession: session) {
                        $0.id = "1"
                        $0.requireSequentialProgress = true
                    }
                    let module = Module.build(inSession: session) {
                        $0.id = "2"
                        $0.prerequisiteModuleIDs = [sequential.id]
                    }

                    let incomplete = ModuleItem.build(inSession: session) {
                        $0.moduleID = sequential.id
                        $0.completed = false
                    }

                    let item = ModuleItem.build(inSession: session) {
                        $0.moduleID = module.id
                    }

                    expect(try! item.lockedBySequentialProgress(session)) == true
                }
            }

            describe("next") {
                it("finds next module item") {
                    let moduleItem = ModuleItem.build(inSession: session) { $0.id = "1"; $0.moduleID = "1"; $0.position = 1 }
                    let next = ModuleItem.build(inSession: session) { $0.id = "2"; $0.moduleID = "1"; $0.position = 2 }
                    let otherNext = ModuleItem.build(inSession: session) { $0.id = "3"; $0.moduleID = "1"; $0.position = 3 }
                    expect(try! moduleItem.next(session)?.id) == "2"

                    next.position = 100
                    expect(try! moduleItem.next(session)?.id) == "3"
                }

                it("should find the next mastery path module item") {
                    let moduleItem = ModuleItem.build(inSession: session) { $0.id = "1"; $0.moduleID = "1"; $0.position = 1 }
                    let masteryPathsItem = MasteryPathsItem.factory(inSession: session) {
                        $0.id = "11"
                        $0.moduleItemID = moduleItem.id
                        $0.moduleID = moduleItem.moduleID
                        $0.position = 1.5
                    }
                    expect(try! moduleItem.next(session)?.id) == "11"
                }

                it("skips subheaders") {
                    let moduleItem = ModuleItem.build(inSession: session) { $0.id = "1"; $0.moduleID = "1"; $0.position = 1 }
                    ModuleItem.build(inSession: session) { $0.id = "2"; $0.moduleID = "1"; $0.position = 2; $0.content = .SubHeader }
                    ModuleItem.build(inSession: session) { $0.id = "3"; $0.moduleID = "1"; $0.position = 3; }
                    expect(try! moduleItem.next(session)?.id) == "3"
                }

                it("only searches for module items in the same module") {
                    let moduleItem = ModuleItem.build(inSession: session) { $0.id = "1"; $0.moduleID = "1"; $0.position = 1 }
                    ModuleItem.build(inSession: session) { $0.id = "2"; $0.moduleID = "2"; $0.position = 2 }
                    expect(try! moduleItem.next(session)).to(beNil())
                }
            }

            describe("previous") {
                it("finds previous module item") {
                    let moduleItem = ModuleItem.build(inSession: session) { $0.id = "1"; $0.moduleID = "1"; $0.position = 3 }
                    let previous = ModuleItem.build(inSession: session) { $0.id = "2"; $0.moduleID = "1"; $0.position = 2 }
                    let otherPrevious = ModuleItem.build(inSession: session) { $0.id = "3"; $0.moduleID = "1"; $0.position = 1 }
                    expect(try! moduleItem.previous(session)?.id) == "2"

                    previous.position = 100
                    expect(try! moduleItem.next(session)?.id) == "2"
                }

                it("should find the previous mastery path module item") {
                    let moduleItem = ModuleItem.build(inSession: session) { $0.id = "1"; $0.moduleID = "1"; $0.position = 2 }
                    let masteryPathsItem = MasteryPathsItem.factory(inSession: session) {
                        $0.id = "11"
                        $0.moduleItemID = moduleItem.id
                        $0.moduleID = moduleItem.moduleID
                        $0.position = 1.5
                    }
                    expect(try! moduleItem.previous(session)?.id) == "11"
                }

                it("skips subheaders") {
                    let moduleItem = ModuleItem.build(inSession: session) { $0.id = "1"; $0.moduleID = "1"; $0.position = 3 }
                    ModuleItem.build(inSession: session) { $0.id = "2"; $0.moduleID = "1"; $0.position = 2; $0.content = .SubHeader }
                    ModuleItem.build(inSession: session) { $0.id = "3"; $0.moduleID = "1"; $0.position = 1; }
                    expect(try! moduleItem.previous(session)?.id) == "3"
                }

                it("only searches for module items in the same module") {
                    let moduleItem = ModuleItem.build(inSession: session) { $0.id = "1"; $0.moduleID = "1"; $0.position = 2 }
                    ModuleItem.build(inSession: session) { $0.id = "2"; $0.moduleID = "2"; $0.position = 1; }
                    expect(try! moduleItem.previous(session)).to(beNil())
                }
            }

            context("create") {
                var moduleItem: ModuleItem!
                beforeEach {
                    moduleItem = ModuleItem.create(inContext: moc)
                }

                it("gets inserted") {
                    expect(moc.insertedObjects.contains(moduleItem)) == true
                }

                it("has a default indent") {
                    expect(moduleItem.indent) == 0
                }

                it("has a default position") {
                    expect(moduleItem.position) == 1
                }
            }

            context("validation") {
                var moduleItem: ModuleItem!
                beforeEach {
                    moduleItem = ModuleItem.build(inContext: moc)
                }

                it("has a valid factory") {
                    expect(moduleItem.isValid) == true
                }

                it("allows nil completion requirement") {
                    moduleItem.completionRequirement = nil
                    expect(moduleItem.isValid) == true
                }
            }

            describe("updateValues") {
                var moduleItem: ModuleItem!
                beforeEach {
                    moduleItem = ModuleItem.create(inContext: moc)
                }

                it("removes completion requirements") {
                    moduleItem.completionRequirement = .MinScore
                    moduleItem.minScore = 10
                    moduleItem.completed = true
                    var json = ModuleItem.validJSON
                    json["completion_requirement"] = nil

                    try! moduleItem.updateValues(json, inContext: moc)

                    expect(moduleItem.completionRequirement).to(beNil())
                    expect(moduleItem.minScore).to(beNil())
                    expect(moduleItem.completed) == true
                }

                it("sets completion requirements") {
                    moduleItem.completionRequirement = nil
                    moduleItem.minScore = nil
                    moduleItem.completed = false
                    var json = ModuleItem.validJSON
                    json["completion_requirement"] = [
                        "type": "min_score",
                        "min_score": 10,
                        "completed": true
                    ]

                    try! moduleItem.updateValues(json, inContext: moc)

                    expect(moduleItem.completionRequirement) == .MinScore
                    expect(moduleItem.minScore) == 10
                    expect(moduleItem.completed) == true
                }

                it("throws an error if completion requirement type is unknown") {
                    var json = ModuleItem.validJSON
                    json["completion_requirement"] = [
                        "type": "you don't know me"
                    ]
                    expect { try moduleItem.updateValues(json, inContext: moc) }.to(throwError())
                }

                it("sets assignment content type") {
                    var json = ModuleItem.validJSON
                    json["type"] = "Assignment"
                    json["content_id"] = 1
                    try! moduleItem.updateValues(json, inContext: moc)

                    if let content = moduleItem.content,
                        case .Assignment(let id) = content {
                        expect(id) == "1"
                    } else {
                        fail("expected assignment content type")
                    }
                }

                it("should create a mastery paths module item") {
                    let count = MasteryPathsItem.observeCount(inSession: session)
                    expect {
                        try! moduleItem.updateValues(ModuleItem.jsonWithMasteryPaths, inContext: moc)
                        return try! moc.saveFRD()
                    }.to(change({ count.currentCount }, from: 0, to: 1))
                }

                it("should update the existing mastery paths item") {
                    let masteryPathsItem = MasteryPathsItem.factory(inSession: session) {
                        $0.id = "change me"
                        $0.moduleItemID = "1"
                    }
                    expect {
                        try! moduleItem.updateValues(ModuleItem.jsonWithMasteryPaths, inContext: moc)
                    }.toEventually(change({ masteryPathsItem.id }))
                }

                it("should create assignment sets") {
                    let count = MasteryPathAssignmentSet.observeCount(inSession: session)
                    expect {
                        try! moduleItem.updateValues(ModuleItem.jsonWithMasteryPaths, inContext: moc)
                        return try! moc.saveFRD()
                    }.to(change({ count.currentCount }, from: 0, to: 1))
                }

                it("should cascade delete old assignment sets") {
                    try! moduleItem.updateValues(ModuleItem.validJSON, inContext: moc)
                    let masteryPathsItem = MasteryPathsItem.build(inSession: session) {
                        $0.moduleItemID = "1"
                    }
                    MasteryPathAssignmentSet.build(inSession: session) {
                        $0.masteryPathsItem = masteryPathsItem
                    }

                    var json = ModuleItem.jsonWithMasteryPaths
                    json["mastery_paths"] = nil

                    expect {
                        try! moduleItem.updateValues(json, inContext: moc)
                        return try! moc.saveFRD()
                    }.to(change({ MasteryPathAssignmentSet.count(inContext: moc) }, from: 1, to: 0))
                }

                it("should clean up old mastery path items") {
                    MasteryPathsItem.factory(inSession: session) {
                        $0.moduleItemID = "1"
                    }
                    try! moduleItem.updateValues(ModuleItem.jsonWithMasteryPaths, inContext: moc)
                    try! moc.saveFRD()

                    var json = ModuleItem.jsonWithMasteryPaths
                    json["mastery_paths"] = nil

                    expect {
                        try! moduleItem.updateValues(json, inContext: moc)
                    }.to(change({ MasteryPathsItem.count(inContext: moc) }, from: 1, to: 0))
                }
            }

            describe("markDone") {
                let happyStub = "ModuleItemMarkDone"
                let sadStub = "ModuleItemMarkDoneFailure"
                var happyItem: ModuleItem {
                    return ModuleItem.build(inSession: session) {
                        $0.id = "25474105"
                        $0.moduleID = "3001848"
                        $0.courseID = "1867097"
                        $0.completionRequirement = .MarkDone
                        $0.completed = false
                    }
                }
                var sadItem: ModuleItem {
                    return ModuleItem.build(inSession: session) {
                        $0.id = "does not exist"
                        $0.moduleID = "3001848"
                        $0.courseID = "1867097"
                        $0.completed = true
                    }
                }

                it("should set completed to true") {
                    let session = Session.user1
                    let item = happyItem

                    session.playback(happyStub, in: .soAutomated) {
                        waitUntil { done in
                            try! item.markDone(session).startWithCompletedAction(done)
                        }
                    }

                    expect(item.completed).toEventually(beTrue())
                }

                it("should set completed to false if it fails") {
                    let session = Session.user1
                    let item = sadItem

                    session.playback(sadStub, in: .soAutomated) {
                        waitUntil { done in
                            try! item.markDone(session).startWithFailedAction(done)
                        }
                    }

                    expect(item.completed) == false
                }

                it("should dispatch marked done progress") {
                    let session = Session.user1
                    let item = happyItem
                    var progress: Progress?
                    session.progressDispatcher.onProgress.observeNext { progress = $0 }

                    session.playback(happyStub, in: .soAutomated) {
                        waitUntil { done in
                            try! item.markDone(session).startWithCompletedAction(done)
                        }
                    }

                    expect(progress).toNot(beNil())
                    expect(progress?.kind) == .MarkedDone
                }
            }

            describe("markRead") {
                let happyStub = "ModuleItemMarkRead"
                let sadStub = "ModuleItemMarkReadFailure"
                var happyItem: ModuleItem {
                    return ModuleItem.build(inSession: session) {
                        $0.id = "25915393"
                        $0.moduleID = "3001848"
                        $0.courseID = "1867097"
                    }
                }
                var sadItem: ModuleItem {
                    return ModuleItem.build(inSession: session) {
                        $0.id = "does not exist"
                        $0.moduleID = "3001848"
                        $0.courseID = "1867097"
                        $0.completed = true
                    }
                }

                it("should set completed to true") {
                    let session = Session.user1
                    let item = happyItem
                    
                    session.playback(happyStub, in: .soAutomated) {
                        waitUntil { done in
                            try! item.markRead(session).startWithCompletedAction(done)
                        }
                    }
                    expect(item.completed).toEventually(beTrue())
                }

                it("should set completed to false if it fails") {
                    let session = Session.user1
                    let item = sadItem

                    session.playback(sadStub, in: .soAutomated) {
                        waitUntil { done in
                            try! item.markRead(session).startWithFailedAction(done)
                        }
                    }

                    expect(item.completed) == false
                }

                it("should dispatch viewed progress") {
                    let session = Session.user1
                    let item = happyItem
                    var progress: Progress?
                    session.progressDispatcher.onProgress.observeNext { progress = $0 }

                    session.playback(happyStub, in: .soAutomated) {
                        waitUntil { done in
                            try! item.markRead(session).startWithCompletedAction(done)
                        }
                    }

                    expect(progress).toNot(beNil())
                    expect(progress?.kind) == .Viewed
                }
            }

            describe("observingProgress") {
                var session: Session!
                var moc: NSManagedObjectContext!

                var completedCount = 0
                var errors: [NSError] = []
                beforeEach {
                    session = Session.user1
                    moc = session.managedObjectContext(ModuleItem.self)

                    ModuleItem.beginObservingProgress(session)
                }

                func cacheInvalidated(key: String) -> Bool {
                    let refreshingMoc = try! session.managedObjectContext(SoRefreshingStoreID)
                    let refresh: Refresh? = try! refreshingMoc.findOne(withValue: key, forKey: "key")
                    return refresh != nil
                }

                it("should invalidate modules collection cache if there is a module item matching the progress item type") {
                    let itemID = "25474105"
                    let moduleID = "3001848"
                    let courseID = "1867097"
                    let assignmentID = "1"
                    let progress = Progress(kind: .MarkedDone, contextID: ContextID(id: courseID, context: .Course), itemType: .Assignment, itemID: assignmentID)

                    Module.build(inSession: session) {
                        $0.id = moduleID
                        $0.courseID = courseID
                    }

                    let item = ModuleItem.build(inSession: session) {
                        $0.id = itemID
                        $0.moduleID = moduleID
                        $0.courseID = courseID
                        $0.completionRequirement = .MarkDone
                        $0.completed = false
                        $0.content = .Assignment(id: assignmentID)
                    }

                    session.playback("ModuleItemMarkDone", in: .soAutomated) {
                        var completed = false
                        session.progressDispatcher
                            .onProgress
                            .assumeNoErrors()
                            .filter {
                                $0.itemType == .ModuleItem
                            }
                            .observeNext {
                                completed = completed || $0.itemID == item.id
                            }

                        session.progressDispatcher.dispatch(progress)

                        waitUntil { done in
                            if completed {
                                done()
                            }
                        }
                    }

                    expect(errors).to(beEmpty())
                    expect(cacheInvalidated(Module.collectionCacheKey(moc, courseID: courseID))).toEventually(beTrue())
                    expect(item.completed).toEventually(beTrue())
                }

                it("should invalidate modules collection cache from legacy module item updates") {
                    let itemID = "25915393"
                    let moduleID = "3001848"
                    let courseID = "1867097"
                    let item = ModuleItem.build(inSession: session) {
                        $0.id = itemID
                        $0.moduleID = moduleID
                        $0.courseID = courseID
                        $0.content = .Assignment(id: "1")
                        $0.completionRequirement = .MustView
                    }

                    session.playback("ModuleItemMarkRead", in: .soAutomated) {
                        var completed = false
                        session.progressDispatcher
                            .onProgress
                            .assumeNoErrors()
                            .filter {
                                $0.itemType == .ModuleItem
                            }
                            .observeNext {
                                completed = completed || $0.itemID == item.id
                            }

                        let legacyProgress = Progress(kind: .Viewed, contextID: ContextID(id: "1", context: .User), itemType: .LegacyModuleProgressShim, itemID: "1")
                        session.progressDispatcher.dispatch(legacyProgress)

                        waitUntil(timeout: 3) { done in
                            if completed {
                                done()
                            }
                        }
                    }
                    expect(cacheInvalidated(Module.collectionCacheKey(moc, courseID: courseID))).toEventually(beTrue())
                    expect(item.completed).toEventually(beTrue())
                }
            }
        }
    }
}
