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

import XCTest
@testable import Core

class PairWithObserverViewControllerTests: CoreTestCase {

    var vc: PairWithObserverViewController!

    override func setUp() {
        super.setUp()
        vc = PairWithObserverViewController.create()
    }

    func load() {
        vc.loadView()
        vc.viewDidLoad()
        vc.viewDidAppear(false)
    }

    func testRender() {
        let code = APIPairingCode.make(code: "abc")
        api.mock(PostObserverPairingCodes(), value: code)
        api.mock(GetAccountTermsOfServiceRequest(), value: .make())
        load()
        XCTAssertEqual(vc.spinner.isHidden, true)
        XCTAssertEqual(vc.qrCodePairingCodeLabel.attributedText?.string, "Pairing Code: abc")
        let share = vc.navigationItem.rightBarButtonItem!
        _ = share.target!.perform(share.action, with: [share])
        XCTAssert(router.presented is UIActivityViewController)
    }
}
