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

class TimeSpentWidgetUseInteractorPreview: TimeSpentWidgetUseInteractor {
    let showError: Bool
    init(showError: Bool) {
        self.showError = showError
    }
    func getTimeSpent(ignoreCache: Bool) -> AnyPublisher<[TimeSpentWidgetModel], Error> {
        if showError {
            return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
        } else {
            return Just(
                [
                    .init(id: "1", courseName: "Introduction to SwiftUI", minutesPerDay: 125),
                    .init(id: "2", courseName: "Advanced iOS Development", minutesPerDay: 90),
                    .init(id: "3", courseName: "UI/UX Design Principles", minutesPerDay: 45),
                    .init(id: "4", courseName: "Networking with URLSession", minutesPerDay: 60),
                    .init(id: "5", courseName: "Core Data Essentials", minutesPerDay: 30)
                ]
            )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }
    }
}
#endif
