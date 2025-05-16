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

import XCTest
import Combine
@testable import Core
@testable import Teacher

final class MockSubmissionListInteractor: SubmissionListInteractor {

    var submissionsSubject = PassthroughSubject<[Submission], Never>()
    var assignmentSubject = PassthroughSubject<Assignment?, Never>()
    var courseSubject = PassthroughSubject<Course?, Never>()

    var submissions: AnyPublisher<[Submission], Never> {
        submissionsSubject.eraseToAnyPublisher()
    }

    var assignment: AnyPublisher<Assignment?, Never> {
        assignmentSubject.eraseToAnyPublisher()
    }

    var course: AnyPublisher<Course?, Never> {
        courseSubject.eraseToAnyPublisher()
    }

    var context: Context
    var assignmentID: String

    init(context: Context, assignmentID: String) {
        self.context = context
        self.assignmentID = assignmentID
    }

    var refreshCalls: Int = 0
    func refresh() -> AnyPublisher<Void, Never> {
        refreshCalls += 1
        return Just<Void>(()).eraseToAnyPublisher()
    }

    var appliedFilters: [GetSubmissions.Filter] = []
    func applyFilters(_ filters: [GetSubmissions.Filter]) {
        appliedFilters = filters
    }
}
