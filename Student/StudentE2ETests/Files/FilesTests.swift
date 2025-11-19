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
import XCTest

class FilesTests: E2ETestCase {
    typealias Helper = FilesHelper
    typealias FileList = Helper.List
    typealias Details = Helper.Details
    typealias PDFViewer = Helper.PDFViewer
    typealias Dashboard = DashboardHelper
    typealias Profile = ProfileHelper

    let testFolderName = "Test Folder"

    func downloadTestPDF() {
        SafariAppHelper.safariApp.launch()
        var addressLabel = SafariAppHelper.addressLabelIpad.waitUntil(.visible, timeout: 5)
        if addressLabel.isVisible {
            addressLabel.hit()
        } else {
            SafariAppHelper.tabBarItemTitle.hit()
            addressLabel = SafariAppHelper.URL.waitUntil(.visible)
        }
        let clearTextButton = SafariAppHelper.clearTextButton.waitUntil(.visible, timeout: 5)
        if clearTextButton.isVisible, clearTextButton.isHittable { clearTextButton.hit() }
        addressLabel.waitUntil(.visible)
        XCTAssertVisible(addressLabel)

        addressLabel.writeText(text: FilesHelper.TestPDF.url, hitEnter: true, customApp: SafariAppHelper.safariApp)
        let shareButton = SafariAppHelper.shareButton.waitUntil(.visible)
        XCTAssertVisible(shareButton)

        shareButton.hit()
        let titleOfFile = SafariAppHelper.Share.titleLabel(title: FilesHelper.TestPDF.title).waitUntil(.visible)
        XCTAssertVisible(titleOfFile)

        let moreButton = SafariAppHelper.Share.moreButton.waitUntil(.visible)
        moreButton.swipeUp()
        let saveToFilesButton = SafariAppHelper.Share.saveToFiles.waitUntil(.visible)
        XCTAssertVisible(saveToFilesButton)

        saveToFilesButton.hit()
        var onMyButton = SafariAppHelper.Share.onMyIpadCell.waitUntil(.visible, timeout: 5)
        if onMyButton.isVanished { onMyButton = SafariAppHelper.Share.onMyIphoneButton.waitUntil(.visible) }
        XCTAssertVisible(onMyButton)

        onMyButton.hit()
        let onMyLabel = SafariAppHelper.Share.onMyLabel.waitUntil(.visible)
        XCTAssertVisible(onMyLabel)

        let saveButton = SafariAppHelper.Share.saveButton.waitUntil(.visible)
        XCTAssertVisible(saveButton)

        saveButton.hit()
        let replaceButton = SafariAppHelper.replaceButton.waitUntil(.visible, timeout: 5)
        if replaceButton.isVisible { replaceButton.hit() }
    }

    func testCreateTestFolderAndUploadPDF() throws {
        try XCTSkipIf(true,
            """
            The save dialog changed and it now automatically enters the \"On My iPhone\" folder on iPhone. Needs to be checked on iPad as well. \
            Sometimes a tutorial is shown about the slide to type keyboard feature that also needs to be dismissed.
            """
        )
        // MARK: Download and save test PDF file
        downloadTestPDF()
        app.activate()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Files, create test folder
        logInDSUser(student)
        let profileButton = Dashboard.profileButton.waitUntil(.visible)
        XCTAssertVisible(profileButton)

        profileButton.hit()
        let filesButton = Profile.filesButton.waitUntil(.visible)
        XCTAssertVisible(filesButton)

        filesButton.hit()
        let noFilesLabel = Helper.noFilesLabel.waitUntil(.visible)
        XCTAssertVisible(noFilesLabel)

        let addButton = FileList.addButton.waitUntil(.visible)
        XCTAssertVisible(addButton)

        addButton.hit()
        let addFolderButton = FileList.addFolderButton.waitUntil(.visible)
        XCTAssertVisible(addFolderButton)

        addFolderButton.hit()
        let folderNameInput = FileList.folderNameInput.waitUntil(.visible)
        let okButton = FileList.okButton.waitUntil(.visible)
        XCTAssertVisible(folderNameInput)
        XCTAssertVisible(okButton)

        folderNameInput.writeText(text: testFolderName)
        okButton.hit()
        let testFolder = FileList.file(index: 0).waitUntil(.visible)
        XCTAssertVisible(testFolder)

        // MARK: Upload test PDF to the test folder
        testFolder.hit()
        XCTAssertTrue(testFolder.waitUntil(.vanish).isVanished)

        addButton.hit()
        XCTAssertTrue(addButton.waitUntil(.vanish).isVanished)

        let addFileButton = FileList.addFileButton.waitUntil(.visible)
        XCTAssertVisible(addFileButton)

        addFileButton.hit()
        XCTAssertTrue(addFileButton.waitUntil(.vanish).isVanished)

        let uploadFileButton = FileList.uploadFileButton.waitUntil(.visible)
        XCTAssertVisible(uploadFileButton)

        uploadFileButton.hit()
        XCTAssertTrue(uploadFileButton.waitUntil(.vanish).isVanished)

        var buttonToBeSelected = FileList.onMyIpadButton.waitUntil(.visible, timeout: 5)
        if buttonToBeSelected.isVanished { buttonToBeSelected = FileList.browseButton.waitUntil(.visible) }
        XCTAssertVisible(buttonToBeSelected)

        if !buttonToBeSelected.isSelected { buttonToBeSelected.hit() }
        let testPDFButton = FileList.testPDFButton.waitUntil(.visible)
        XCTAssertVisible(testPDFButton)

        testPDFButton.hit()
        XCTAssertTrue(testPDFButton.waitUntil(.vanish).isVanished)

        // MARK: Check uploaded file in list
        let uploadedFileListItem = FileList.file(index: 0).waitUntil(.visible)
        XCTAssertVisible(uploadedFileListItem)
        XCTAssertContains(uploadedFileListItem.label, Helper.TestPDF.title)

        // MARK: Tap test PDF file, check details
        uploadedFileListItem.hit()
        let PDFView = PDFViewer.PDFView.waitUntil(.visible)
        let testText1 = PDFViewer.testText1.waitUntil(.visible)
        let testText2 = PDFViewer.testText2.waitUntil(.visible)
        let testText3 = PDFViewer.testText3.waitUntil(.visible)
        XCTAssertVisible(PDFView)
        XCTAssertVisible(testText1)
        XCTAssertVisible(testText2)
        XCTAssertVisible(testText3)

        let backButton = Helper.backButton.waitUntil(.visible)
        XCTAssertVisible(backButton)

        // MARK: Delete the file
        if uploadedFileListItem.isVanished { backButton.hit() }
        uploadedFileListItem.actionUntilElementCondition(action: .swipeLeft(.onElement), element: FileList.deleteButton, condition: .visible)
        let deleteButton = FileList.deleteButton.waitUntil(.visible)
        XCTAssertVisible(deleteButton)

        deleteButton.hit()
        let areYouSureLabel = FileList.areYouSureLabel.waitUntil(.visible)
        XCTAssertVisible(areYouSureLabel)

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
        let profileButton = Dashboard.profileButton.waitUntil(.visible)
        XCTAssertVisible(profileButton)

        Helper.navigateToFiles()
        let folderIsCreated = FileList.createFolder(name: testFolderName, shouldOpen: true)
        XCTAssertTrue(folderIsCreated)

        // MARK: Upload test image, check result
        FileList.addButton.hit()
        FileList.addFileButton.hit()
        let uploadImageButton = FileList.uploadImageButton.waitUntil(.visible)
        XCTAssertVisible(uploadImageButton)

        uploadImageButton.hit()
        let imageItem = FileList.imageItem.waitUntil(.visible)
        XCTAssertVisible(imageItem)

        imageItem.forceTap()
        imageItem.waitUntil(.vanish)
        XCTAssertTrue(imageItem.isVanished)

        let uploadedImageItem = FileList.file(index: 0).waitUntil(.visible, timeout: 60)
        XCTAssertVisible(uploadedImageItem)

        uploadedImageItem.hit()
        let imageView = Details.imageView.waitUntil(.visible, timeout: 60)
        let backButton = Helper.backButton.waitUntil(.visible)
        XCTAssertVisible(imageView)
        XCTAssertVisible(backButton)

        // MARK: Delete image
        backButton.hit()
        uploadedImageItem.actionUntilElementCondition(action: .swipeLeft(.onElement), element: FileList.deleteButton, condition: .visible)
        let deleteButton = FileList.deleteButton.waitUntil(.visible)
        XCTAssertVisible(deleteButton)

        deleteButton.hit()
        let areYouSureLabel = FileList.areYouSureLabel.waitUntil(.visible)
        XCTAssertVisible(areYouSureLabel)

        deleteButton.hit()
        deleteButton.waitUntil(.vanish)
        XCTAssertTrue(uploadedImageItem.waitUntil(.vanish).isVanished)
    }
}
