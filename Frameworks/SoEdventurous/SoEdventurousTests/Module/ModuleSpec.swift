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
