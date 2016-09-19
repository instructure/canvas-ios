//
//  ModuleItemSpec.swift
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

class ModuleItemSpec: QuickSpec {
    override func spec() {
        describe("ModuleItem") {
            var moc: NSManagedObjectContext!
            var moduleItem: ModuleItem!
            beforeEach {
                moc = try! User(credentials: .user1).session.soEdventurousManagedObjectContext()
                moduleItem = ModuleItem(inContext: moc)
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
    }
}
