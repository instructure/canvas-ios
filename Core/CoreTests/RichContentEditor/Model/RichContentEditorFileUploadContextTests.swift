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

@testable import Core
import XCTest

class RCEFileUploadContextTests: XCTestCase {

    func testFileUploadContextForTeacherApp() {
        let result = FileUploadContext.makeForRCEUploads(app: .teacher,
                                                         context: .course("123"),
                                                         session: nil)
        XCTAssertEqual(result, .context(.course("123")))
    }

    func testFileUploadContextWhenUserIDNotAvailable() {
        let result = FileUploadContext.makeForRCEUploads(app: .student,
                                                         context: .course("123"),
                                                         session: nil)
        XCTAssertEqual(result, .myFiles)
    }

    func testFileUploadContext() {
        let result = FileUploadContext.makeForRCEUploads(app: .student,
                                                         context: .course("321"),
                                                         session: .init(baseURL: URL(string: "/")!,
                                                                        userID: "7053~123",
                                                                        userName: ""))
        XCTAssertEqual(result, .context(.user("7053~123")))
    }
}
