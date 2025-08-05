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

protocol StudentAccessInteractor: AnyObject {
  func isRestricted() -> AnyPublisher<Bool, Never>
}

final class StudentAccessInteractorLive: StudentAccessInteractor {
    // MARK: - Private Properties
    private let featureFlagsStore: ReactiveStore<GetEnvironmentFeatureFlags>

    // MARK: - Init
    public init(env: AppEnvironment) {
        self.featureFlagsStore = ReactiveStore(
            useCase: GetEnvironmentFeatureFlags(context: .currentUser),
            environment: env
        )
    }

    // MARK: - Output
    public func isRestricted() -> AnyPublisher<Bool, Never> {
        featureFlagsStore
            .getEntities(keepObservingDatabaseChanges: true)
            .map { $0.isFeatureEnabled(.restrict_student_access) }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
