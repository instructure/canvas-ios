//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

open class K5UITestCase: CoreUITestCase {
    override open var experimentalFeatures: [ExperimentalFeature] { return [ExperimentalFeature.K5Dashboard] }

    open func resetAppStateForK5() {
        app.terminate()
        launch()
        sleep(5)
    }

    override open var user: UITestUser? {
        .readStudentK5
    }

    open func setUpK5() {
        K5Helper.homeroom.waitUntil(.visible)
        resetAppStateForK5()
        app.pullToRefresh()
        K5Helper.homeroom.waitUntil(.visible)
    }
}
