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

class HorizontalMenuViewControllerTests: XCTestCase {

    var mock: Mock!

    override func setUp() {
        super.setUp()
        mock = Mock()
    }

    func testTitleForSelectedTab() {
        var title = mock.titleForSelectedTab()
        XCTAssertEqual("A", title)

        mock.collectionView(mock.menu!, didSelectItemAt: IndexPath(item: 1, section: 0))

        title = mock.titleForSelectedTab()
        XCTAssertEqual("B", title)
    }

    class Mock: HorizontalMenuViewController, HorizontalPagedMenuDelegate {
        init() {
            super.init(nibName: nil, bundle: nil)
            delegate = self
            layoutViewControllers()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        var viewControllers: [UIViewController] = [UIViewController(), UIViewController()]
        var menuItemSelectedColor: UIColor? = UIColor.red
        func accessibilityIdentifier(at: IndexPath) -> String { return "" }

        func menuItemTitle(at: IndexPath) -> String {
            switch at.item {
            case 0: return "A"
            case 1: return "B"
            default: return "error"
            }
        }
    }
}
