//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class ExperimentalFeatureTests: XCTestCase {
    let allEnabled = ExperimentalFeature.allEnabled
    override func tearDown() {
        ExperimentalFeature.allEnabled = allEnabled
    }

    func testIsEnabled() {
        ExperimentalFeature.allEnabled = false
        XCTAssertFalse(ExperimentalFeature(state: .disabled).isEnabled)
        XCTAssertTrue(ExperimentalFeature(state: .enabled).isEnabled)

        AppEnvironment.shared.currentSession = LoginSession.make(baseURL: URL(string: "https://canvas.beta.instructure.com")!)
        XCTAssertTrue(ExperimentalFeature(state: .enabledInBeta).isEnabled)
        AppEnvironment.shared.currentSession = LoginSession.make(baseURL: URL(string: "https://canvas.instructure.com")!)
        XCTAssertFalse(ExperimentalFeature(state: .enabledInBeta).isEnabled)
        AppEnvironment.shared.currentSession = nil
        XCTAssertFalse(ExperimentalFeature(state: .enabledInBeta).isEnabled)

        AppEnvironment.shared.currentSession = LoginSession.make(baseURL: URL(string: "https://a.edu")!)
        XCTAssertTrue(ExperimentalFeature(state: .enabledForHosts([ "a.edu" ])).isEnabled)
        XCTAssertFalse(ExperimentalFeature(state: .enabledForHosts([ "a.ed" ])).isEnabled)
        XCTAssertFalse(ExperimentalFeature(state: .enabledForHosts([ "b.edu" ])).isEnabled)
        AppEnvironment.shared.currentSession = nil
        XCTAssertFalse(ExperimentalFeature(state: .enabledForHosts([ "a.edu" ])).isEnabled)

        ExperimentalFeature.allEnabled = true
        XCTAssertTrue(ExperimentalFeature(state: .disabled).isEnabled)
    }
}
