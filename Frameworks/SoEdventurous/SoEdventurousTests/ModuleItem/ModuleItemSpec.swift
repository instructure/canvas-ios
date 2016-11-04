
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
