//
//  ModuleSpec.swift
//  SoEdventurous
//
//  Created by Nathan Armstrong on 9/9/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import SoEdventurous
import Quick
import Nimble
import SoAutomated
import SoPersistent
import CoreData

class ModuleSpec: QuickSpec {
    override func spec() {
        describe("Module") {
            var moc: NSManagedObjectContext!
            var module: Module!
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
}
