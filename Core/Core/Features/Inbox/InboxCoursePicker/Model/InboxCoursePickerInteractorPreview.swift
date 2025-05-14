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

import Foundation
import Combine

class InboxCoursePickerInteractorPreview: InboxCoursePickerInteractor {
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.data)
    public var favoriteCourses = CurrentValueSubject<[Course], Never>([])
    public var moreCourses = CurrentValueSubject<[Course], Never>([])
    public var groups = CurrentValueSubject<[Group], Never>([])

    public init(env: AppEnvironment) {
        self.favoriteCourses = CurrentValueSubject<[Course], Never>([
            .save(.make(id: "3", name: "Course 3 (favorite)", is_favorite: true), in: env.database.viewContext)
        ])
        self.moreCourses = CurrentValueSubject<[Course], Never>([
            .save(.make(id: "1", name: "Course 1"), in: env.database.viewContext),
            .save(.make(id: "2", name: "Course 2"), in: env.database.viewContext)
        ])
        self.groups = CurrentValueSubject<[Group], Never>([
            .save(.make(id: "1", name: "Group 1"), in: env.database.viewContext)
        ])
    }

    func refresh() -> AnyPublisher<[Void], Never> {
        Future<[Void], Never> {_ in }.eraseToAnyPublisher()
    }
}

#endif
