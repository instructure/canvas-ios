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

class UserSettingsTests: CoreTestCase {
    func testSaveUserSettings() {
        let apiSettings = APIUserSettings.make(
            manual_mark_as_read: true,
            collapse_global_nav: true,
            hide_dashcard_color_overlays: true,
            comment_library_suggestions_enabled: true
        )

        XCTAssertNoThrow( UserSettings.save(apiSettings, in: databaseClient) )

        let settings: UserSettings = databaseClient.fetch().first!
        XCTAssertTrue(settings.manualMarkAsRead)
        XCTAssertTrue(settings.collapseGlobalNav)
        XCTAssertTrue(settings.hideDashcardColorOverlays)
        XCTAssertTrue(settings.commentLibrarySuggestionsEnabled)
    }
}
