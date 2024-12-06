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

protocol CourseNotesRepositoryProtocol {
    func delete(id: String) -> Future<Void, Error>
    func get() -> AnyPublisher<[CourseNote], any Error>
    func get(id: String) -> AnyPublisher<CourseNote?, any Error>
    func set(id: String, content: String?, labels: [CourseNoteLabel]?) -> Future<Void, Error>
}

struct RepositoryNote {
    let id: String
    let date: Date
    let content: String
    let institution: String
    let courseId: String
    let course: String
    let labels: [String]
}

extension RepositoryNote {
    func toCourseNote() -> CourseNote {
        CourseNote(
            id: self.id,
            date: self.date,
            content: self.content,
            institution: self.institution,
            courseId: self.courseId,
            course: self.course,
            labels: self.labels.map { CourseNoteLabel(rawValue: $0) ?? .other }
       )
    }
}

class StaticCourseNotesRepository: CourseNotesRepositoryProtocol {
    // MARK: - Static

    static let instance: CourseNotesRepositoryProtocol = StaticCourseNotesRepository()

    // MARK: - Properties

    private let courseNotesPublisher = CurrentValueSubject<[CourseNote], Error>([])
    private var courseNotePublisher: [String: CurrentValueSubject<CourseNote?, Error>] = [:]

    // MARK: - Init

    private init() {}

    // MARK: - Public

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

    func get() -> AnyPublisher<[CourseNote], any Error> {
        courseNotesPublisher.send(notes.toCourseNotes())
        return courseNotesPublisher.eraseToAnyPublisher()
    }

    func get(id: String) -> AnyPublisher<CourseNote?, any Error> {
        let courseNote = notes
            .first { $0.id == id }?
            .toCourseNote()
        let publisher = courseNotePublisher[id, default: CurrentValueSubject(courseNote)]
        courseNotePublisher[id] = publisher
        publisher.send(courseNote)
        return publisher.eraseToAnyPublisher()
    }

    func set(id: String, content: String? = nil, labels: [CourseNoteLabel]? = nil) -> Future<Void, Error> {
        Future { promise in
            if let index = self.notes.firstIndex(where: { $0.id == id }) {
                let oldNote = self.notes[index]
                let repositoryNote = RepositoryNote(
                    id: oldNote.id,
                    date: oldNote.date,
                    content: content ?? oldNote.content,
                    institution: oldNote.institution,
                    courseId: oldNote.courseId,
                    course: oldNote.course,
                    labels: labels?.map { $0.rawValue } ?? oldNote.labels
                )
                self.notes[index] = repositoryNote
                self.notify(id: id)
            }
            promise(.success(()))
        }
    }

    // MARK: - Private

    private func notify(id: String? = nil) {
        if let id = id,
            let courseNotePublisher = self.courseNotePublisher[id],
            let courseNote = notes.first(where: { $0.id == id })?.toCourseNote() {
            courseNotePublisher.send(courseNote)
        }
        let courseNotes = notes.toCourseNotes()
        self.courseNotesPublisher.send(courseNotes)
    }

    private var notes: [RepositoryNote] = [
        RepositoryNote(id: "1",
                   date: Date(timeIntervalSinceNow: -10000),
                   content: "The full user-generated note here. Lorem ipsum dolor sit amet adipiscing so do eed at leo magna. Nunc sit amet velit faucibus, tristique orci ut, posuere odio. Pellentesque venenatis neque ipsum, in malesuada elit egestas hendrerit.",
                   institution: "Brigham Young University",
                   courseId: "1", course: "CS193P",
                   labels: ["Important"]),
        RepositoryNote(id: "2",
                   date: Date(timeIntervalSinceNow: -50000),
                   content: "This is a note 2",
                   institution: "Brigham Young University",
                   courseId: "1", course: "CS193P",
                   labels: ["Confusing"]),
        RepositoryNote(id: "3",
                   date: Date(timeIntervalSinceNow: -30000),
                   content: "This is a note 3",
                   institution: "Brigham Young University",
                   courseId: "1", course: "CS193P",
                   labels: ["Important"]),
        RepositoryNote(id: "4",
                   date: Date(timeIntervalSinceNow: -70000),
                   content: "This is a note 4",
                   institution: "Brigham Young University",
                   courseId: "1", course: "CS193P",
                   labels: ["Confusing"]),
        RepositoryNote(id: "5",
                   date: Date(timeIntervalSinceNow: -100000),
                   content: "This is a note 5",
                   institution: "Brigham Young University",
                   courseId: "1", course: "CS193P",
                   labels: ["Important"]),
        RepositoryNote(id: "6",
                   date: Date(timeIntervalSinceNow: -200000),
                   content: "This is a note 6",
                   institution: "Brigham Young University",
                   courseId: "1", course: "CS193P",
                   labels: ["Confusing"]),
        RepositoryNote(id: "7",
                   date: Date(timeIntervalSinceNow: -150000),
                   content: "This is a note 7",
                   institution: "Brigham Young University",
                   courseId: "1", course: "CS193P",
                   labels: ["Important"]),
        RepositoryNote(id: "8",
                   date: Date(),
                   content: "This is a note 8",
                   institution: "Brigham Young University",
                   courseId: "1",
                   course: "CS193P",
                   labels: ["Confusing"]),
        RepositoryNote(id: "9",
                   date: Date(),
                   content: "Exploring advanced Swift features",
                   institution: "Snow College",
                   courseId: "2",
                   course: "6.006",
                   labels: ["Important", "Complex"]),
        RepositoryNote(id: "10",
                   date: Date(),
                   content: "Data structures and algorithms overview",
                   institution: "Snow College",
                   courseId: "2",
                   course: "6.006",
                   labels: ["Important"]),
        RepositoryNote(id: "11",
                   date: Date(),
                   content: "Object-oriented programming concepts",
                   institution: "University of Utah",
                   courseId: "3",
                   course: "CS50",
                   labels: ["Important"]),
        RepositoryNote(id: "12",
                   date: Date(),
                   content: "Introduction to Machine Learning",
                   institution: "University of Utah",
                   courseId: "4",
                   course: "CS50",
                   labels: ["Important", "Confusing"]),
        RepositoryNote(id: "13",
                   date: Date(),
                   content: "Linear Algebra fundamentals",
                   institution: "Brigham Young University",
                   courseId: "5",
                   course: "MATH51",
                   labels: ["Confusing"]),
        RepositoryNote(id: "14",
                   date: Date(),
                   content: "Multivariable Calculus review",
                   institution: "Brigham Young University",
                   courseId: "5",
                   course: "MATH51",
                   labels: ["Important"]),
        RepositoryNote(id: "15",
                   date: Date(),
                   content: "Basics of Probability and Statistics",
                   institution: "Utah Valley University",
                   courseId: "6",
                   course: "STAT134",
                   labels: ["Important"]),
        RepositoryNote(id: "16",
                   date: Date(),
                   content: "Statistical Modeling Techniques",
                   institution: "Utah Valley University",
                   courseId: "6",
                   course: "STAT134",
                   labels: ["Confusing"]),
        RepositoryNote(id: "17",
                   date: Date(),
                   content: "Introduction to Databases",
                   institution: "Southern Utah University",
                   courseId: "7",
                   course: "CS411",
                   labels: ["Important"]),
        RepositoryNote(id: "18",
                   date: Date(),
                   content: "SQL and NoSQL Databases",
                   institution: "Southern Utah University",
                   courseId: "7",
                   course: "CS411",
                   labels: ["Confusing"]),
        RepositoryNote(id: "19",
                   date: Date(),
                   content: "Basic Operating Systems concepts",
                   institution: "Utah State University",
                   courseId: "8",
                   course: "15-213",
                   labels: ["Important"]),
        RepositoryNote(id: "20",
                   date: Date(),
                   content: "Concurrency in Operating Systems",
                   institution: "Utah State University",
                   courseId: "8",
                   course: "15-213",
                   labels: ["Confusing"]),
        RepositoryNote(id: "21",
                   date: Date(),
                   content: "Network protocols and architectures",
                   institution: "University of Washington",
                   courseId: "9",
                   course: "CSE461",
                   labels: ["Important"]),
        RepositoryNote(id: "22",
                   date: Date(),
                   content: "Computer Security fundamentals",
                   institution: "University of Washington",
                   courseId: "9",
                   course: "CSE461",
                   labels: ["Important", "Confusing"]),
        RepositoryNote(id: "23",
                   date: Date(),
                   content: "Introduction to Artificial Intelligence",
                   institution: "Brigham Young University",
                   courseId: "10",
                   course: "CS221",
                   labels: ["Important"]),
        RepositoryNote(id: "24",
                   date: Date(),
                   content: "Deep Learning basics",
                   institution: "Brigham Young University",
                   courseId: "11",
                   course: "CS229",
                   labels: ["Confusing"]),
        RepositoryNote(id: "25",
                   date: Date(),
                   content: "Natural Language Processing",
                   institution: "Snow College",
                   courseId: "12",
                   course: "6.864",
                   labels: ["Important", "Complex"]),
        RepositoryNote(id: "26",
                   date: Date(),
                   content: "Advanced Data Analysis techniques",
                   institution: "Utah Valley University",
                   courseId: "13",
                   course: "STAT135",
                   labels: ["Important"])
    ]
}

extension [RepositoryNote] {
    func toCourseNotes() -> [CourseNote] {
        self.map { $0.toCourseNote() }
    }
}
