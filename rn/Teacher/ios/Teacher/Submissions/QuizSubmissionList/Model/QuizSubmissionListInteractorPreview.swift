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

#if DEBUG

import Combine
import Core

public class QuizSubmissionListInteractorPreview: QuizSubmissionListInteractor {
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)
    public var submissions = CurrentValueSubject<[QuizSubmissionListItem], Never>([])
    public var quizTitle = CurrentValueSubject<String, Never>("Title")
    public let courseID: String = ""
    public let quizID: String = ""

    public init(env: AppEnvironment, submissions: [QuizSubmissionListItem] = []) {
        self.submissions = CurrentValueSubject<[QuizSubmissionListItem], Never>(submissions)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            if submissions.isEmpty {
                state.send(.empty)
            } else {
                state.send(.data)
            }
        }
    }

    public func setFilter(_ filter: QuizSubmissionListFilter) -> Future<Void, Never> {
        Future<Void, Never> { promise in
            promise(.success(()))
        }
    }

    public func refresh() -> Future<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                promise(.success(()))
            }
        }
    }

    public func createMessageUserInfo() -> Future<[String: Any], Never> {
        Future<[String: Any], Never> { promise in
            promise(.success([:]))
        }
    }
}

#endif
