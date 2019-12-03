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

class ProfileSettingsViewControllerTests: CoreTestCase {
    var vc: ProfileSettingsViewController!
    override func setUp() {
        super.setUp()
        vc = ProfileSettingsViewController.create()
        vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 800)
        vc.view.layoutIfNeeded()
        XCTAssertNotNil(vc.view)
    }

    func testCanNavigateToExperimentalFeatures() {
        vc.reloadData()
        let cell = vc.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RightDetailTableViewCell
        XCTAssertEqual(cell?.textLabel?.text, "Experimental Features")

        vc.tableView.delegate?.tableView?(vc.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        wait(for: [router.showExpectation], timeout: 1)
        let (routedVC, _, _) = router.viewControllerCalls.last!
        XCTAssert(routedVC is ExperimentalFeaturesViewController)
    }
}
