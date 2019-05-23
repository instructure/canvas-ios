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
@testable import Core

class UserSettingsTests: CoreTestCase {
    func testSaveUserSettings() {
        let apiSettings = APIUserSettings.make(
            manual_mark_as_read: true,
            collapse_global_nav: true,
            hide_dashcard_color_overlays: true
        )

        XCTAssertNoThrow( try UserSettings.save(apiSettings, in: databaseClient) )

        let settings: UserSettings = databaseClient.fetch().first!
        XCTAssertTrue(settings.manualMarkAsRead)
        XCTAssertTrue(settings.collapseGlobalNav)
        XCTAssertTrue(settings.hideDashcardColorOverlays)
    }
}
