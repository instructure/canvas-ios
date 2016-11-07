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
import Quick
import Nimble
import SoAutomated
import TooLegit
import Result

class FileNodeSpec: QuickSpec {
    override func spec() {
        describe("FileNode") {
            describe("refresher") {
                it("creates files and folders") {
                    let session = User(credentials: .user4).session
                    let contextID = ContextID(id: "6782429", context: .User)
                    let refresher = try! FileNode.refresher(session, contextID: contextID, hiddenForUser: false, folderID: "10119415")

                    let count = File.observeCount(inSession: session)
                    expect {
                        refresher.playback("refresh-files-and-folders", in: currentBundle, with: session)
                    }.to(change({ count.currentCount }, from: 0, to: 136))
                }
            }
        }
    }
}
