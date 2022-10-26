//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Core

class FilesUITests: MiniCanvasUITestCase {
    var firstFile: MiniFile? {
        guard let fileID = firstCourse.courseFiles?.fileIDs.first else {
            return nil
        }
        return mocked.files[fileID]
    }

    func testUploadAudioFile() throws {
        // Disabled test, Swifter can't seem to parse our form data. To re-enable it, right click on the test symbol and select enabled or edit NightlyTests.xctestplan
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.files.tap()

        FileList.addButton.tap()
        app.find(label: "Add File").tap()
        allowAccessToMicrophone {
            app.find(label: "Record Audio").tap()
        }

        AudioRecorder.recordButton.tap()
        AudioRecorder.stopButton.tap()
        AudioRecorder.sendButton.tap()

        app.find(labelContaining: "Not Published").waitToExist()

        let newFileId = try XCTUnwrap(firstCourse.courseFiles?.fileIDs.last)
        let file = try XCTUnwrap(mocked.files[newFileId])
        XCTAssertEqual(file.api.contentType, "audio/x-m4a")
        XCTAssertNotNil(file.contents)
    }

    func testAddFileFromLibrary() throws {
        // Disabled test, Swifter can't seem to parse our form data. To re-enable it, right click on the test symbol and select enabled or edit NightlyTests.xctestplan
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.files.tap()

        FileList.addButton.tap()
        app.find(label: "Add File").tap()
        allowAccessToPhotos {
            app.find(label: "Photo Library").tap()
        }

        app.find(labelContaining: "Photo, ").tap()

        app.find(labelContaining: "Not Published").waitToExist()

        let newFileId = try XCTUnwrap(firstCourse.courseFiles?.fileIDs.last)
        let file = try XCTUnwrap(mocked.files[newFileId])
        XCTAssertEqual(file.api.contentType, "image/jpeg")
        XCTAssertNotNil(file.contents)
    }

    func testAddFolder() throws {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.files.tap()

        FileList.addButton.tap()
        app.find(label: "Add Folder").tap()
        app.alerts.textFields.firstElement.typeText("top secret!")
        app.find(label: "OK", type: .button).tap()

        app.find(labelContaining: "Published, top secret!").waitToExist()
        let folderID = try XCTUnwrap(firstCourse.courseFiles?.folderIDs.last)
        XCTAssertEqual(mocked.folders[folderID]?.api.name, "top secret!")
    }

    func testEditUsageRights() throws {
        firstCourse.settings = .make(usage_rights_required: true)

        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.files.tap()
        FileList.file(index: 0).tap()
        FileDetails.editButton.tap()

        // FileEditor.copyrightField.typeText("me") // Can't type in SwiftUI TextField?!
        FileEditor.justificationButton.tap()
        app.find(label: "It is in the public domain").tap()
        NavBar.backButton(label: "Edit File").tap()
        FileEditor.doneButton.tap().waitToVanish()

        // XCTAssertEqual(firstFile!.api.usage_rights?.legal_copyright, "me")
        XCTAssertEqual(firstFile!.api.usage_rights?.use_justification, .public_domain)
    }

    func testRestrictAccess() throws {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.files.tap()
        FileList.file(index: 0).tap()
        FileDetails.editButton.tap()

        FileEditor.accessButton.tap()
        app.find(label: "Schedule student availability").tap()
        NavBar.backButton(label: "Edit File").tap()
        let picker = app.datePickers.firstElement
        FileEditor.unlockAtButton.tapUntil { picker.exists }
        app.find(label: "Done", type: .button).tap().waitToVanish()
        FileEditor.doneButton.tap().waitToVanish()

        XCTAssertNotNil(firstFile!.api.unlock_at)
        XCTAssertNil(firstFile!.api.lock_at)
    }

    func testPublishFile() {
        firstFile!.api.hidden = true

        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.files.tap()

        let file = FileList.file(index: 0)
        XCTAssertEqual(file.label(), "Restricted, hamburger, 1 KB")
        file.tap()
        FileDetails.editButton.tap()

        FileEditor.accessButton.tap()
        app.find(label: "Publish").tap()
        NavBar.backButton(label: "Edit File").tap()
        FileEditor.doneButton.tap().waitToVanish()
        NavBar.backButton.tap()

        XCTAssertEqual(file.label(), "Published, hamburger, 1 KB")
        XCTAssertFalse(firstFile!.api.hidden)
    }

    func testDeleteFile() throws {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.files.tap()
        FileList.file(index: 0).tap()
        FileDetails.editButton.tap()

        FileEditor.deleteButton.tap()
        app.find(label: "Delete").tap()

        app.find(label: "This folder is empty.").waitToExist()
        XCTAssertNil(firstFile)
    }
}
