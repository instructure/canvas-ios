//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import Core
@testable import Teacher
import TestsFoundation

class DatePickerViewControllerTests: TeacherTestCase, DatePickerDelegate {
    override func setUp() {
        let now = DateComponents(calendar: .current, timeZone: .current, year: 2019, month: 10, day: 29).date!
        Clock.mockNow(now)
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    var selected: Date?
    func didSelectDate(_ date: Date) {
        selected = date
    }

    func testLayout() {
        let controller = DatePickerViewController(selected: Clock.now, delegate: self)
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.view.backgroundColor, .backgroundLightest)
        XCTAssertTrue(controller.hasScrolledToInitialDate)
        XCTAssertEqual(controller.layout.itemSize, CGSize(width: 49, height: 49))

        controller.view.frame = CGRect(x: 0, y: 0, width: 802, height: 375)
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.layout.itemSize, CGSize(width: 110, height: 110))
    }

    func testChangeDate() {
        let controller = DatePickerViewController(selected: Clock.now, delegate: self)
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        controller.view.layoutIfNeeded()
        controller.collectionView(controller.collectionView, didSelectItemAt: IndexPath(item: 30, section: 24))
        let doneItem = controller.navigationItem.rightBarButtonItem
        _ = doneItem?.target?.perform(doneItem?.action, with: nil)
        XCTAssertNil(selected)
        controller.collectionView(controller.collectionView, didDeselectItemAt: IndexPath(item: 30, section: 24))
        controller.collectionView(controller.collectionView, didSelectItemAt: IndexPath(item: 32, section: 24))
        _ = doneItem?.target?.perform(doneItem?.action, with: nil)
        XCTAssertEqual(selected, controller.dateForCell(at: IndexPath(item: 32, section: 24)))
    }
}
