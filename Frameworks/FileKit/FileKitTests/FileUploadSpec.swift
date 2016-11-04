
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
    
    

import SoAutomated
@testable import FileKit
import CoreData
import ReactiveCocoa
import TooLegit
import AVFoundation
import SoPersistent
import Quick
import Nimble

class FileUploadSpec: QuickSpec {
    override func spec() {
        describe("FileUpload") {
            describe("begin") {
                it("through a series of requests creates a file") {
                    let session = User(credentials: .user4).session
                    let data = NSData(contentsOfURL: currentBundle.URLForResource("testfile", withExtension: "txt")!)!
                    let parentFolderID = "6782429"
                    let path = "/api/v1/users/\(parentFolderID)/files"

                    let context = try! session.filesManagedObjectContext()
                    let upload = FileUpload.createInContext(context)
                    upload.prepare("unit test", path: path, data: data, name: "testfile.txt", contentType: nil, parentFolderID: parentFolderID, contextID: ContextID(id: parentFolderID, context: .User))
                    
                    let predicate = NSPredicate(format: "%K == %@", "backgroundSessionID", "unit test")
                    let observer = try! ManagedObjectObserver<FileUpload>(predicate: predicate, inContext: context)
                    var disposable: Disposable?

                    session.playback("upload-file", in: currentBundle) {
                        waitUntil { done in
                            disposable = observer.signal.observeResult { result in
                                expect(result.error).to(beNil())
                                if let upload = result.value?.1 {
                                    expect(upload.errorMessage).to(beNil())
                                    if upload.hasCompleted && upload.file != nil {
                                        done()
                                    }
                                }
                            }
                            upload.begin(inSession: session, inContext: context)
                        }
                    }

                    expect(upload.file).toNot(beNil())
                    
                    disposable?.dispose()
                }
            }
        }
    }
}
