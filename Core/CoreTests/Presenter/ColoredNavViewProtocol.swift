//
// Copyright (C) 2018-present Instructure, Inc.
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
        let expectedColor: UIColor = .red
        updateNavBar(subtitle: subtitle, color: expectedColor)

        XCTAssertEqual(color, expectedColor)
        XCTAssertEqual(titleSubtitleView.subtitle, subtitle)
        XCTAssertEqual(navigationController?.navigationBar.barTintColor, expectedColor)
        XCTAssertEqual(navigationController?.navigationBar.tintColor, .named(.white))
        XCTAssertEqual(navigationController?.navigationBar.barStyle, .black)
    }
}
