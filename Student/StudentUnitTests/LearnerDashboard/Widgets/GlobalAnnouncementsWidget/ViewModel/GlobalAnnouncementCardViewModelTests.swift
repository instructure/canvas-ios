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

@testable import Core
@testable import Student
@testable import TestsFoundation
import XCTest

final class GlobalAnnouncementCardViewModelTests: StudentTestCase {

    private static let testData = (
        id: "announcement1",
        title: "some title",
        date: Date.make(year: 2025, month: 9, day: 15)
    )
    private lazy var testData = Self.testData

    private var testee: GlobalAnnouncementCardViewModel!

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Basic properties

    func test_basicProperties() {
        let model = GlobalAnnouncementsWidgetItem.make(
            id: testData.id,
            title: testData.title,
            icon: .warning,
            startDate: testData.date
        )
        testee = makeViewModel(model: model)

        XCTAssertEqual(testee.id, model)
        XCTAssertEqual(testee.title, testData.title)
        XCTAssertEqual(testee.iconType, .warning)
        XCTAssertEqual(testee.date, testData.date.dateTimeString)
    }

    // MARK: - Accessibility label

    func test_a11yLabel_shouldCombineAllElements() {
        testee = makeViewModel(model: .make(
            title: testData.title,
            icon: .information,
            startDate: testData.date
        ))

        XCTAssertContains(testee.a11yLabel, "Global Announcement")
        XCTAssertContains(testee.a11yLabel, "Information")
        XCTAssertContains(testee.a11yLabel, testData.date.dateTimeString)
        XCTAssertContains(testee.a11yLabel, testData.title)
    }

    func test_a11yLabel_shouldContainIconType() {
        testee = makeViewModel(model: .make(icon: .calendar))
        XCTAssertContains(testee.a11yLabel, "Calendar")

        testee = makeViewModel(model: .make(icon: .information))
        XCTAssertContains(testee.a11yLabel, "Information")

        testee = makeViewModel(model: .make(icon: .question))
        XCTAssertContains(testee.a11yLabel, "Question")

        testee = makeViewModel(model: .make(icon: .warning))
        XCTAssertContains(testee.a11yLabel, "Warning")

        testee = makeViewModel(model: .make(icon: .error))
        XCTAssertContains(testee.a11yLabel, "Error")
    }

    // MARK: - didTapCard

    func test_didTapCard_shouldInvokeCallback() {
        let expectedController = WeakViewController(.init())
        var receivedController: WeakViewController?
        var tapCount = 0

        testee = makeViewModel(
            model: .make(),
            onCardTap: {
                receivedController = $0
                tapCount += 1
            }
        )

        testee.didTapCard(from: expectedController)

        XCTAssertEqual(receivedController === expectedController, true)
        XCTAssertEqual(tapCount, 1)
    }

    // MARK: - Equatability

    func test_equatable_withSameModel_shouldBeEqual() {
        let vm1 = makeViewModel(model: .make(id: testData.id))
        let vm2 = makeViewModel(model: .make(id: testData.id))

        XCTAssertEqual(vm1, vm2)
    }

    func test_equatable_withDifferentModels_shouldNotBeEqual() {
        let vm1 = makeViewModel(model: .make(title: "1"))
        let vm2 = makeViewModel(model: .make(title: "2"))

        XCTAssertNotEqual(vm1, vm2)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        model: GlobalAnnouncementsWidgetItem,
        onCardTap: @escaping (WeakViewController) -> Void = { _ in }
    ) -> GlobalAnnouncementCardViewModel {
        GlobalAnnouncementCardViewModel(
            model: model,
            onCardTap: onCardTap
        )
    }
}
