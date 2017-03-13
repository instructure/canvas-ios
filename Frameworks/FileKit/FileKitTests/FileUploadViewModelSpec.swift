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
import XCTest
@testable import FileKit
import ReactiveSwift
import Result
import TooLegit
import SoPersistent
import CoreData
import SoIconic
import SoLazy

class FileUploadViewModelTests: XCTestCase {
    let session = Session.user1
    let vm: FileUploadViewModelType = FileUploadViewModel()

    let statusText = TestObserver<String, NoError>()
    let errorInfoButtonIsHidden = TestObserver<Bool, NoError>()
    let showError = TestObserver<String, NoError>()
    let statusIcon = TestObserver<Icon, NoError>()
    let graphic = TestObserver<Graphic, NoError>()
    let imageData = TestObserver<Data, NoError>()
    let progress = TestObserver<Double, NoError>()
    let fileName = TestObserver<String, NoError>()
    let statusTextColor = TestObserver<UIColor, NoError>()
    let statusIconColor = TestObserver<UIColor?, NoError>()

    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        self.context = try! session.filesManagedObjectContext()

        self.vm.outputs.statusText.observe(self.statusText.observer)
        self.vm.outputs.errorInfoButtonIsHidden.observe(self.errorInfoButtonIsHidden.observer)
        self.vm.outputs.showError.observe(self.showError.observer)
        self.vm.outputs.statusIcon.observe(self.statusIcon.observer)
        self.vm.outputs.graphic.observe(self.graphic.observer)
        self.vm.outputs.imageData.observe(self.imageData.observer)
        self.vm.outputs.progress.observe(self.progress.observer)
        self.vm.outputs.fileName.observe(self.fileName.observer)
        self.vm.outputs.statusTextColor.observe(self.statusTextColor.observer)
        self.vm.outputs.statusIconColor.observe(self.statusIconColor.observer)
    }

    func testOutputs_FileUploadIs_Failed() {
        let error = NSError(subdomain: "FileKit", description: "The server stopped responding.")
        self.context.performAndWait {
            let fileUpload = FileUpload.template(session: self.session)
            fileUpload.startWithTask(DummyTask())
            fileUpload.failWithError(error)
            self.vm.inputs.fileUpload(fileUpload, session: self.session)
        }

        self.statusText.assertValues(["Failed"])
        self.errorInfoButtonIsHidden.assertValues([false])
        self.statusIcon.assertValues([.refresh])
        self.progress.assertValues([0])
        self.fileName.assertValues(["IMG_1234"])
        self.statusTextColor.assertValues([.fileKit_uploadInterrupted])
        self.statusIconColor.assertValues([nil])
    }

    func testOutputs_FileUploadIs_Document() {
        self.context.performAndWait {
            let fileUpload = FileUpload.template(session: self.session)
            fileUpload.name = "applicationfiles.docx"
            fileUpload.contentType = "application/msword"
            self.vm.inputs.fileUpload(fileUpload, session: self.session)
        }

        self.graphic.assertValueCount(1)
        expect(self.graphic.lastValue?.icon) == .page
        self.imageData.assertDidNotEmitValue()
        self.fileName.assertValues(["applicationfiles.docx"])
    }

    func testOutputs_FileUploadIs_Image() {
        self.context.performAndWait {
            let fileUpload = FileUpload.template(session: self.session)
            fileUpload.contentType = "image/jpeg"
            self.vm.inputs.fileUpload(fileUpload, session: self.session)
        }

        self.graphic.assertDidNotEmitValue()
        self.imageData.assertValueCount(1)
    }

    func testOutputs_FileUploadIs_InProgress() {
        var fileUpload: FileUpload!
        self.context.performAndWait {
            fileUpload = FileUpload.template(session: self.session)
            fileUpload.startWithTask(DummyTask())
            self.vm.inputs.fileUpload(fileUpload, session: self.session)
        }

        self.statusText.assertValues(["uploading..."])
        self.progress.assertValues([5], "it sends a min progress when started")
        self.statusIcon.assertValues([.cancel])
        self.errorInfoButtonIsHidden.assertValues([true])
        self.statusTextColor.assertValues([.fileKit_uploadInProgress])
        self.statusIconColor.assertValues([.fileKit_uploadInProgress])

        self.context.performAndWait {
            fileUpload.process(sent: 10, of: 100)
            self.vm.inputs.fileUpload(fileUpload, session: self.session)
        }

        self.statusText.assertValues(["uploading..."], "it should skip repeats")
        self.progress.assertValues([5, 10])
        self.statusIcon.assertValues([.cancel], "it should skip repeats")
    }

    func testOutputs_FileUploadIs_Stopped() {
        self.context.performAndWait {
            let fileUpload = FileUpload.template(session: self.session)
            fileUpload.start()
            fileUpload.abort()
            self.vm.inputs.fileUpload(fileUpload, session: self.session)
        }

        self.statusText.assertValues(["Stopped"])
        self.statusIcon.assertValues([.refresh])
        self.errorInfoButtonIsHidden.assertValues([true])
        self.progress.assertValues([0])
        self.statusTextColor.assertValues([.fileKit_uploadInterrupted])
        self.statusIconColor.assertValues([nil])
    }

    func testOutputs_FileUploadIs_Completed() {
        self.context.performAndWait {
            let fileUpload = FileUpload.template(session: self.session)
            let file = File.template(session: self.session)
            fileUpload.start()
            fileUpload.complete(file: file)
            self.vm.inputs.fileUpload(fileUpload, session: self.session)
        }

        self.statusText.assertValues(["Complete"])
        self.statusIcon.assertValues([.todo])
        self.errorInfoButtonIsHidden.assertValues([true])
        self.progress.assertValues([0])
        self.statusTextColor.assertValues([.fileKit_uploadCompleted])
        self.statusIconColor.assertValues([.fileKit_uploadCompleted])
    }

    func testOutputs_ShowError() {
        let error = NSError(subdomain: "FileKit", description: "The server stopped responding.")
        self.context.performAndWait {
            let fileUpload = FileUpload.template(session: self.session)
            fileUpload.start()
            fileUpload.failWithError(error)
            self.vm.inputs.fileUpload(fileUpload, session: self.session)
        }

        self.vm.inputs.tappedErrorInfoButton()

        self.showError.assertValues(["The server stopped responding."])
    }
}
