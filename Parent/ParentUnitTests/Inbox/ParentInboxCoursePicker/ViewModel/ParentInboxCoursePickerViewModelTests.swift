//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

@testable import Parent
import CoreData
import XCTest
import Combine
import Core
import TestsFoundation

class ParentInboxCoursePickerViewModelTests: ParentTestCase {
    private var mockInteractor: ParentInboxCoursePickerInteractorMock!
    var testee: ParentInboxCoursePickerViewModel!

    override func setUp() {
        super.setUp()
        mockInteractor = ParentInboxCoursePickerInteractorMock(env: env)
        testee = ParentInboxCoursePickerViewModel(interactor: mockInteractor, environment: env, router: router)
    }

    func testInteractorStateMappedToViewModel() {
        XCTAssertEqual(testee.state, mockInteractor.state.value)
        XCTAssertEqual(testee.items, mockInteractor.studentContextItems.value)
    }

    func testRefreshTap() {
        XCTAssertEqual(false, mockInteractor.isRefreshCalled)
        testee.didTapRefresh.accept(())
        XCTAssertEqual(true, mockInteractor.isRefreshCalled)

    }

    func testItemTap() {
        let selectedItem = mockInteractor.studentContextItems.value.first!
        testee.didTapContext.accept((WeakViewController(), selectedItem))
        wait(for: [router.dismissExpectation], timeout: 1)
        wait(for: [router.showExpectation], timeout: 1)
        let viewController = router.viewControllerCalls.last?.0
        XCTAssert(viewController is CoreHostingController<ComposeMessageView>)
    }
}

private class ParentInboxCoursePickerInteractorMock: ParentInboxCoursePickerInteractor {
    var state = CurrentValueSubject<StoreState, Never>(.data)
    var studentContextItems = CurrentValueSubject<[StudentContextItem], Never>([])
    private(set) var isRefreshCalled = false

    func getCourseURL(courseId: String) -> String {
        return "https://instructure.com/courses/\(courseId)"
    }

    func refresh() -> AnyPublisher<[Void], Never> {
        isRefreshCalled = true
        return Future<[Void], Never> { _ in }.eraseToAnyPublisher()
    }

    init(env: AppEnvironment) {
        self.studentContextItems = CurrentValueSubject<[StudentContextItem], Never>([
            StudentContextItem(studentId: "1", studentDisplayName: "User 1", course: .make()),
            StudentContextItem(studentId: "2", studentDisplayName: "User 2", course: .make())
        ])
    }

}
