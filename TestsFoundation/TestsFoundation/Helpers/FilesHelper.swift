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

        public static func file(index: Int) -> XCUIElement {
            return app.find(id: "FileList.\(index)")
        }
    }
}
