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

import Combine
import Foundation

#if DEBUG

final class GlobalAnnouncementsWidgetInteractorMock: GlobalAnnouncementsWidgetInteractor {

    var mockAnnouncements: [GlobalAnnouncementsWidgetItem] = []

    // MARK: - loadAnnouncements

    var loadAnnouncementsCallCount: Int = 0
    var loadAnnouncementsInput: Bool?
    var loadAnnouncementsOutputError: Error?

    func loadAnnouncements(ignoreCache: Bool) -> AnyPublisher<Void, any Error> {
        loadAnnouncementsInput = ignoreCache
        loadAnnouncementsCallCount += 1

        if let error = loadAnnouncementsOutputError {
            return Publishers.typedFailure(error: error)
        }

        return Publishers.typedJust()
    }

    // MARK: - observeAnnouncements

    var observeAnnouncementsCallCount: Int = 0
    var observeAnnouncementsOutputValue: [GlobalAnnouncementsWidgetItem] { mockAnnouncements }
    var observeAnnouncementsOutputError: Error?

    func observeAnnouncements() -> AnyPublisher<[GlobalAnnouncementsWidgetItem], Error> {
        observeAnnouncementsCallCount += 1

        if let error = observeAnnouncementsOutputError {
            return Publishers.typedFailure(error: error)
        }

        return Publishers.typedJust(observeAnnouncementsOutputValue)
    }

    // MARK: - deleteAnnouncement

    var deleteAnnouncementCallCount: Int = 0
    var deleteAnnouncementInput: String?

    func deleteAnnouncement(id: String) -> AnyPublisher<Void, Never> {
        deleteAnnouncementInput = id
        deleteAnnouncementCallCount += 1

        return Publishers.typedJust()
    }
}

#endif
