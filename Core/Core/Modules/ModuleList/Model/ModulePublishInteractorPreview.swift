//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class ModulePublishInteractorPreview: ModulePublishInteractor {
    enum MockState {
        case loading
        case error
        case data
    }
    private let state: MockState

    init(state: MockState) {
        self.state = state
        super.init(app: .teacher, courseId: "")
    }

    override func getFilePermission(
        fileContext: ModulePublishInteractor.FileContext
    ) -> AnyPublisher<ModulePublishInteractor.FilePermission, Error> {
        switch state {
        case .loading:
            return Empty(completeImmediately: false).eraseToAnyPublisher()
        case .error:
            return Fail(error: NSError.internalError()).eraseToAnyPublisher()
        case .data:
            let data = ModulePublishInteractor.FilePermission(unlockAt: Date(),
                                                              lockAt: Date(),
                                                              availability: .scheduledAvailability,
                                                              visibility: .institutionMembers)
            return Just(data).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
}

#endif
