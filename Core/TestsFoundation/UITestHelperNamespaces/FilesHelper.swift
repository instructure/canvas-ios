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

import XCTest

public class FilesHelper: BaseHelper {
    public struct Details {
        public static var editButton: XCUIElement { app.find(id: "FileDetails.editButton") }
        public static var imageView: XCUIElement { app.find(id: "FileDetails.imageView") }
        public static var shareButton: XCUIElement { app.find(id: "FileDetails.shareButton") }
        public static var webView: XCUIElement { app.find(id: "FileDetails.webView") }
    }

    public struct Editor {
        public static var nameField: XCUIElement { app.find(id: "FileEditor.nameField") }
        public static var accessButton: XCUIElement { app.find(id: "FileEditor.accessButton") }
        public static var unlockAtButton: XCUIElement { app.find(id: "FileEditor.unlockAtButton") }
        public static var lockAtButton: XCUIElement { app.find(id: "FileEditor.lockAtButton") }
        public static var copyrightField: XCUIElement { app.find(id: "FileEditor.copyrightField") }
        public static var justificationButton: XCUIElement { app.find(id: "FileEditor.justificationButton") }
        public static var licenseButton: XCUIElement { app.find(id: "FileEditor.licenseButton") }
        public static var doneButton: XCUIElement { app.find(id: "FileEditor.doneButton") }
        public static var deleteButton: XCUIElement { app.find(id: "FileEditor.deleteButton") }
    }

    public struct List {
        public static var addButton: XCUIElement { app.find(id: "FileList.addButton") }
        public static var editButton: XCUIElement { app.find(id: "FileList.editButton") }
        public static var addFileButton: XCUIElement { app.find(id: "FileList.addFileButton") }
        public static var addFolderButton: XCUIElement { app.find(id: "FileList.addFolderButton") }

        // Upload file
        public static var uploadFileButton: XCUIElement { app.find(label: "Upload File", type: .button) }
        public static var testPDFButton: XCUIElement { app.find(id: "\(FilesHelper.TestPDF.title), pdf") }
        public static var uploadImageButton: XCUIElement { app.find(label: "Photo Library", type: .button) }
        public static var imageItem: XCUIElement { app.find(labelContaining: "Photo", type: .image) }
        public static var browseButton: XCUIElement { app.find(label: "Browse", type: .button) }
        public static var onMyIpadButton: XCUIElement { app.find(id: "DOC.sidebar.item.On My iPad", type: .cell) }

        // Deleting file
        public static var deleteButton: XCUIElement { app.find(label: "Delete", type: .button) }
        public static var areYouSureLabel: XCUIElement { app.find(labelContaining: "Are you sure", type: .staticText) }

        // Folder creation
        public static var folderNameInput: XCUIElement { app.find(label: "Folder Name", type: .textField) }
        public static var okButton: XCUIElement { app.find(label: "OK", type: .button) }

        // File list item
        public static func file(index: Int) -> XCUIElement {
            return app.find(id: "FileList.\(index)")
        }

        public static func createFolder(name: String, shouldOpen: Bool = true) -> Bool {
            let filesCount = files.count
            addButton.hit()
            addFolderButton.hit()
            folderNameInput.writeText(text: name)
            okButton.hit()
            folderNameInput.waitUntil(.vanish)
            let allFiles = files
            allFiles[0].waitUntil(.visible)
            guard allFiles.count > filesCount else { return false }

            let theFolder = allFiles.filter { $0.label.contains(name) }
            theFolder[0].hit()
            return true
        }

        public static func uploadTestPDF() {
            addButton.hit()
            addFileButton.hit()
            uploadFileButton.hit()
            testPDFButton.hit()
        }
    }

    public struct PDFViewer {
        public static var PDFView: XCUIElement { app.find(id: "PDF View") }

        public static var testText1: XCUIElement { app.find(labelContaining: "Lorem ipsum dolor sit amet", type: .staticText) }
        public static var testText2: XCUIElement { app.find(labelContaining: "Aenean pulvinar euismod ligula at lacinia", type: .staticText) }
        public static var testText3: XCUIElement { app.find(labelContaining: "Fusce efficitur mi ex", type: .staticText) }
    }

    // MARK: Functions
    public static func navigateToFiles() {
        DashboardHelper.profileButton.hit()
        ProfileHelper.filesButton.hit()
    }
}
