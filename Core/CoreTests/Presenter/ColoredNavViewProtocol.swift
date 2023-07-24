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

class ColoredNavViewProtocolTests: XCTestCase, ColoredNavViewProtocol {
    var color: UIColor?
    var navigationController: UINavigationController? = UINavigationController(rootViewController: UIViewController())
    var navigationItem: UINavigationItem = UINavigationItem(title: "error")
    var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()
    let subtitle = "subtitle"

    override func setUp() {
        navigationController = UINavigationController(rootViewController: UIViewController())
        navigationItem = UINavigationItem(title: "error")
        titleSubtitleView = TitleSubtitleView.create()
    }

    func testSetupTitleViewInNavbar() {
        setupTitleViewInNavbar(title: self.name)
        XCTAssertEqual(titleSubtitleView.title, self.name)
        XCTAssertEqual(navigationItem.titleView, titleSubtitleView)
    }

    func testUpdateNavBar() {
        let expectedColor: UIColor = .red.darkenToEnsureContrast(against: .white)
        updateNavBar(subtitle: subtitle, color: expectedColor)

        XCTAssertEqual(color, expectedColor)
        XCTAssertEqual(titleSubtitleView.subtitle, subtitle)
        XCTAssertEqual(navigationController?.navigationBar.barTintColor?.hexString, expectedColor.hexString)
        XCTAssertEqual(navigationController?.navigationBar.tintColor.hexString, UIColor.white.hexString)
        XCTAssertEqual(navigationController?.navigationBar.barStyle, .black)
    }
}
