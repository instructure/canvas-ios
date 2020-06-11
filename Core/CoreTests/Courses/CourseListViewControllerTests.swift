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
import XCTest
@testable import Core

class CourseListViewControllerTests: CoreTestCase {
    lazy var controller = CourseListViewController.create()

    override func setUp() {
        super.setUp()
        api.mock(controller.colors, value: APICustomColors(custom_colors: [ "course_1": "#880000" ]))
        api.mock(controller.courses, value: [
            .make(),
            .make(id: "2"), // duplicate name
            .make(id: "3", name: "Course Two"),
            .make(id: "4", name: "Concluded 1", workflow_state: .completed),
            .make(id: "5", name: "Concluded 2", end_at: Clock.now.addDays(-10)),
            .make(id: "6", name: "Concluded 10", term: .make(end_at: Clock.now.addDays(-2))),
        ])
        api.mock(controller.settings, value: .make(hide_dashcard_color_overlays: true))
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor, Brand.shared.navBackground)

        XCTAssertEqual(controller.collectionView.numberOfSections, 2)
        XCTAssertFalse(controller.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) is CourseListSectionHeaderView)
        let prevHeader = controller.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 1)) as? CourseListSectionHeaderView
        XCTAssertEqual(prevHeader?.titleLabel.text, "Past Enrollments")

        let index00 = IndexPath(item: 0, section: 0)
        let cell00 = controller.collectionView.cellForItem(at: index00) as? CourseCardCell
        XCTAssertLessThan(cell00!.imageView.alpha, 1)
        XCTAssertEqual(cell00?.titleLabel.text, "Course One")
        cell00?.optionsButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.lastRoutedTo(.parse("/courses/1/user_preferences")))

        let cell10 = controller.collectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? CourseCardCell
        XCTAssertEqual(cell10?.titleLabel.text, "Course One")
        let cell20 = controller.collectionView.cellForItem(at: IndexPath(item: 2, section: 0)) as? CourseCardCell
        XCTAssertEqual(cell20?.titleLabel.text, "Course Two")
        let cell01 = controller.collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? CourseCardCell
        XCTAssertEqual(cell01?.titleLabel.text, "Concluded 1")
        let cell11 = controller.collectionView.cellForItem(at: IndexPath(item: 1, section: 1)) as? CourseCardCell
        XCTAssertEqual(cell11?.titleLabel.text, "Concluded 2")
        let cell21 = controller.collectionView.cellForItem(at: IndexPath(item: 2, section: 1)) as? CourseCardCell
        XCTAssertEqual(cell21?.titleLabel.text, "Concluded 10")

        controller.collectionView.delegate?.collectionView?(controller.collectionView, didSelectItemAt: index00)
        XCTAssert(router.lastRoutedTo(.parse("/courses/1")))
        controller.collectionView.selectItem(at: index00, animated: false, scrollPosition: .top)
        XCTAssertEqual(controller.collectionView.indexPathsForSelectedItems, [ index00 ])
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.collectionView.indexPathsForSelectedItems, [])

        api.mock(controller.settings, value: .make(hide_dashcard_color_overlays: false))
        controller.refreshControl.beginRefreshing()
        controller.collectionView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertFalse(controller.refreshControl.isRefreshing)

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }
}
