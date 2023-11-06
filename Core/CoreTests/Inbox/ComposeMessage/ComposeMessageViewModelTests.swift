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

import Foundation
import Combine
@testable import Core
import CoreData
import XCTest

class ComposeMessageViewModelTests: CoreTestCase {
    private var mockInteractor: ComposeMessageInteractorMock!
    var testee: ComposeMessageViewModel!

    override func setUp() {
        super.setUp()
        mockInteractor = ComposeMessageInteractorMock(context: databaseClient)
        testee = ComposeMessageViewModel(router: router, interactor: mockInteractor)
    }

    func testInteractorStateMappedToViewModel() {
        XCTAssertEqual(testee.state, mockInteractor.state.value)
        XCTAssertEqual(testee.courses, mockInteractor.courses.value)
    }
}

private class ComposeMessageInteractorMock: ComposeMessageInteractor {
    var state: CurrentValueSubject<Core.StoreState, Never>
    var courses: CurrentValueSubject<[Core.InboxCourse], Never>

    init(context: NSManagedObjectContext) {
        self.state = .init(.data)
        self.courses = .init(.make(count: 5, in: context))
    }

    func send(parameters: MessageParameters) -> Future<Void, Error> {
        return mockFuture
    }

    private var mockFuture: Future<Void, Error> {
        Future<Void, Error> { promise in
            promise(.success(()))
        }
    }
}
