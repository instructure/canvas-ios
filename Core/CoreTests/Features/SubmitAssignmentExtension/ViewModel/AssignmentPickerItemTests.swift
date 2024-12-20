//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core
import XCTest

class AssignmentPickerItemTests: XCTestCase {

    func testSetupFromAPIEntity() {
        let apiAssignment = APIAssignmentPickerListItem(id: "1", name: "n1", allowedExtensions: ["pdf", "jpg"], gradeAsGroup: false)
        let testee = AssignmentPickerItem(apiItem: apiAssignment, sharedFileExtensions: Set<String>())
        XCTAssertEqual(testee.id, "1")
        XCTAssertEqual(testee.name, "n1")
        XCTAssertEqual(testee.gradeAsGroup, false)
    }

    func testSetupFromGroupAPIEntity() {
        let apiAssignment = APIAssignmentPickerListItem(id: "1", name: "n1", allowedExtensions: ["pdf", "jpg"], gradeAsGroup: true)
        let testee = AssignmentPickerItem(apiItem: apiAssignment, sharedFileExtensions: Set<String>())
        XCTAssertEqual(testee.id, "1")
        XCTAssertEqual(testee.name, "n1")
        XCTAssertEqual(testee.gradeAsGroup, true)
    }

    func testNoReasonWhenAllFilesAllowed() {
        let apiAssignment = APIAssignmentPickerListItem(id: "1", name: "n1", allowedExtensions: [], gradeAsGroup: false)
        let testee = AssignmentPickerItem(apiItem: apiAssignment, sharedFileExtensions: Set<String>(["jpg"]))
        XCTAssertNil(testee.notAvailableReason)
    }

    func testUnknownFileExtensionReason() {
        let apiAssignment = APIAssignmentPickerListItem(id: "1", name: "n1", allowedExtensions: ["pdf", "jpg"], gradeAsGroup: false)
        let testee = AssignmentPickerItem(apiItem: apiAssignment, sharedFileExtensions: Set<String>())
        XCTAssertNil(testee.notAvailableReason)
    }

    func testCompatibleFileExtensionReason() {
        let apiAssignment = APIAssignmentPickerListItem(id: "1", name: "n1", allowedExtensions: ["pdf", "jpg"], gradeAsGroup: false)
        let testee = AssignmentPickerItem(apiItem: apiAssignment, sharedFileExtensions: Set<String>(["jpg"]))
        XCTAssertNil(testee.notAvailableReason)
    }

    func testIncompatibleFileExtensionReason() {
        let apiAssignment = APIAssignmentPickerListItem(id: "1", name: "n1", allowedExtensions: ["pdf"], gradeAsGroup: false)
        let testee = AssignmentPickerItem(apiItem: apiAssignment, sharedFileExtensions: Set<String>(["xls"]))
        XCTAssertEqual(testee.notAvailableReason, "The xls file type in your submission is incompatible with the selected assignment.\nPlease use pdf file extension.")
    }

    func testIncompatibleFilesExtensionReason() {
        let apiAssignment = APIAssignmentPickerListItem(id: "1", name: "n1", allowedExtensions: ["pdf", "jpg"], gradeAsGroup: false)
        let testee = AssignmentPickerItem(apiItem: apiAssignment, sharedFileExtensions: Set<String>(["xls", "docx", "pdf"]))
        XCTAssertEqual(testee.notAvailableReason, "The docx, xls file types in your submission are incompatible with the selected assignment.\nPlease use jpg, pdf file extensions.")
    }
}
