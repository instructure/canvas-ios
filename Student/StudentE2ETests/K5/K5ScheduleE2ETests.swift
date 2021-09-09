//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
import TestsFoundation
@testable import Core

class K5ScheduleE2ETests: K5UITestCase {
    func testK5Schedule() {
        setUpK5()

        K5CourseCard.courseCard(id: "21025").waitToExist()
        K5NavigationBar.schedule.waitToExist()
        K5NavigationBar.schedule.tap()
        // The today button shouldn't be visible when starting out, will change the behaviour once it's fixed
        app.find(label: "Today", type: XCUIElement.ElementType.button).waitToExist()
        app.find(label: "Today", type: XCUIElement.ElementType.staticText).waitToExist()
        app.swipeLeft()
        app.find(label: "Today", type: XCUIElement.ElementType.staticText).waitToVanish()
        app.find(label: "Today", type: XCUIElement.ElementType.button).waitToVanish()
        app.swipeRight()
        app.find(label: "Today", type: XCUIElement.ElementType.staticText).waitToExist()
    }
}
