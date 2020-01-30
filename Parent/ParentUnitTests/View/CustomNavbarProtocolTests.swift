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
@testable import Parent
import Core

class CustomNavbarProtocolTests: XCTestCase {

    var mock = CustomNavbarMock()

    override func setUp() {
        super.setUp()
        mock = CustomNavbarMock()
    }

    func testMenu() {
        mock.viewDidLoad()
        XCTAssertEqual( mock.navbarMenuHeightConstraint.constant, 0  )
        mock.navbarNameButton.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(mock.didClickNavbarButton)
        XCTAssertEqual( mock.navbarMenuHeightConstraint.constant, 105  )
    }
}

class CustomNavbarMock: UIViewController, CustomNavbarProtocol, CustomNavbarActionDelegate {

    var navbarBottomViewContainer: UIView!
    var navbarMenu: UIView!
    var navbarMenuStackView: HorizontalScrollingStackview!
    var navbarNameButton: Parent.DynamicButton!
    var navbarAvatar: Parent.AvatarView?
    var navbarMenuHeightConstraint: NSLayoutConstraint!
    weak var customNavbarDelegate: CustomNavbarActionDelegate?
    var customNavBarColor: UIColor? { .red }
    var didClickNavbarButton: Bool = false
    var mainView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavbar()
        customNavbarDelegate = self
        mainView = UIView()

        view.addSubview(mainView)
        mainView.pinToAllSidesOfSuperview()
        hookupRootViewToMenu(mainView)
    }

    func didClickNavbarNameButton(sender: UIButton) {
        showCustomNavbarMenu(navbarMenuIsHidden)
        didClickNavbarButton = true
    }
}
