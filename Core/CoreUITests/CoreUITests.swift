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

import Core
import XCTest
import TestsFoundation

class CoreUITests: UITestCase {
    var user: UITestUser? {
        if Bundle.main.isStudentUITestsRunner {
            return .readStudent1
        } else if Bundle.main.isTeacherUITestsRunner {
            return .readTeacher1
        } else {
            return nil
        }
    }

    // The class in this variable will not have tests run for it, only for subclasses
    var abstractTestClass: CoreUITests.Type { return CoreUITests.self }

    private static var firstRun = true

    override func perform(_ run: XCTestRun) {
        if type(of: self) != abstractTestClass {
            super.perform(run)
        }
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        if CoreUITests.firstRun || app.state != .runningForeground {
            CoreUITests.firstRun = false
            launch()
            if currentSession() != nil {
                Dashboard.coursesLabel.waitToExist()
            }
        }
        reset()
        if let user = user {
            logInUser(user)
            Dashboard.coursesLabel.waitToExist()
        }
    }
}
