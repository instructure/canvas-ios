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

#if DEBUG

import Combine
import Core
import Foundation

final class CoursesInteractorMock: CoursesInteractor {
    enum MockBehavior {
        case success
        case failure(Error)
    }

    var acceptBehavior: MockBehavior = .success
    var declineBehavior: MockBehavior = .success
    var mockCoursesResult: CoursesResult = .make()
    var getCoursesDelay: TimeInterval = 0

    func getCourses(ignoreCache: Bool) -> AnyPublisher<CoursesResult, Error> {
        let publisher = Just(mockCoursesResult)
            .setFailureType(to: Error.self)

        if getCoursesDelay > 0 {
            return publisher
                .delay(for: .seconds(getCoursesDelay), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        } else {
            return publisher.eraseToAnyPublisher()
        }
    }

    func acceptInvitation(courseId: String, enrollmentId: String) -> AnyPublisher<Void, Error> {
        switch acceptBehavior {
        case .success:
            return Just(())
                .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }

    func declineInvitation(courseId: String, enrollmentId: String) -> AnyPublisher<Void, Error> {
        switch declineBehavior {
        case .success:
            return Just(())
                .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .delay(for: .seconds(2), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
}

#endif
