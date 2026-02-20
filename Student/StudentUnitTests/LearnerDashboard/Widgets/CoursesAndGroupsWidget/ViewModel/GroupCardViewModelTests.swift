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
import SwiftUI
import XCTest

final class GroupCardViewModelTests: StudentTestCase {

    private static let testData = (
        id: "group1",
        title: "some title",
        courseName: "some courseName",
        courseColorString: "#4A90D9",
        groupColorString: "#E91E63",
        memberCount: 42
    )
    private lazy var testData = Self.testData

    private var testee: GroupCardViewModel!

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Basic properties

    func test_basicProperties() {
        testee = makeViewModel(model: .make(
            id: testData.id,
            title: testData.title,
            courseName: testData.courseName,
            courseColorString: testData.courseColorString,
            groupColorString: testData.groupColorString,
            memberCount: testData.memberCount
        ))

        XCTAssertEqual(testee.id, testData.id)
        XCTAssertEqual(testee.title, testData.title)
        XCTAssertEqual(testee.courseName, testData.courseName)
        XCTAssertEqual(testee.courseColor.hexString, testData.courseColorString.lowercased())
        XCTAssertEqual(testee.groupColor.hexString, testData.groupColorString.lowercased())
        XCTAssertEqual(testee.memberCount, String(testData.memberCount))
    }

    // MARK: - didTapCard

    func test_didTapCard_shouldRouteToGroup() {
        testee = makeViewModel(model: .make(id: testData.id))
        let vc = UIViewController()

        testee.didTapCard(from: .init(vc))

        XCTAssertEqual(router.lastRoutedPath, "/groups/group1")
        XCTAssertEqual(router.lastRoutedFromVC, vc)
        XCTAssertEqual(router.lastRoutedOptions, .push)
    }

    // MARK: - Equatability

    func test_equatable_withSameModel_shouldBeEqual() {
        let vm1 = makeViewModel(model: .make(id: testData.id, title: testData.title))
        let vm2 = makeViewModel(model: .make(id: testData.id, title: testData.title))

        XCTAssertEqual(vm1, vm2)
    }

    func test_equatable_withDifferentModels_shouldNotBeEqual() {
        let vm1 = makeViewModel(model: .make(title: "title 1"))
        let vm2 = makeViewModel(model: .make(title: "title 2"))

        XCTAssertNotEqual(vm1, vm2)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        model: CoursesAndGroupsWidgetGroupItem = .make()
    ) -> GroupCardViewModel {
        GroupCardViewModel(
            model: model,
            router: router
        )
    }
}
