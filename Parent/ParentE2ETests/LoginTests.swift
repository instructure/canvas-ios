//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class LoginCreateAccountE2ETests: CoreUITestCase {
    override var user: UITestUser? { nil }

    override func setUp() {
        super.setUp()
        launch { app in
            app.launchEnvironment["QR_CODE"] = "canvas-parent://iosauto.beta.instructure.com/pair?code=abc"
        }
    }

    func testCreateAccount() {
        LoginHelper.Start.qrCodeButton.hit()
        LoginHelper.Start.dontHaveAccountAction.hit()
        LoginHelper.PairWithStudentQR.headerLabel.waitUntil(.visible)
        LoginHelper.PairWithStudentQR.nextButton.hit()
        LoginHelper.Login.webView.waitUntil(.visible)
        // Login screen automatically shows parent signup page
        LoginHelper.Login.studentPairingCodeLabel.waitUntil(.visible)
        LoginHelper.Login.parentCreateAccountButton.hit()
    }
}
