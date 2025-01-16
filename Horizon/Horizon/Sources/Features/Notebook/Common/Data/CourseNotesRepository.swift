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
    func add(index: NotebookNoteIndex,
             content: String?,
             labels: [CourseNoteLabel]?
    ) -> Future<CourseNote?, Error>
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

/// id: The unique identifier of the note.
/// date: The date when the note was created.
/// content: The user written content of the note.
/// courseId: The id of the course where the note was taken.
/// highlightKey: globally unique key belonging to the block of text in which this highlight was made.
/// labels: The labels assigned to the note. (e.g., important, confusing)
/// length: The length of the highlighted text.
/// startIndex: The start index of the highlighted text.
struct RepositoryNote {
    let id: String
    let date: Date
    let content: String
    let courseId: String
    let highlightKey: String
    let labels: [String]
    let length: Int
    let startIndex: Int
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
            highlightKey: self.highlightKey,
            highlightStart: self.startIndex,
            highlightLength: self.length,
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

    func add(index: NotebookNoteIndex,
             content: String?,
             labels: [CourseNoteLabel]?
    ) -> Future<CourseNote?, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                return promise(.success(nil))
            }
            guard let course = self.courses.first(where: { $0.id == index.groupId }) else {
                return promise(.success(nil))
            }

            // Generate a new unique ID (in this case, we'll use a timestamp-based approach)
            let date = Date()
            let newId = String(date.timeIntervalSince1970)

            // Create the new note
            let newNote = RepositoryNote(
                id: newId,
                date: date,
                content: content ?? "",
                courseId: index.groupId,
                highlightKey: index.highlightKey,
                labels: labels?.map { $0.rawValue } ?? [],
                length: index.length,
                startIndex: index.startIndex
            )

            // Add the note to our collection
            self.notes.append(newNote)

            // Notify subscribers about the change
            self.notify()

            let courseNote = newNote.toCourseNote(withCourse: course)
            promise(.success(courseNote))
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
                    highlightKey: oldNote.highlightKey,
                    labels: labels?.map { $0.rawValue } ?? oldNote.labels,
                    length: oldNote.length,
                    startIndex: oldNote.startIndex
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
        RepositoryCourse(id: "13", name: "STAT135", institution: "Utah Valley University")
    ]

    private static var defaultNotes: [RepositoryNote] {
        []
    }
}
