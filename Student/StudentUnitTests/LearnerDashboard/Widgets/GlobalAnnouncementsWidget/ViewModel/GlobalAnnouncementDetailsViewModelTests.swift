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

import Combine
@testable import Core
@testable import Student
@testable import TestsFoundation
import XCTest

final class GlobalAnnouncementDetailsViewModelTests: StudentTestCase {

    private static let testData = (
        id: "announcement1",
        title: "some title",
        message: "some message",
        date: Date.make(year: 2025, month: 9, day: 15)
    )
    private lazy var testData = Self.testData

    private var testee: GlobalAnnouncementDetailsViewModel!
    private var interactor: GlobalAnnouncementsWidgetInteractorMock!

    override func setUp() {
        super.setUp()
        interactor = .init()
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        super.tearDown()
    }

    // MARK: - Basic properties

    func test_basicProperties() {
        let item = GlobalAnnouncementsWidgetItem.make(
            id: testData.id,
            title: testData.title,
            startDate: testData.date,
            message: testData.message
        )
        testee = makeViewModel(item: item)

        XCTAssertEqual(testee.id, testData.id)
        XCTAssertEqual(testee.title, testData.title)
        XCTAssertEqual(testee.date, testData.date.dateTimeString)
        XCTAssertEqual(testee.message, testData.message)
    }

    // MARK: - didTapDelete

    func test_didTapDelete_shouldCallInteractor() {
        testee = makeViewModel(item: .make(id: testData.id))

        let controller = WeakViewController()
        testee.didTapDelete(from: controller)

        waitUntil(shouldFail: true) {
            interactor.deleteAnnouncementCallCount == 1
        }
        XCTAssertEqual(interactor.deleteAnnouncementInput, testData.id)
    }

    func test_didTapDelete_shouldDismissView() {
        testee = makeViewModel(item: .make(id: testData.id))

        let vc = UIViewController()
        testee.didTapDelete(from: .init(vc))

        waitUntil(shouldFail: true) {
            router.dismissed != nil
        }
        XCTAssertEqual(router.dismissed, vc)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        item: GlobalAnnouncementsWidgetItem
    ) -> GlobalAnnouncementDetailsViewModel {
        GlobalAnnouncementDetailsViewModel(
            item: item,
            interactor: interactor,
            environment: env
        )
    }
}
