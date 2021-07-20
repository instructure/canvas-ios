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
@testable import Core

open class K5UITestCase: CoreUITestCase {
    let env = AppEnvironment()
    override open var experimentalFeatures: [ExperimentalFeature]{ return [ExperimentalFeature.K5Dashboard]}
    
    open override func setUp() {
        super.setUp()
    }
    
    open override var homeScreen: Element {
        return TabBar.dashboardTab
    }
    
    open override var user: UITestUser? {
        return .readStudentK5
    }
    
    open override func tearDown() {
        env.userDefaults?.isElementaryViewEnabled = false
        super.tearDown()
    }
}
