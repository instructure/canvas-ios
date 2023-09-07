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
import Combine
import CombineSchedulers
import XCTest

class CourseSyncListInteractorLiveTests: CoreTestCase {

    func testInteractorDeallocationNotCrashesActiveStream() {
        let mockAPIRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [.current_and_concluded],
            includes: [.tabs]
        )
        api.mock(mockAPIRequest, value: [.make()])
        let streamFinished = expectation(description: "")

        // WHEN
        let subscription = {
            let mockComposer = MockCourseSyncEntryComposerInteractor()
            let testee = CourseSyncListInteractorLive(entryComposerInteractor: mockComposer)
            return testee
                .getCourseSyncEntries(filter: .all)
                .sink(receiveCompletion: { _ in
                    streamFinished.fulfill()
                }, receiveValue: { _ in })
        }()

        // THEN
        // At this point testee is deallocated but the stream subscription is alive
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }
}

class MockCourseSyncEntryComposerInteractor: CourseSyncEntryComposerInteractor {

    func composeEntry(from course: CourseSyncSelectorCourse,
                      useCache: Bool)
    -> AnyPublisher<CourseSyncEntry, Error> {
        Just(CourseSyncEntry(name: "", id: "", tabs: [], files: []))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
