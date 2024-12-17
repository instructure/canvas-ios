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

import Combine
import Foundation

protocol CourseNotesRepository {
    func add(courseId: String,
             highlightedText: String,
             content: String?,
             labels: [CourseNoteLabel]?
    ) -> Future<Void, Error>
    func delete(id: String) -> Future<Void, Error>
    func get() -> AnyPublisher<[CourseNote], Error>
    func get(id: String) -> AnyPublisher<CourseNote?, Error>
    func set(id: String, content: String?, labels: [CourseNoteLabel]?) -> Future<Void, Error>
}

struct RepositoryCourse {
    let id: String
    let name: String
    let institution: String
}

struct RepositoryNote {
    let id: String
    let date: Date
    let content: String
    let courseId: String
    let highlightedText: String
    let labels: [String]
}

extension RepositoryNote {
    func toCourseNote(withCourse course: RepositoryCourse) -> CourseNote {
        CourseNote(
            id: self.id,
            date: self.date,
            content: self.content,
            institution: course.institution,
            courseId: self.courseId,
            course: course.name,
            labels: self.labels.map { CourseNoteLabel(rawValue: $0) ?? .other }
        )
    }
}

extension Array where Element == RepositoryNote {
    func toCourseNotes(withCourses courses: [RepositoryCourse]) -> [CourseNote] {
        self.map { note in
            let course = courses.first { $0.id == note.courseId }
            guard let course = course else {
                return nil
            }
            return note.toCourseNote(withCourse: course)
        }.compactMap { $0 }
    }
}

class CourseNotesRepositoryPreview: CourseNotesRepository {
    // MARK: - Static

    static let instance: CourseNotesRepository = CourseNotesRepositoryPreview()

    // MARK: - Properties

    private let courseNotesPublisher = CurrentValueSubject<[CourseNote], Error>([])
    private var courseNotePublisher: [String: CurrentValueSubject<CourseNote?, Error>] = [:]

    private var courses: [RepositoryCourse]
    private var notes: [RepositoryNote]

    // MARK: - Init

    private init() {
        self.courses = Self.defaultCourses
        self.notes = Self.defaultNotes
    }

    // MARK: - Public Methods

    func add(courseId: String,
             highlightedText: String,
             content: String?,
             labels: [CourseNoteLabel]?
    ) -> Future<Void, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                return promise(.success(()))
            }

            // Generate a new unique ID (in this case, we'll use a timestamp-based approach)
            let date = Date()
            let newId = String(date.timeIntervalSince1970)

            // Create the new note
            let newNote = RepositoryNote(
                id: newId,
                date: date,
                content: content ?? "",
                courseId: courseId,
                highlightedText: highlightedText,
                labels: labels?.map { $0.rawValue } ?? []
            )

            // Add the note to our collection
            self.notes.append(newNote)

            // Notify subscribers about the change
            self.notify()

            promise(.success(()))
        }
    }

    func delete(id: String) -> Future<Void, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                return promise(.success(()))
            }
            if let index = self.notes.firstIndex(where: { $0.id == id }) {
                self.notes.remove(at: index)
            }
            self.notify()
            promise(.success(()))
        }
    }

    func get() -> AnyPublisher<[CourseNote], Error> {
        courseNotesPublisher.send(notes.toCourseNotes(withCourses: self.courses))
        return courseNotesPublisher.eraseToAnyPublisher()
    }

    func get(id: String) -> AnyPublisher<CourseNote?, Error> {
        let courseNote = notes.toCourseNotes(withCourses: self.courses).first { $0.id == id }
        let publisher = courseNotePublisher[id, default: CurrentValueSubject(courseNote)]
        courseNotePublisher[id] = publisher
        publisher.send(courseNote)
        return publisher.eraseToAnyPublisher()
    }

    func set(id: String, content: String? = nil, labels: [CourseNoteLabel]? = nil) -> Future<Void, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                return promise(.success(()))
            }

            if let index = self.notes.firstIndex(where: { $0.id == id }) {
                let oldNote = self.notes[index]
                let repositoryNote = RepositoryNote(
                    id: oldNote.id,
                    date: oldNote.date,
                    content: content ?? oldNote.content,
                    courseId: oldNote.courseId,
                    highlightedText: oldNote.highlightedText,
                    labels: labels?.map { $0.rawValue } ?? oldNote.labels
                )
                self.notes[index] = repositoryNote
                self.notify(id: id)
            }
            promise(.success(()))
        }
    }

    // MARK: - Private Methods

    private func notify(id: String? = nil) {
        if let id = id,
            let courseNotePublisher = self.courseNotePublisher[id],
            let note = notes.first(where: { $0.id == id }) {
            if let course = courses.first(where: { $0.id == note.courseId }) {
                courseNotePublisher.send(note.toCourseNote(withCourse: course))
            }
        }

        let courseNotes: [CourseNote] = notes.map { note in
            guard let course = courses.first(where: { $0.id == note.courseId }) else {
                return nil
            }
            return note.toCourseNote(withCourse: course)
        }.compactMap { $0 }
        self.courseNotesPublisher.send(courseNotes)
    }

    // MARK: - Default Data

    private static var defaultCourses: [RepositoryCourse] = [
        RepositoryCourse(id: "1", name: "CS193P", institution: "Brigham Young University"),
        RepositoryCourse(id: "2", name: "6.006", institution: "Snow College"),
        RepositoryCourse(id: "3", name: "CS50", institution: "University of Utah"),
        RepositoryCourse(id: "4", name: "CS50", institution: "University of Utah"),
        RepositoryCourse(id: "5", name: "MATH51", institution: "Brigham Young University"),
        RepositoryCourse(id: "6", name: "STAT134", institution: "Utah Valley University"),
        RepositoryCourse(id: "7", name: "CS411", institution: "Southern Utah University"),
        RepositoryCourse(id: "8", name: "15-213", institution: "Utah State University"),
        RepositoryCourse(id: "9", name: "CSE461", institution: "University of Washington"),
        RepositoryCourse(id: "10", name: "CS221", institution: "Brigham Young University"),
        RepositoryCourse(id: "11", name: "CS229", institution: "Brigham Young University"),
        RepositoryCourse(id: "12", name: "6.864", institution: "Snow College"),
        RepositoryCourse(id: "13", name: "STAT135", institution: "Utah Valley University"),
    ]

    private static var defaultNotes: [RepositoryNote] {
        [
            RepositoryNote(
                id: "1",
                date: Date(timeIntervalSinceNow: -10000),
                content: "This is going to be an example of a very long note...",
                courseId: "1",
                highlightedText: "example of a very long note",
                labels: ["Important"]
            ),
            RepositoryNote(
                id: "2",
                date: Date(timeIntervalSinceNow: -50000),
                content: "This is a note 2",
                courseId: "1",
                highlightedText: "note 2",
                labels: ["Confusing"]
            ),
            RepositoryNote(
                id: "3",
                date: Date(timeIntervalSinceNow: -30000),
                content: "This is a note 3",
                courseId: "1",
                highlightedText: "note 3",
                labels: ["Important"]
            ),
            RepositoryNote(
                id: "4",
                date: Date(timeIntervalSinceNow: -70000),
                content: "This is a note 4",
                courseId: "1",
                highlightedText: "note 4",
                labels: ["Confusing"]
            ),
            RepositoryNote(
                id: "5",
                date: Date(timeIntervalSinceNow: -100000),
                content: "This is a note 5",
                courseId: "1",
                highlightedText: "note 5",
                labels: ["Important"]
            ),
            RepositoryNote(
                id: "6",
                date: Date(timeIntervalSinceNow: -200000),
                content: "This is a note 6",
                courseId: "1",
                highlightedText: "note 6",
                labels: ["Confusing"]
            ),
            RepositoryNote(
                id: "7",
                date: Date(timeIntervalSinceNow: -150000),
                content: "This is a note 7",
                courseId: "1",
                highlightedText: "note 7",
                labels: ["Important"]
            ),
            RepositoryNote(
                id: "8",
                date: Date(),
                content: "This is a note 8",
                courseId: "1",
                highlightedText: "note 8",
                labels: ["Confusing"]
            ),
            RepositoryNote(
                id: "9",
                date: Date(),
                content: "Exploring advanced Swift features",
                courseId: "2",
                highlightedText: "advanced Swift features",
                labels: ["Important", "Complex"]
            ),
            RepositoryNote(
                id: "10",
                date: Date(),
                content: "Data structures and algorithms overview",
                courseId: "2",
                highlightedText: "Data structures and algorithms",
                labels: ["Important"]
            ),
            RepositoryNote(
                id: "11",
                date: Date(),
                content: "Object-oriented programming concepts",
                courseId: "3",
                highlightedText: "Object-oriented programming",
                labels: ["Important"]
            ),
            RepositoryNote(
                id: "12",
                date: Date(),
                content: "Introduction to Machine Learning",
                courseId: "4",
                highlightedText: "Machine Learning",
                labels: ["Important", "Confusing"]
            ),
            RepositoryNote(
                id: "13",
                date: Date(),
                content: "Linear Algebra fundamentals",
                courseId: "5",
                highlightedText: "Linear Algebra",
                labels: ["Confusing"]
            ),
            RepositoryNote(
                id: "14",
                date: Date(),
                content: "Multivariable Calculus review",
                courseId: "5",
                highlightedText: "Multivariable Calculus",
                labels: ["Important"]
            ),
            RepositoryNote(
                id: "15",
                date: Date(),
                content: "Basics of Probability and Statistics",
                courseId: "6",
                highlightedText: "Probability and Statistics",
                labels: ["Important"]
            ),
            RepositoryNote(
                id: "16",
                date: Date(),
                content: "Statistical Modeling Techniques",
                courseId: "6",
                highlightedText: "Statistical Modeling",
                labels: ["Confusing"]
            ),
            RepositoryNote(
                id: "17",
                date: Date(),
                content: "Introduction to Databases",
                courseId: "7",
                highlightedText: "Databases",
                labels: ["Important"]
            ),
            RepositoryNote(
                id: "18",
                date: Date(),
                content: "SQL and NoSQL Databases",
                courseId: "7",
                highlightedText: "SQL and NoSQL",
                labels: ["Confusing"]
            ),
            RepositoryNote(
                id: "19",
                date: Date(),
                content: "Basic Operating Systems concepts",
                courseId: "8",
                highlightedText: "Operating Systems",
                labels: ["Important"]
            ),
            RepositoryNote(
                id: "20",
                date: Date(),
                content: "Concurrency in Operating Systems",
                courseId: "8",
                highlightedText: "Concurrency",
                labels: ["Confusing"]
            ),
            RepositoryNote(
                id: "21",
                date: Date(),
                content: "Network protocols and architectures",
                courseId: "9",
                highlightedText: "Network protocols",
                labels: ["Important"]
            ),
            RepositoryNote(
                id: "22",
                date: Date(),
                content: "Computer Security fundamentals",
                courseId: "9",
                highlightedText: "Computer Security",
                labels: ["Important", "Confusing"]
            ),
            RepositoryNote(
                id: "23",
                date: Date(),
                content: "Introduction to Artificial Intelligence",
                courseId: "10",
                highlightedText: "Artificial Intelligence",
                labels: ["Important"]
            ),
            RepositoryNote(
                id: "24",
                date: Date(),
                content: "Deep Learning basics",
                courseId: "11",
                highlightedText: "Deep Learning",
                labels: ["Confusing"]
            ),
            RepositoryNote(
                id: "25",
                date: Date(),
                content: "Natural Language Processing",
                courseId: "12",
                highlightedText: "Natural Language Processing",
                labels: ["Important", "Complex"]
            ),
            RepositoryNote(
                id: "26",
                date: Date(),
                content: "Advanced Data Analysis techniques",
                courseId: "13",
                highlightedText: "Data Analysis",
                labels: ["Important"]
            )
        ]
    }
}
