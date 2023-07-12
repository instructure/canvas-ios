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

import Combine
import Foundation

public protocol CourseSyncSyllabusInteractor: CourseSyncContentInteractor {}

extension CourseSyncSyllabusInteractor {
    public var associatedTabType: TabName { .syllabus }
}

public final class CourseSyncSyllabusInteractorLive: CourseSyncSyllabusInteractor, CourseSyncContentInteractor {
    public init() {}

    public func getContent(courseId: String) -> AnyPublisher<Void, Error> {
        Publishers
            .Zip(fetchSyllabusContent(courseId: courseId),
                 fetchSyllabusSummary(courseId: courseId))
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    // MARK: - Syllabus Summary

    private func fetchSyllabusSummary(courseId: String) -> AnyPublisher<Void, Error> {
        fetchCourseSettingsAndGetSyllabusSummaryState(courseId: courseId)
            .filter { $0 }
            .mapToVoid()
            .flatMap {
                Publishers
                    .Zip(Self.fetchAssignments(courseId: courseId),
                         Self.fetchEvents(courseId: courseId))
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    typealias SyllabusSummaryEnabled = Bool
    private func fetchCourseSettingsAndGetSyllabusSummaryState(courseId: String) -> AnyPublisher<SyllabusSummaryEnabled, Error> {
        ReactiveStore(useCase: GetCourseSettings(courseID: courseId))
            .getEntities()
            .map { $0.first?.syllabusCourseSummary == true }
            .eraseToAnyPublisher()
    }

    private static func fetchAssignments(courseId: String) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCalendarEvents(context: .course(courseId), type: .assignment))
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private static func fetchEvents(courseId: String) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCalendarEvents(context: .course(courseId), type: .event))
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    // MARK: - Syllabus Content

    private func fetchSyllabusContent(courseId: String) -> AnyPublisher<Void, Error> {
        Publishers
            .Zip(fetchCourse(courseId: courseId),
                 fetchColors())
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func fetchCourse(courseId: String) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCourse(courseID: courseId))
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func fetchColors() -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCustomColors())
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
