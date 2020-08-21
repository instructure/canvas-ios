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

import Core
import TestsFoundation

class LoginCreateAccountE2ETests: CoreUITestCase {
    override var experimentalFeatures: [ExperimentalFeature] { [.qrLoginParent, .parentQRCodePairing] }
    override var qrCode: String? { "canvas-parent://iosauto.beta.instructure.com/pair?code=abc" }
    override var user: UITestUser? { nil }

    func testCreateAccount() {
        LoginStart.qrCodeButton.tap()
        LoginStart.dontHaveAccountAction.tap()
        PairWithStudentQRCodeTutorial.headerLabel.waitToExist()
        PairWithStudentQRCodeTutorial.nextButton.tap()
        LoginWeb.webView.waitToExist()
        LoginWeb.studentPairingCodeLabel.waitToExist()
        LoginWeb.parentCreateAccountButton.waitToExist()
    }
}
