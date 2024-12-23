//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Foundation
import SwiftUI
import XCTest

class InstIconTests: XCTestCase {
    func testImages() {
        XCTAssertEqual(Image.addAudioLine, Image("addAudioLine", bundle: .core))
        XCTAssertEqual(Image.addCameraLine, Image("addCameraLine", bundle: .core))
        XCTAssertEqual(Image.addDocumentLine, Image("addDocumentLine", bundle: .core))
        XCTAssertEqual(Image.addImageLine, Image("addImageLine", bundle: .core))
        XCTAssertEqual(Image.addVideoCameraLine, Image("addVideoCameraLine", bundle: .core))
        XCTAssertEqual(Image.alertsTab, Image("alertsTab", bundle: .core))
        XCTAssertEqual(Image.alertsTabActive, Image("alertsTabActive", bundle: .core))
        XCTAssertEqual(Image.archiveLine, Image("archiveLine", bundle: .core))
        XCTAssertEqual(Image.attendance, Image("attendance", bundle: .core))
        XCTAssertEqual(Image.calendarEmptyLine, Image("calendarEmptyLine", bundle: .core))
        XCTAssertEqual(Image.calendarEmptySolid, Image("calendarEmptySolid", bundle: .core))
        XCTAssertEqual(Image.calendarTab, Image("calendarTab", bundle: .core))
        XCTAssertEqual(Image.calendarTabActive, Image("calendarTabActive", bundle: .core))
        XCTAssertEqual(Image.calendarTodayLine, Image("calendarTodayLine", bundle: .core))
        XCTAssertEqual(Image.cameraLine, Image("cameraLine", bundle: .core))
        XCTAssertEqual(Image.cameraSolid, Image("cameraSolid", bundle: .core))
        XCTAssertEqual(Image.chatBubble, Image("chatBubble", bundle: .core))
        XCTAssertEqual(Image.checkbox, Image("checkbox", bundle: .core))
        XCTAssertEqual(Image.checkboxSelected, Image("checkboxSelected", bundle: .core))
        XCTAssertEqual(Image.chevronDown, Image("chevronDown", bundle: .core))
        XCTAssertEqual(Image.collaborations, Image("collaborations", bundle: .core))
        XCTAssertEqual(Image.conferences, Image("conferences", bundle: .core))
        XCTAssertEqual(Image.coursesTab, Image("coursesTab", bundle: .core))
        XCTAssertEqual(Image.coursesTabActive, Image("coursesTabActive", bundle: .core))
        XCTAssertEqual(Image.dashboardLayoutGrid, Image("dashboardLayoutGrid", bundle: .core))
        XCTAssertEqual(Image.dashboardLayoutList, Image("dashboardLayoutList", bundle: .core))
        XCTAssertEqual(Image.dashboardTab, Image("dashboardTab", bundle: .core))
        XCTAssertEqual(Image.dashboardTabActive, Image("dashboardTabActive", bundle: .core))
        XCTAssertEqual(Image.dropdown, Image("dropdown", bundle: .core))
        XCTAssertEqual(Image.filterCheckbox, Image("filterCheckbox", bundle: .core))
        XCTAssertEqual(Image.grab, Image("grab", bundle: .core))
        XCTAssertEqual(Image.homeroomTab, Image("homeroomTab", bundle: .core))
        XCTAssertEqual(Image.homeroomTabActive, Image("homeroomTabActive", bundle: .core))
        XCTAssertEqual(Image.inboxTab, Image("inboxTab", bundle: .core))
        XCTAssertEqual(Image.inboxTabActive, Image("inboxTabActive", bundle: .core))
        XCTAssertEqual(Image.k5dueToday, Image("k5dueToday", bundle: .core))
        XCTAssertEqual(Image.k5grades, Image("k5grades", bundle: .core))
        XCTAssertEqual(Image.k5homeroom, Image("k5homeroom", bundle: .core))
        XCTAssertEqual(Image.k5importantDates, Image("k5importantDates", bundle: .core))
        XCTAssertEqual(Image.k5resources, Image("k5resources", bundle: .core))
        XCTAssertEqual(Image.k5schedule, Image("k5schedule", bundle: .core))
        XCTAssertEqual(Image.logout, Image("logout", bundle: .core))
        XCTAssertEqual(Image.markReadLine, Image("markReadLine", bundle: .core))
        XCTAssertEqual(Image.masteryLTI, Image("masteryLTI", bundle: .core))
        XCTAssertEqual(Image.offlineLine, Image("offlineLine", bundle: .core))
        XCTAssertEqual(Image.partialSolid, Image("partialSolid", bundle: .core))
        XCTAssertEqual(Image.radioButtonSelected, Image("radioButtonSelected", bundle: .core))
        XCTAssertEqual(Image.radioButtonUnselected, Image("radioButtonUnselected", bundle: .core))
        XCTAssertEqual(Image.qrCode, Image("qrCode", bundle: .core))
        XCTAssertEqual(Image.share, Image("share", bundle: .core))
        XCTAssertEqual(Image.todoTab, Image("todoTab", bundle: .core))
        XCTAssertEqual(Image.todoTabActive, Image("todoTabActive", bundle: .core))
        XCTAssertEqual(Image.unionLine, Image("unionLine", bundle: .core))
    }
}
