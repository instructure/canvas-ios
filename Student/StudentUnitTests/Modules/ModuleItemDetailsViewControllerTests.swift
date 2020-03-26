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

import Foundation
@testable import Student
@testable import Core
import XCTest

class ModuleItemDetailsViewControllerTests: StudentTestCase {
    class CurrentViewController: UIViewController {}
    class NextViewController: UIViewController {}
    class PreviousViewController: UIViewController {}

    var courseID = "1"
    var assetType: ModuleItemSequenceViewController.AssetType = .assignment
    var assetID: String = "2"
    var url = URLComponents(string: "/courses/1/assignments/2")!
    lazy var controller = ModuleItemSequenceViewController.create(
        courseID: courseID,
        assetType: assetType,
        assetID: assetID,
        url: url
    )

    override func setUp() {
        super.setUp()
        env.mockStore = false
    }

    func testLayout() {
        let prev = APIModuleItem.make(id: "1", html_url: URL(string: "/prev"))
        let next = APIModuleItem.make(id: "2", html_url: URL(string: "/next"))

        router.mock(.parse(url.url!.appendingOrigin("module_item_details"))) {
            CurrentViewController()
        }
        router.mock(.parse(next.html_url!.appendingOrigin("module_item_details"))) {
            NextViewController()
        }
        router.mock(.parse(prev.html_url!.appendingOrigin("module_item_details"))) {
            PreviousViewController()
        }

        api.mock(
            GetModuleItemSequenceRequest(courseID: courseID, assetType: assetType, assetID: assetID),
            value: .make(items: [.make(prev: prev, next: next)])
        )
        controller.view.layoutIfNeeded()
        let pages = controller.pages
        XCTAssert(pages.currentPage is CurrentViewController)
        XCTAssert(pages.dataSource?.pagesViewController(pages, pageBefore: pages.currentPage) is PreviousViewController)
        XCTAssert(pages.dataSource?.pagesViewController(pages, pageAfter: pages.currentPage) is NextViewController)
    }
}
