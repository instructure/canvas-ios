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

public class FilesHelper: BaseHelper {
    // MARK: Test data
    public struct TestPDF {
        public static let url = "https://freetestdata.com/wp-content/uploads/2021/09/Free_Test_Data_100KB_PDF.pdf"
        public static let name = "Free_Test_Data_100KB_PDF"

        public static func download() {
            SafariAppHelper.launchAppWithURL(url)
            SafariAppHelper.shareButton.hit()
            SafariAppHelper.Share.titleLabel(title: TestPDF.name).actionUntilElementCondition(
                action: .swipeUp(.onElement), element: SafariAppHelper.Share.saveToFiles, condition: .hittable)
            SafariAppHelper.Share.saveToFiles.hit()
            SafariAppHelper.Share.onMyIphoneButton.hit()
            SafariAppHelper.Share.onMyIphoneLabel.waitUntil(.visible)
            SafariAppHelper.Share.saveButton.hit()
        }
    }

    // MARK: UI Elements
    public static var noFilesLabel: XCUIElement { app.find(labelContaining: "No Files", type: .table) }

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
        public static var uploadFileButton: XCUIElement { app.find(label: "Upload File", type: .button) }
        public static var testPDFButton: XCUIElement { app.find(id: "\(FilesHelper.TestPDF.name), pdf") }
        public static var deleteButton: XCUIElement { app.find(label: "Delete", type: .button) }
        public static var areYouSureLabel: XCUIElement { app.find(labelContaining: "Are you sure", type: .staticText) }

        public static func file(index: Int) -> XCUIElement {
            return app.find(id: "FileList.\(index)")
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
