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
import Core
import CombineExt

protocol HCourseSyncSyllabus {
    func getContent(courseIDs: [String])
    func cancelRequests()
}

final class HCourseSyncSyllabusLive: HCourseSyncSyllabus {
    // MARK: - Dependencies

    private let htmlParser: HTMLParser

    // MARK: - Properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(htmlParser: HTMLParser) {
        self.htmlParser = htmlParser
    }

    func getContent(courseIDs: [String]) {
        cancelRequests()
        Publishers.Sequence(sequence: courseIDs)
            .flatMap { [weak self] courseID -> AnyPublisher<Void, Never> in
                guard let self else { return Just(()).eraseToAnyPublisher() }
                return self.getCourseSyllabus(courseID: courseID)
            }
            .collect()
            .mapToVoid()
            .sink()
            .store(in: &subscriptions)
    }

    func cancelRequests() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }

    private func getCourseSyllabus(courseID: String) -> AnyPublisher<Void, Never> {
        ReactiveStore(useCase: GetCourse(courseID: courseID))
            .getEntities(ignoreCache: true)
            .parseHtmlContent(attribute: \.syllabusBody, id: \.id, courseId: .init(value: courseID), htmlParser: htmlParser)
            .replaceError(with: [])
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
