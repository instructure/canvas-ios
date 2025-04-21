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

import Core
import Combine

class SubmissionListInteractorLive: SubmissionListInteractor {

    var submissions = CurrentValueSubject<[Core.Submission], Never>([])
    var assignment = CurrentValueSubject<Assignment?, Never>(nil)

    let context: Context
    let assignmentID: String
    let env: AppEnvironment

    private var subscriptions = Set<AnyCancellable>()

    private let assignmentStore: ReactiveStore<GetAssignment>
    private let submissionsUseCase: GetSubmissions
    private let submissionsStore: ReactiveStore<GetSubmissions>

    init(context: Context, assignmentID: String, env: AppEnvironment) {
        self.context = context
        self.assignmentID = assignmentID
        self.env = env

        self.assignmentStore = ReactiveStore(
            useCase: GetAssignment(courseID: context.id, assignmentID: assignmentID),
            environment: env
        )

        self.submissionsUseCase = GetSubmissions(context: context, assignmentID: assignmentID)
        self.submissionsStore = ReactiveStore(
            useCase: submissionsUseCase,
            environment: env
        )

        setupBindings()
    }

    private func setupBindings() {

        assignmentStore
            .getEntities()
            .map { $0.first }
            .replaceError(with: nil)
            .subscribe(assignment)
            .store(in: &subscriptions)

        submissionsStore
            .getEntities()
            .replaceError(with: [])
            .subscribe(submissions)
            .store(in: &subscriptions)
    }

    func refresh() -> AnyPublisher<Void, Never> {
        Publishers.Last(upstream:
            assignmentStore
                .forceRefresh()
                .merge(with: submissionsStore.forceRefresh())
        )
        .eraseToAnyPublisher()
    }

    func applyFilter(_ filter: [Core.GetSubmissions.Filter]) {
        //
    }
}
