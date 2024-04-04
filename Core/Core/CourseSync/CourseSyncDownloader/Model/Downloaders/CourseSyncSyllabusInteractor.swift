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
    let assignmentEventHtmlParser: HTMLParser
    let calendarEventHtmlParser: HTMLParser

    public init(assignmentEventHtmlParser: HTMLParser, calendarEventHtmlParser: HTMLParser) {
        self.assignmentEventHtmlParser = assignmentEventHtmlParser
        self.calendarEventHtmlParser = calendarEventHtmlParser
    }

    public func getContent(courseId: String) -> AnyPublisher<Void, Error> {
        Publishers
            .Zip(fetchSyllabusContent(courseId: courseId),
                 fetchSyllabusSummary(courseId: courseId))
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public func cleanContent(courseId: String) -> AnyPublisher<Void, Never> {
        let rootURLAssignmentEvent = URL.Directories.documents.appendingPathComponent(
            URL.Paths.Offline.courseSectionFolder(
                sessionId: assignmentEventHtmlParser.sessionId,
                courseId: courseId,
                sectionName: assignmentEventHtmlParser.sectionName
            )
        )
        let rootURLCalendarEvent = URL.Directories.documents.appendingPathComponent(
            URL.Paths.Offline.courseSectionFolder(
                sessionId: calendarEventHtmlParser.sessionId,
                courseId: courseId,
                sectionName: calendarEventHtmlParser.sectionName
            )
        )
        let assignmentEventUrls = (try? FileManager.default.contentsOfDirectory(at: rootURLAssignmentEvent, includingPropertiesForKeys: nil)) ?? []
        let calendarEventUrls = (try? FileManager.default.contentsOfDirectory(at: rootURLCalendarEvent, includingPropertiesForKeys: nil)) ?? []
        let fileUrls = assignmentEventUrls + calendarEventUrls

        return fileUrls
            .publisher
            .compactMap { try? FileManager.default.removeItem(at: $0) }
            .map { try? FileManager.default.removeItem(at: rootURLAssignmentEvent) }
            .map { try? FileManager.default.removeItem(at: rootURLCalendarEvent) }
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    // MARK: - Syllabus Summary

    private func fetchSyllabusSummary(courseId: String) -> AnyPublisher<Void, Error> {
        fetchCourseSettingsAndGetSyllabusSummaryState(courseId: courseId)
            .filter { $0 }
            .mapToVoid()
            .flatMap { [assignmentEventHtmlParser, calendarEventHtmlParser] in
                Publishers
                    .Zip(Self.fetchAssignments(courseId: courseId, htmlParser: assignmentEventHtmlParser),
                         Self.fetchEvents(courseId: courseId, htmlParser: calendarEventHtmlParser))
            }
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    typealias SyllabusSummaryEnabled = Bool
    private func fetchCourseSettingsAndGetSyllabusSummaryState(courseId: String) -> AnyPublisher<SyllabusSummaryEnabled, Error> {
        ReactiveStore(useCase: GetCourseSettings(courseID: courseId))
            .getEntities(ignoreCache: true)
            .map { $0.first?.syllabusCourseSummary == true }
            .eraseToAnyPublisher()
    }

    private static func fetchAssignments(courseId: String, htmlParser: HTMLParser) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCalendarEvents(context: .course(courseId), type: .assignment))
            .getEntities(ignoreCache: true)
            .map { (assignments: [CalendarEvent]) -> [CalendarEvent] in
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

    private static func fetchEvents(courseId: String, htmlParser: HTMLParser) -> AnyPublisher<Void, Error> {
        ReactiveStore(useCase: GetCalendarEvents(context: .course(courseId), type: .event))
            .getEntities(ignoreCache: true)
            .parseHtmlContent(attribute: \.details, id: \.id, courseId: courseId, baseURLKey: \.htmlURL, htmlParser: htmlParser)
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
