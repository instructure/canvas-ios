//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import TestsFoundation
import XCTest

class HelpTests: E2ETestCase {
    func testHelpPage() {
        // Seed
        let student = seeder.createStudentEnrolled()

        // Log in, navigate to entry point
        logInDSUser(student)
        DashboardHelper.waitUntilDashboardIsVisible()
        HelpHelper.navigateToHelpPage()

        // Verify minimum number of rows
        let helpItems = HelpHelper.getAllHelpItems()
        XCTAssertEqual(helpItems.count >= 4, true, "Should have at least 4 Help items")

        // Verify each row
        for (index, item) in helpItems.enumerated() {
            let label = item.label

            XCTAssertEqual(label.isEmpty, false, "Help item at index \(index) should have non-empty title")

            if label.contains("Ask Your Instructor") {
                item.waitUntil(.visible).hit()

                let sendButton = InboxHelper.Composer.sendButton.waitUntil(.visible)
                let cancelButton = InboxHelper.Composer.cancelButton.waitUntil(.visible)
                XCTAssertVisible(sendButton)
                XCTAssertVisible(cancelButton)

                cancelButton.hit()
                InboxHelper.handleCancelAlert()
                HelpHelper.navigateToHelpPage()
            } else if label.contains("Report a Problem") {
                item.waitUntil(.visible).hit()

                let dismissButton = InboxHelper.Composer.dismissButton.waitUntil(.visible)
                let reportAProblemLabel = app.find(label: "Report a Problem").waitUntil(.visible)
                XCTAssertVisible(dismissButton)
                XCTAssertVisible(reportAProblemLabel)

                dismissButton.hit()
                HelpHelper.navigateToHelpPage()
            } else {
                item.hit()
                let browserURL = SafariAppHelper.browserURL
                XCTAssertHasPrefix(browserURL, "https://", " at index \(index)")

                HelpHelper.returnToHelpPage()
            }
        }
    }
}
