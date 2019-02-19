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

import Core

extension Quiz: QuizListItemModel {
    public var gradingType: GradingType { return .points }
    public var viewableGrade: String? { return nil }
    public var viewableScore: Double? { return nil }
}

class QuizListPresenter {
    let courseID: String
    let env: AppEnvironment
    weak var view: QuizListViewProtocol?
    var viewIsVisible = false

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

    private func update() {
        view?.updateNavBar(subtitle: course.first?.name, color: course.first?.color)
        view?.update(isLoading: quizzes.pending)
        if let error = course.error ?? quizzes.error {
            view?.showError(error)
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

    func select(_ quiz: QuizListItemModel, from view: UIViewController) {
        env.router.route(to: quiz.htmlURL, from: view, options: nil)
    }
}
