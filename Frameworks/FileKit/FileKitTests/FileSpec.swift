
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
    
    

@testable import FileKit
import SoAutomated
import TooLegit
import UIKit
import Quick
import Nimble

class FileSpec: QuickSpec {
    override func spec() {
        describe("File") {
            describe("deleteFileNode") {
                it("through a network call should delete the file") {
                    let session = User(credentials: .user4).session
                    let contextID = ContextID(id: "6782429", context: .User)
                    let file = File.build(inSession: session) {
                        $0.id = "85285506"
                        $0.contextID = contextID
                        $0.name = "file"
                    }
                    let count = File.observeCount(inSession: session)
                    expect {
                        session.playback("delete-file", in: currentBundle) {
                            waitUntil { done in
                                try! file.deleteFileNode(session, shouldForce: true).startWithCompletedAction(done)
                            }
                            try! session.filesManagedObjectContext().processPendingChanges()
                        }
                    }.to(change({ count.currentCount }, from: 1, to: 0))
                }
            }
        }
    }
}
