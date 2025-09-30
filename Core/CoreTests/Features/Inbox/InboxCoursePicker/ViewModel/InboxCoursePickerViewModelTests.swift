//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import CoreData
import XCTest
import Combine

class InboxCoursePickerViewModelTests: CoreTestCase {
    private var mockInteractor: InboxCoursePickerInteractorMock!
    var testee: InboxCoursePickerViewModel!

    override func setUp() {
        super.setUp()
        mockInteractor = InboxCoursePickerInteractorMock(env: AppEnvironment())
        testee = InboxCoursePickerViewModel(interactor: mockInteractor, didSelect: { _ in })
    }

    func testInteractorStateMappedToViewModel() {
        XCTAssertEqual(testee.state, mockInteractor.state.value)
        XCTAssertEqual(testee.favoriteCourses.count, 1)
        XCTAssertEqual(testee.moreCourses.count, 2)
        XCTAssertEqual(testee.groups.count, 1)
        XCTAssertEqual(testee.favoriteCourses.first?.name, "Course 3 (favorite)")
        XCTAssertEqual(testee.moreCourses.first?.name, "Course 1")
        XCTAssertEqual(testee.groups.first?.name, "Group 1")
    }

    func testFavoriteCourseSelection() {
        let context = testee.favoriteCourses.first!
        testee.onSelect(selected: context)
        XCTAssertEqual(testee.selectedRecipientContext?.context.id, context.id)

    }

    func testMoreCourseSelection() {
        let context = testee.moreCourses.first!
        testee.onSelect(selected: context)
        XCTAssertEqual(testee.selectedRecipientContext?.context.id, context.id)
    }

    func testGroupSelection() {
        let context = testee.groups.first!
        testee.onSelect(selected: context)
        XCTAssertEqual(testee.selectedRecipientContext?.context.id, context.id)

    }
}

private class InboxCoursePickerInteractorMock: InboxCoursePickerInteractor {
    var favoriteCourses: CurrentValueSubject<[Core.Course], Never>
    var moreCourses: CurrentValueSubject<[Core.Course], Never>
    var groups = CurrentValueSubject<[Group], Never>([])
    var state = CurrentValueSubject<StoreState, Never>(.data)

    init(env: AppEnvironment) {
        self.favoriteCourses = CurrentValueSubject<[Course], Never>([
            .save(.make(id: "3", name: "Course 3 (favorite)", is_favorite: true), in: env.database.viewContext)
        ])
        self.moreCourses = CurrentValueSubject<[Course], Never>([
            .save(.make(id: "1", name: "Course 1"), in: env.database.viewContext),
            .save(.make(id: "2", name: "Course 2"), in: env.database.viewContext)
        ])
        self.groups = CurrentValueSubject<[Group], Never>([
            .save(.make(id: "1", name: "Group 1"), in: env.database.viewContext)
        ])
    }

    func refresh() -> AnyPublisher<[Void], Never> {
        return Future<[Void], Never> { _ in }.eraseToAnyPublisher()
    }
}
