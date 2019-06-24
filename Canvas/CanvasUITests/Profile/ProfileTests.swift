//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import TestsFoundation

class ProfileTests: CanvasUITests {
    func testProfileDisplaysUsername() {
        Profile.open()
        XCTAssertEqual(Profile.userNameLabel.label, "Student One")
    }

    func testProfileChangesUser() {
        Profile.open()
        Profile.changeUserButton.tap()
        let entry = user!.keychainEntry!
        LoginStartKeychainEntry.cell(host: entry.baseURL.host!, userID: entry.userID).waitToExist()
    }

    func testProfileLogsOut() {
        Profile.open()
        Profile.logOutButton.tap()
        LoginStart.findSchoolButton.waitToExist()
        let entry = user!.keychainEntry!
        XCTAssertFalse(LoginStartKeychainEntry.cell(host: entry.baseURL.host!, userID: entry.userID).exists)
    }
}
