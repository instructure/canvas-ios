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

#if DEBUG
import Combine
import Foundation

class CompletedWidgetInteractorPreview: CompletedWidgetInteractor {
    private let hasError: Bool

    init(hasError: Bool) {
        self.hasError = hasError
    }

    func getCompletedWidgets(ignoreCache: Bool) -> AnyPublisher<[CompletedWidgetModel], Error> {
        if hasError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else {
            return Just(
                [
                    .init(courseID: "101", courseName: "Biology Basics", moduleCountCompleted: 5),
                    .init(courseID: "102", courseName: "Chemistry 101", moduleCountCompleted: 3),
                    .init(courseID: "103", courseName: "Nursing Fundamentals", moduleCountCompleted: 8)
                ]
            )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
    }
}
#endif
