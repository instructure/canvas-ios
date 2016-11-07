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
    
    

@testable import EnrollmentKit
import SoAutomated
import Quick
import Nimble
import CoreData
import TooLegit
@testable import SoPersistent

class GradingPeriodItemSpec: QuickSpec {
    override func spec() {
        describe("GradingPeriodItem") {
            describe("all") {
                var all: GradingPeriodItem!
                beforeEach { all = .All }

                it("has the correct title") {
                    expect(all.title) == "All Grading Periods"
                }

                it("has a nil grading period id") {
                    expect(all.gradingPeriodID).to(beNil())
                }
            }

            describe("some") {
                var some: GradingPeriodItem!
                beforeEach {
                    let user = User(credentials: .user1)
                    let managedObjectContext = try! user.session.enrollmentManagedObjectContext()
                    let gradingPeriod = GradingPeriod.build(managedObjectContext, id: "11", title: "Some Title")
                    some = GradingPeriodItem.Some(gradingPeriod)
                }

                it("has the correct title") {
                    expect(some.title) == "Some Title"
                }

                it("has a grading period id") {
                    expect(some.gradingPeriodID) == "11"
                }
            }

            it("is equatable") {
                let user = User(credentials: .user1)
                let managedObjectContext = try! user.session.enrollmentManagedObjectContext()
                let some1 = GradingPeriodItem.Some(GradingPeriod.build(managedObjectContext, id: "1"))
                let some2 = GradingPeriodItem.Some(GradingPeriod.build(managedObjectContext, id: "1"))
                let some3 = GradingPeriodItem.Some(GradingPeriod.build(managedObjectContext, id: "2"))

                expect(GradingPeriodItem.All).to(equal(GradingPeriodItem.All))
                expect(GradingPeriodItem.All).toNot(equal(some1))
                expect(some1).to(equal(some2))
                expect(some1).toNot(equal(some3))
            }
        }
    }
}

class GradingPeriodCollectionSpec: QuickSpec {
    override func spec() {
        describe("GradingPeriodCollection") {
            var session: Session!
            var managedObjectContext: NSManagedObjectContext!
            var course: Course!
            let makeCollection: (Void)->GradingPeriodCollection = {
                let gradingPeriods = try! GradingPeriod.collectionByCourseID(session, courseID: course.id)
                return GradingPeriodCollection(course: course, gradingPeriods: gradingPeriods)
            }

            beforeEach {
                let user = User(credentials: .user1)
                session = user.session
                managedObjectContext = try! user.session.enrollmentManagedObjectContext()
                course = Course.build(inSession: session) { $0.id = "1"; $0.currentGradingPeriodID = "1" }
            }

            describe("selected grading period") {
                context("without grading periods") {
                    var collection: GradingPeriodCollection!
                    beforeEach {
                        collection = makeCollection()
                    }

                    it("defaults to 'all'") {
                        expect(collection.selectedGradingPeriod.value) == GradingPeriodItem.All
                    }
                }

                context("without current grading period") {
                    var collection: GradingPeriodCollection!
                    beforeEach {
                        GradingPeriod.build(managedObjectContext, id: "2", courseID: "1")
                        GradingPeriod.build(managedObjectContext, id: "3", courseID: "1")
                        collection = makeCollection()
                    }

                    it("defaults to 'all'") {
                        expect(collection.selectedGradingPeriod.value) == GradingPeriodItem.All
                    }
                }
            }

            describe("as a collection") {
                var collection: GradingPeriodCollection!
                beforeEach {
                    collection = makeCollection()
                }

                context("with grading periods") {
                    var gradingPeriods: [GradingPeriod]!
                    beforeEach {
                        var updated = false
                        collection.collectionUpdates.observeNext { _ in
                            updated = true
                        }
                        gradingPeriods = [
                            GradingPeriod.build(managedObjectContext, id: "1", courseID: "1", startDate: NSDate(year: 2016, month: 1, day: 1)),
                            GradingPeriod.build(managedObjectContext, id: "2", courseID: "1", startDate: NSDate(year: 2016, month: 1, day: 2))
                        ]
                        managedObjectContext.processPendingChanges()
                        waitUntil { done in
                            if updated { done() }
                        }
                    }
                    let expectUpdate: (CollectionUpdate<GradingPeriodItem>, (Void) -> Void) -> Void = { update, block in
                        var gotUpdate = false
                        collection.collectionUpdates.observeNext { updates in
                            gotUpdate = gotUpdate || updates.indexOf(update) != nil
                        }
                        block()
                        expect(gotUpdate).toEventually(beTrue())
                    }

                    it("has two sections") {
                        expect(collection.numberOfSections()) == 2
                    }

                    it("has 'all' row in first section") {
                        expect(collection.numberOfItemsInSection(1)) == 2
                        expect(collection[NSIndexPath(forRow: 0, inSection: 0)]) == GradingPeriodItem.All
                    }

                    it("has grading periods in second section") {
                        expect(collection[NSIndexPath(forRow: 0, inSection: 1)].gradingPeriodID) == "1"
                        expect(collection[NSIndexPath(forRow: 1, inSection: 1)].gradingPeriodID) == "2"
                    }

                    context("when collection updates") {
                        it("offsets inserts") {
                            let gradingPeriod = GradingPeriod.build(managedObjectContext)
                            expectUpdate(.Inserted(NSIndexPath(forRow: 2, inSection: 1), .Some(gradingPeriod))) {
                                gradingPeriod.courseID = "1"
                            }
                        }

                        context("with object") {
                            var gradingPeriod: GradingPeriod!
                            beforeEach {
                                gradingPeriod = gradingPeriods.first!
                            }

                            it("offsets updates") {
                                expectUpdate(.Updated(NSIndexPath(forRow: 0, inSection: 1), .Some(gradingPeriod))) {
                                    gradingPeriod.title = "Updated title"
                                }
                            }

                            it("offsets deletes") {
                                expectUpdate(.Deleted(NSIndexPath(forRow: 0, inSection: 1), .Some(gradingPeriod))) {
                                    gradingPeriod.delete(inContext: managedObjectContext)
                                }
                            }

                            it("offsets moves") {
                                expectUpdate(.Moved(NSIndexPath(forRow: 0, inSection: 1), NSIndexPath(forRow: 1, inSection: 1), .Some(gradingPeriod))) {
                                    gradingPeriod.startDate = NSDate(year: 2016, month: 1, day: 3)
                                }
                            }
                        }
                    }
                }

                context("without grading periods") {
                    it("has only the all row") {
                        expect(collection.numberOfSections()) == 2
                        expect(collection.numberOfItemsInSection(0)) == 1
                        expect(collection.numberOfItemsInSection(1)) == 0
                        expect(collection.titleForSection(0)).to(beNil())
                        expect(collection[NSIndexPath(forRow: 0, inSection: 0)]) == GradingPeriodItem.All
                    }
                }
            }

            it("forwards 'Reload' updates") {
                var reloaded = false
                let gradingPeriods = try! GradingPeriod.collectionByCourseID(session, courseID: course.id)
                let collection = GradingPeriodCollection(course: course, gradingPeriods: gradingPeriods)
                collection.collectionUpdates.observeNext { updates in
                    reloaded = reloaded || updates.contains(.Reload)
                }
                gradingPeriods.updatesObserver.sendNext([.Reload])
                expect(reloaded).toEventually(beTrue())
            }
        }
    }
}
