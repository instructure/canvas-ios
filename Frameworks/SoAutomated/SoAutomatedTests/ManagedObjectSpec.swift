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

import Quick
import Nimble
import SoAutomated
import TooLegit
@testable import FileKit

class ManagedObjectSpec: QuickSpec {
    override func spec() {
        describe("factories") {
            it("should create a valid object") {
                let session = Session.user1
                let node = FileNode.factory(session)
                expect(node.isValid) == true
            }

            it("should create a valid object that is a subentity") {
                let session = Session.user1
                let subentity = File.factory(session)
                expect(subentity.entity.superentity).toNot(beNil())
                expect(subentity.isValid) == true
            }
        }
    }
}
