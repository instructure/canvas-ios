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

import Combine
@testable import Horizon
import Foundation

final class CourseCardsInteractorMock: CourseCardsInteractor {
    var shouldFail = false
    var error: Error = URLError(.badServerResponse)
    var coursesToReturn: [HCourse] = []
    
    func getAndObserveCoursesWithoutModules(ignoreCache: Bool) -> AnyPublisher<[HCourse], Error> {
        if shouldFail {
            return Fail(error: error).eraseToAnyPublisher()
        } else {
            return Just(coursesToReturn)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func refreshModuleItemsUponCompletions() -> AnyPublisher<Void, Never> {
        return Just(()).eraseToAnyPublisher()
    }
}
