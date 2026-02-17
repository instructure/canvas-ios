//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

final class OfflineBannerAppearanceModelTests: CoreTestCase {

    private static let testData = (
        contentHeight1: CGFloat(42),
        contentHeight2: CGFloat(100),
        bounds1: CGRect(x: 0, y: 0, width: 320, height: 480),
        bounds2: CGRect(x: 0, y: 0, width: 768, height: 1024)
    )
    private lazy var testData = Self.testData

    private var testee: OfflineBannerAppearanceModel!

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Offline content opacity

    func test_offlineContentOpacityWhen() {
        testee = makeModel()

        // WHEN offline is true
        var result = testee.offlineContentOpacity(isOffline: true)
        // THEN
        XCTAssertEqual(result, 1)

        // WHEN offline is false
        result = testee.offlineContentOpacity(isOffline: false)
        // THEN
        XCTAssertEqual(result, 0)
    }

    // MARK: - Online content opacity

    func test_onlineContentOpacityWhen() {
        testee = makeModel()

        // WHEN offline is true
        var result = testee.onlineContentOpacity(isOffline: true)
        // THEN
        XCTAssertEqual(result, 0)

        // WHEN offline is false
        result = testee.onlineContentOpacity(isOffline: false)
        // THEN
        XCTAssertEqual(result, 1)
    }

    // MARK: - View opacity

    func test_viewOpacityWhen() {
        testee = makeModel()

        // WHEN visible is true
        var result = testee.viewOpacity(isVisible: true)
        // THEN
        XCTAssertEqual(result, 1)

        // WHEN visible is false
        result = testee.viewOpacity(isVisible: false)
        // THEN
        XCTAssertEqual(result, 0)
    }

    // MARK: - View change required

    func test_viewChangeRequiredUpdating_whenNoChanges_shouldReturnNil() {
        testee = makeModel(
            contentHeight: testData.contentHeight1,
            containerBounds: testData.bounds1
        )

        let result = testee.viewChangeRequiredUpdating(
            contentHeight: testData.contentHeight1,
            containerBounds: testData.bounds1
        )

        XCTAssertEqual(result, nil)
    }

    func test_viewChangeRequiredUpdating_whenContentHeightChanges_shouldReturnAdditionalInsets() {
        testee = makeModel(
            contentHeight: testData.contentHeight1,
            containerBounds: testData.bounds1
        )

        let result = testee.viewChangeRequiredUpdating(
            contentHeight: testData.contentHeight2,
            containerBounds: testData.bounds1
        )

        XCTAssertEqual(result, .additionalInsets)
    }

    func test_viewChangeRequiredUpdating_whenContainerBoundsChanges_shouldReturnLayout() {
        testee = makeModel(
            contentHeight: testData.contentHeight1,
            containerBounds: testData.bounds1
        )

        let result = testee.viewChangeRequiredUpdating(
            contentHeight: testData.contentHeight1,
            containerBounds: testData.bounds2
        )

        XCTAssertEqual(result, .layout)
    }

    func test_viewChangeRequiredUpdating_whenBothChange_shouldReturnLayout() {
        testee = makeModel(
            contentHeight: testData.contentHeight1,
            containerBounds: testData.bounds1
        )

        let result = testee.viewChangeRequiredUpdating(
            contentHeight: testData.contentHeight2,
            containerBounds: testData.bounds2
        )

        XCTAssertEqual(result, .layout)
    }

    func test_viewChangeRequiredUpdating_whenContainerBoundsIsNil_shouldOnlyCheckContentHeight() {
        testee = makeModel(
            contentHeight: testData.contentHeight1,
            containerBounds: testData.bounds1
        )

        // WHEN content height changes and bounds is nil
        var result = testee.viewChangeRequiredUpdating(
            contentHeight: testData.contentHeight2,
            containerBounds: nil
        )
        // THEN
        XCTAssertEqual(result, .additionalInsets)

        // WHEN content height is same and bounds is nil
        result = testee.viewChangeRequiredUpdating(
            contentHeight: testData.contentHeight2,
            containerBounds: nil
        )
        // THEN
        XCTAssertEqual(result, nil)
    }

    // MARK: - Container additional insets

    func test_containerAdditionalInsets() {
        testee = makeModel(contentHeight: testData.contentHeight1)

        // WHEN visible is true
        var result = testee.containerAdditionalInsets(isVisible: true)
        // THEN
        XCTAssertEqual(result.top, 0)
        XCTAssertEqual(result.left, 0)
        XCTAssertEqual(result.bottom, testData.contentHeight1)
        XCTAssertEqual(result.right, 0)

        // WHEN visible is false
        result = testee.containerAdditionalInsets(isVisible: false)
        // THEN
        XCTAssertEqual(result.top, 0)
        XCTAssertEqual(result.left, 0)
        XCTAssertEqual(result.bottom, 0)
        XCTAssertEqual(result.right, 0)
    }

    // MARK: - Private helpers

    private func makeModel(
        contentHeight: CGFloat = 42,
        containerBounds: CGRect = CGRect(x: 0, y: 0, width: 320, height: 480)
    ) -> OfflineBannerAppearanceModel {
        OfflineBannerAppearanceModel(
            contentHeight: contentHeight,
            containerBounds: containerBounds
        )
    }
}
