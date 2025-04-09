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

public final class CourseSyncSyllabusInteractorLive: CourseSyncSyllabusInteractor {
    let assignmentEventHtmlParser: HTMLParser
    let calendarEventHtmlParser: HTMLParser
    let envResolver: CourseSyncEnvironmentResolver

    public init(
        assignmentEventHtmlParser: HTMLParser,
        calendarEventHtmlParser: HTMLParser,
        envResolver: CourseSyncEnvironmentResolver
    ) {
        self.assignmentEventHtmlParser = assignmentEventHtmlParser
        self.calendarEventHtmlParser = calendarEventHtmlParser
        self.envResolver = envResolver
    }

    public func getContent(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        Publishers
            .Zip(fetchSyllabusContent(courseId: courseId),
                 fetchSyllabusSummary(courseId: courseId))
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public func cleanContent(courseId: CourseSyncID) -> AnyPublisher<Void, Never> {
        let rootURLAssignmentEvent = assignmentEventHtmlParser.sectionFolder(for: courseId)
        let rootURLCalendarEvent = calendarEventHtmlParser.sectionFolder(for: courseId)
        return Publishers.Zip(
            FileManager.default.removeItemPublisher(at: rootURLAssignmentEvent),
            FileManager.default.removeItemPublisher(at: rootURLCalendarEvent)
        )
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    // MARK: - Syllabus Summary

    private func fetchSyllabusSummary(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        let environment = envResolver.targetEnvironment(for: courseId)
        return fetchCourseSettingsAndGetSyllabusSummaryState(courseId: courseId)
            .filter { $0 }
            .mapToVoid()
            .flatMap { [assignmentEventHtmlParser, calendarEventHtmlParser] in
                Publishers
                    .Zip(
                        Self.fetchAssignments(
                            courseId: courseId,
                            htmlParser: assignmentEventHtmlParser,
                            environment: environment
                        ),
                        Self.fetchEvents(
                            courseId: courseId,
                            htmlParser: calendarEventHtmlParser,
                            environment: environment
                        )
                    )
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    typealias SyllabusSummaryEnabled = Bool
    private func fetchCourseSettingsAndGetSyllabusSummaryState(courseId: CourseSyncID) -> AnyPublisher<SyllabusSummaryEnabled, Error> {
        ReactiveStore(
            useCase: GetCourseSettings(courseID: courseId.localID),
            environment: envResolver.targetEnvironment(for: courseId)
        )
        .getEntities(ignoreCache: true)
        .map { $0.first?.syllabusCourseSummary == true }
        .eraseToAnyPublisher()
    }

    private static func fetchAssignments(courseId: CourseSyncID, htmlParser: HTMLParser, environment: AppEnvironment) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetCalendarEvents(context: courseId.asContext, type: .assignment),
            environment: environment
        )
        .getEntities(ignoreCache: true)
        .map { (assignments: [CalendarEvent]) -> [CalendarEvent] in
            // AssignmentEvent objects' ids are synthetic ids, which means they contain the type as prefix: assignment_987.
            // We store the prefix separately so it doesn't neccessary
            assignments.forEach { a in
                if let index = a.id.firstIndex(of: "_") {
                    a.id = String(a.id.suffix(from: a.id.index(index, offsetBy: 1)))
                }
            }
            return assignments
        }
        .parseHtmlContent(attribute: \.details, id: \.id, courseId: courseId, baseURLKey: \.htmlURL, htmlParser: htmlParser)
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    private static func fetchEvents(courseId: CourseSyncID, htmlParser: HTMLParser, environment: AppEnvironment) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetCalendarEvents(context: courseId.asContext, type: .event),
            environment: environment
        )
        .getEntities(ignoreCache: true)
        .parseHtmlContent(attribute: \.details, id: \.id, courseId: courseId, baseURLKey: \.htmlURL, htmlParser: htmlParser)
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    // MARK: - Syllabus Content

    private func fetchSyllabusContent(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        Publishers
            .Zip(fetchCourse(courseId: courseId),
                 fetchColors())
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func fetchCourse(courseId: CourseSyncID) -> AnyPublisher<Void, Error> {
        ReactiveStore(
            useCase: GetCourse(courseID: courseId.localID),
            environment: envResolver.targetEnvironment(for: courseId)
        )
        .getEntities(ignoreCache: true)
        .mapToVoid()
        .eraseToAnyPublisher()
    }

    private func fetchColors() -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCustomColors())
            .getEntities(ignoreCache: true)
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
