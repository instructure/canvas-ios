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
import Core
import Foundation

final class CustomGradebookColumnsInteractorPreview: CustomGradebookColumnsInteractor {
    var studentNoteEntries: [StudentNotesEntry] = [
        .make(title: "Notes", content: "This is some note about a student"),
        .make(title: "Other Notes", content: .loremIpsumLong)
    ]

    var courseId: String = ""

    func loadCustomColumnsData() -> AnyPublisher<Void, Error> {
        Publishers.typedJust()
    }

    func getCustomColumnEntries(columnId: String, ignoreCache: Bool) -> AnyPublisher<[CDCustomGradebookColumnEntry], Error> {
        Publishers.typedJust([])
    }

    func getStudentNotesEntries(userId: String) -> AnyPublisher<[StudentNotesEntry], Error> {
        Publishers.typedJust(studentNoteEntries)
    }
}

#endif
