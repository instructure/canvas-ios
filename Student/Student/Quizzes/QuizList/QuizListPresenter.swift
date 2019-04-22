//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import CoreData
import Core

class QuizListPresenter {
    let courseID: String
    let env: AppEnvironment
    weak var view: QuizListViewProtocol?
    var viewIsVisible = false
    var sectionIndex: [Int] = []

    lazy var quizzes: Store<GetQuizzes> = {
        let useCase = GetQuizzes(courseID: self.courseID)
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var course: Store<GetCourseUseCase> = {
        let useCase = GetCourseUseCase(courseID: courseID)
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

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
        view?.updateNavBar(subtitle: course.first?.name, color: course.first?.color)
        view?.update(isLoading: quizzes.pending)
        if let error = course.error ?? quizzes.error {
            view?.showError(error)
        }
    }

    func quiz(_ index: IndexPath) -> Quiz? {
        return quizzes[IndexPath(row: index.row, section: sectionIndex[index.section])]
    }

    func section(_ index: Int) -> NSFetchedResultsSectionInfo? {
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
        quizzes.refresh()
        course.refresh()
    }

    func pageViewStarted() {
        viewIsVisible = true
        // log page view
    }

    func pageViewEnded() {
        viewIsVisible = false
        // log page view
    }

    func select(_ quiz: Quiz, from view: UIViewController) {
        env.router.route(to: quiz.htmlURL, from: view, options: nil)
    }
}
