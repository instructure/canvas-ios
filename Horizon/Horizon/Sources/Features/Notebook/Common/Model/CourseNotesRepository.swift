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

import Foundation
import Combine

struct CourseNote {
    let id: String
    let date: Date
    let content: String
    let institution: String
    let courseId: String
    let course: String
    let labels: [String] // e.g. "Important", "Confusing", etc.
}

struct CourseNotesRepository {
    func get() -> AnyPublisher<[CourseNote], any Error> {
        return Just(notes).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    let notes: [CourseNote] = [
        CourseNote(id: UUID().uuidString, date: Date(timeIntervalSinceNow: -10000), content: "This is a note 1", institution: "Brigham Young University", courseId: "1", course: "CS193P", labels: ["Important"]),
        CourseNote(id: UUID().uuidString, date: Date(timeIntervalSinceNow: -50000), content: "This is a note 2", institution: "Brigham Young University", courseId: "1", course: "CS193P", labels: ["Confusing"]),
        CourseNote(id: UUID().uuidString, date: Date(timeIntervalSinceNow: -30000), content: "This is a note 3", institution: "Brigham Young University", courseId: "1", course: "CS193P", labels: ["Important"]),
        CourseNote(id: UUID().uuidString, date: Date(timeIntervalSinceNow: -70000), content: "This is a note 4", institution: "Brigham Young University", courseId: "1", course: "CS193P", labels: ["Confusing"]),
        CourseNote(id: UUID().uuidString, date: Date(timeIntervalSinceNow: -100000), content: "This is a note 5", institution: "Brigham Young University", courseId: "1", course: "CS193P", labels: ["Important"]),
        CourseNote(id: UUID().uuidString, date: Date(timeIntervalSinceNow: -200000), content: "This is a note 6", institution: "Brigham Young University", courseId: "1", course: "CS193P", labels: ["Confusing"]),
        CourseNote(id: UUID().uuidString, date: Date(timeIntervalSinceNow: -150000), content: "This is a note 7", institution: "Brigham Young University", courseId: "1", course: "CS193P", labels: ["Important"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "This is a note 8", institution: "Brigham Young University", courseId: "1", course: "CS193P", labels: ["Confusing"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Exploring advanced Swift features", institution: "Snow College", courseId: "2", course: "6.006", labels: ["Important", "Complex"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Data structures and algorithms overview", institution: "Snow College", courseId: "2", course: "6.006", labels: ["Important"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Object-oriented programming concepts", institution: "University of Utah", courseId: "3", course: "CS50", labels: ["Important"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Introduction to Machine Learning", institution: "University of Utah", courseId: "4", course: "CS50", labels: ["Important", "Confusing"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Linear Algebra fundamentals", institution: "Brigham Young University", courseId: "5", course: "MATH51", labels: ["Confusing"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Multivariable Calculus review", institution: "Brigham Young University", courseId: "5", course: "MATH51", labels: ["Important"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Basics of Probability and Statistics", institution: "Utah Valley University", courseId: "6", course: "STAT134", labels: ["Important"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Statistical Modeling Techniques", institution: "Utah Valley University", courseId: "6", course: "STAT134", labels: ["Confusing"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Introduction to Databases", institution: "Southern Utah University", courseId: "7", course: "CS411", labels: ["Important"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "SQL and NoSQL Databases", institution: "Southern Utah University", courseId: "7", course: "CS411", labels: ["Confusing"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Basic Operating Systems concepts", institution: "Utah State University", courseId: "8", course: "15-213", labels: ["Important"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Concurrency in Operating Systems", institution: "Utah State University", courseId: "8", course: "15-213", labels: ["Confusing"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Network protocols and architectures", institution: "University of Washington", courseId: "9", course: "CSE461", labels: ["Important"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Computer Security fundamentals", institution: "University of Washington", courseId: "9", course: "CSE461", labels: ["Important", "Confusing"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Introduction to Artificial Intelligence", institution: "Brigham Young University", courseId: "10", course: "CS221", labels: ["Important"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Deep Learning basics", institution: "Brigham Young University", courseId: "11", course: "CS229", labels: ["Confusing"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Natural Language Processing", institution: "Snow College", courseId: "12", course: "6.864", labels: ["Important", "Complex"]),
        CourseNote(id: UUID().uuidString, date: Date(), content: "Advanced Data Analysis techniques", institution: "Utah Valley University", courseId: "13", course: "STAT135", labels: ["Important"])
    ]
}
