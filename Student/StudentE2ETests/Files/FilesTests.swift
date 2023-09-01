//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import TestsFoundation

class FilesTests: E2ETestCase {
    typealias Helper = FilesHelper
    typealias FileList = Helper.List
    typealias Details = Helper.Details
    typealias PDFViewer = Helper.PDFViewer
    typealias Dashboard = DashboardHelper
    typealias Profile = ProfileHelper

    let testFolderName = "Test Folder"

    func testCreateTestFolderAndUploadPDF() {
        // MARK: Download and save test PDF file
        Helper.TestPDF.download()
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 30))

        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Files, create test folder
        logInDSUser(student)

        let profileButton = Dashboard.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.hit()
        let filesButton = Profile.filesButton.waitUntil(.visible)
        XCTAssertTrue(filesButton.isVisible)

        filesButton.hit()
        let noFilesLabel = Helper.noFilesLabel.waitUntil(.visible)
        XCTAssertTrue(noFilesLabel.isVisible)

        let addButton = FileList.addButton.waitUntil(.visible)
        XCTAssertTrue(addButton.isVisible)

        addButton.hit()

        let addFolderButton = FileList.addFolderButton.waitUntil(.visible)
        XCTAssertTrue(addFolderButton.isVisible)

        addFolderButton.hit()

        let folderNameInput = FileList.folderNameInput.waitUntil(.visible)
        let okButton = FileList.okButton.waitUntil(.visible)
        XCTAssertTrue(folderNameInput.isVisible)
        XCTAssertTrue(okButton.isVisible)

        folderNameInput.writeText(text: testFolderName)
        okButton.hit()
        let testFolder = FileList.file(index: 0).waitUntil(.visible)
        XCTAssertTrue(testFolder.isVisible)

        // MARK: Upload test PDF to the test folder
        testFolder.hit()
        addButton.hit()
        let addFileButton = FileList.addFileButton.waitUntil(.visible)
        XCTAssertTrue(addFileButton.isVisible)

        addFileButton.hit()
        let uploadFileButton = FileList.uploadFileButton.waitUntil(.visible)
        XCTAssertTrue(uploadFileButton.isVisible)

        uploadFileButton.hit()
        let testPDFButton = FileList.testPDFButton.waitUntil(.visible)
        XCTAssertTrue(testPDFButton.isVisible)

        // MARK: Check uploaded file in list
        testPDFButton.hit()
        let uploadedFileListItem = FileList.file(index: 0).waitUntil(.visible)
        XCTAssertTrue(uploadedFileListItem.isVisible)
        XCTAssertTrue(uploadedFileListItem.hasLabel(label: Helper.TestPDF.name, strict: false))

        // MARK: Tap test PDF file, check details
        uploadedFileListItem.hit()
        let PDFView = PDFViewer.PDFView.waitUntil(.visible)
        let testText1 = PDFViewer.testText1.waitUntil(.visible)
        let testText2 = PDFViewer.testText2.waitUntil(.visible)
        let testText3 = PDFViewer.testText3.waitUntil(.visible)
        XCTAssertTrue(PDFView.isVisible)
        XCTAssertTrue(testText1.isVisible)
        XCTAssertTrue(testText2.isVisible)
        XCTAssertTrue(testText3.isVisible)

        let backButton = Helper.backButton.waitUntil(.visible)
        XCTAssertTrue(backButton.isVisible)

        // MARK: Tap back button, delete the file
        backButton.hit()
        uploadedFileListItem.actionUntilElementCondition(action: .swipeLeft(.onElement), element: FileList.deleteButton, condition: .visible)
        let deleteButton = FileList.deleteButton.waitUntil(.visible)
        XCTAssertTrue(deleteButton.isVisible)

        deleteButton.hit()

        let areYouSureLabel = FileList.areYouSureLabel.waitUntil(.visible)
        XCTAssertTrue(areYouSureLabel.isVisible)

        deleteButton.hit()
        deleteButton.waitUntil(.vanish)
        XCTAssertTrue(uploadedFileListItem.waitUntil(.vanish).isVanished)
    }

    func testCreateTestFolderAndUploadImage() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Files, create test folder
        logInDSUser(student)

        Helper.navigateToFiles()
        let folderIsCreated = FileList.createFolder(name: Helper.testImageName, shouldOpen: true)
        XCTAssertTrue(folderIsCreated)

        // MARK: Upload test image, check result
        FileList.addButton.hit()
        FileList.addFileButton.hit()

        let uploadImageButton = FileList.uploadImageButton.waitUntil(.visible)
        XCTAssertTrue(uploadImageButton.isVisible)

        uploadImageButton.hit()
        let imageItem = FileList.imageItem.waitUntil(.visible)
        XCTAssertTrue(imageItem.isVisible)

        imageItem.hit()
        imageItem.waitUntil(.vanish)

        let uploadedImageItem = FileList.file(index: 0).waitUntil(.visible, timeout: 60)
        XCTAssertTrue(uploadedImageItem.isVisible)

        uploadedImageItem.hit()

        let imageView = Details.imageView.waitUntil(.visible)
        let backButton = Helper.backButton.waitUntil(.visible)
        XCTAssertTrue(imageView.isVisible)
        XCTAssertTrue(backButton.isVisible)

        backButton.hit()

        // MARK: Delete image
        uploadedImageItem.actionUntilElementCondition(action: .swipeLeft(.onElement), element: FileList.deleteButton, condition: .visible)
        let deleteButton = FileList.deleteButton.waitUntil(.visible)
        XCTAssertTrue(deleteButton.isVisible)

        deleteButton.hit()
        let areYouSureLabel = FileList.areYouSureLabel.waitUntil(.visible)
        XCTAssertTrue(areYouSureLabel.isVisible)

        deleteButton.hit()
        deleteButton.waitUntil(.vanish)
        XCTAssertTrue(uploadedImageItem.waitUntil(.vanish).isVanished)
    }
}
