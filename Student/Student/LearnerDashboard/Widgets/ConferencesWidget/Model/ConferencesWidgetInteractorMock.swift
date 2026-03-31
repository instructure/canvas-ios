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

final class ConferencesWidgetInteractorMock: ConferencesWidgetInteractor {

    // MARK: - getConferences

    var getConferencesCallCount = 0
    var getConferencesOutputValue: [ConferencesWidgetItem] = []
    var getConferencesOutputError: Error?

    func getConferences(ignoreCache: Bool) -> AnyPublisher<[ConferencesWidgetItem], Error> {
        getConferencesCallCount += 1

        if let error = getConferencesOutputError {
            return Fail(error: error).eraseToAnyPublisher()
        }

        return Publishers.typedJust(getConferencesOutputValue)
    }

    // MARK: - dismissConference

    var dismissConferenceCallCount = 0
    var dismissConferenceInput: String?

    func dismissConference(id: String) -> AnyPublisher<Void, Never> {
        dismissConferenceCallCount += 1
        dismissConferenceInput = id

        return Publishers.typedJust()
    }
}

#endif
