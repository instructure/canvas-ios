//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import CoreData
import Core

class QuizListPresenter: PageViewLoggerPresenterProtocol {

    var pageViewEventName: String {
        return "courses/\(courseID)/quizzes"
    }

    let courseID: String
    let env: AppEnvironment
    weak var view: QuizListViewProtocol?
    var sectionIndex: [Int] = []

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }
    lazy var quizzes = env.subscribe(GetQuizzes(courseID: courseID)) { [weak self] in
        self?.update()
    }

    init(env: AppEnvironment = .shared, view: QuizListViewProtocol, courseID: String) {
        self.courseID = courseID
        self.env = env
        self.view = view
    }

    func sectionOrder(_ name: String) -> Int {
        switch QuizType(rawValue: name) {
        case .assignment?: return 0
        case .practice_quiz?: return 1
        case .graded_survey?: return 2
        case .survey?: return 3
        case .none: return 4
        }
    }

    private func update() {
        sectionIndex = quizzes.sections?.enumerated()
            .sorted(by: { sectionOrder($0.element.name) < sectionOrder($1.element.name) })
            .map { $0.offset } ?? []
        if let course = course.first, colors.pending == false {
            view?.updateNavBar(subtitle: course.name, color: course.color)
        }
        view?.update(isLoading: quizzes.pending)
        if let error = course.error ?? quizzes.error {
            view?.showError(error)
        }
    }

    func quiz(_ index: IndexPath) -> Quiz? {
        return quizzes[IndexPath(row: index.row, section: sectionIndex[index.section])]
    }

    func section(_ index: Int) -> NSFetchedResultsSectionInfo? {
        if sectionIndex.indices.contains(index) == false {
            return nil
        }
        return quizzes.sections?[sectionIndex[index]]
    }

    func sectionTitle(_ index: Int) -> String? {
        guard let typeRaw = section(index)?.name, let type = QuizType(rawValue: typeRaw) else { return nil }
        switch type {
        case .assignment:
            return NSLocalizedString("Assignments", bundle: .student, comment: "")
        case .practice_quiz:
            return NSLocalizedString("Practice Quizzes", bundle: .student, comment: "")
        case .graded_survey:
            return NSLocalizedString("Graded Surveys", bundle: .student, comment: "")
        case .survey:
            return NSLocalizedString("Surveys", bundle: .student, comment: "")
        }
    }

    func viewIsReady() {
        colors.refresh()
        course.refresh()
        quizzes.refresh()
    }

    func select(_ quiz: Quiz, from view: UIViewController) {
        guard let htmlURL = quiz.htmlURL else { return }
        env.router.route(to: htmlURL, from: view, options: .detail)
    }
}
