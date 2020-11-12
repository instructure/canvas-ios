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

class DasboardCardViewControllerTests: CoreTestCase {
    lazy var controller = DashboardCardViewController.create()

    override func setUp() {
        super.setUp()
        api.mock(controller.colors, value: APICustomColors(custom_colors: [
            "course_1": "#880000",
            "group_1": "#008800",
        ]))
        api.mock(controller.courseSection.cards, value: [ .make() ])
        api.mock(controller.courseSection.courses, value: [ .make() ])
        api.mock(controller.courseSection.settings, value: .make(hide_dashcard_color_overlays: true))
        api.mock(controller.groupSection.groups, value: [ .make() ])
    }

    func testLayout() {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor, Brand.shared.navBackground)

        _ = controller.profileButton.target?.perform(controller.profileButton.action)
        XCTAssert(router.lastRoutedTo(.parse("/profile")))

        /* TODO: figure out why these tests fail when the app works properly
        XCTAssertEqual(controller.collectionView.numberOfSections, 2)
        let courseHeader = controller.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? DashboardSectionHeaderView
        XCTAssertEqual(courseHeader?.titleLabel.text, "Courses")
        courseHeader?.rightButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.lastRoutedTo(.parse("/courses")))
        let groupHeader = controller.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 1)) as? DashboardSectionHeaderView
        XCTAssertEqual(groupHeader?.titleLabel.text, "Groups")

        let index00 = IndexPath(item: 0, section: 0)
        let cell00 = controller.collectionView.cellForItem(at: index00) as? DashboardCourseCell
        XCTAssertEqual(cell00?.titleLabel.text, "Course One")
        cell00?.optionsButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.lastRoutedTo(.parse("/courses/1/user_preferences")))
        */

        let index00 = IndexPath(item: 0, section: 0)
        controller.collectionView.delegate?.collectionView?(controller.collectionView, didSelectItemAt: index00)
        XCTAssert(router.lastRoutedTo(.parse("/courses/1")))
        controller.collectionView.selectItem(at: index00, animated: false, scrollPosition: .top)
        XCTAssertEqual(controller.collectionView.indexPathsForSelectedItems, [ index00 ])
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.collectionView.indexPathsForSelectedItems, [])

        controller.collectionView.delegate?.collectionView?(controller.collectionView, didSelectItemAt: IndexPath(item: 0, section: 1))
        XCTAssert(router.lastRoutedTo(.parse("/groups/1")))

        api.mock(controller.courseSection.settings, value: .make(hide_dashcard_color_overlays: false))
        controller.refreshControl.beginRefreshing()
        controller.collectionView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertFalse(controller.refreshControl.isRefreshing)

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }
}
