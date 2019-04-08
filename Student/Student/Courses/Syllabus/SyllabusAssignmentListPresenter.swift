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

import Foundation
import Core

protocol SyllabusAssignmentListViewProtocol: ErrorViewController, ColoredNavViewProtocol {
    func update()
}

class SyllabusAssignmentListPresenter {

    var sort: GetAssignments.Sort
    let courseID: String
    let env: AppEnvironment
    weak var view: SyllabusAssignmentListViewProtocol?

    lazy var course: Store<GetCourseUseCase> = {
        let useCase = GetCourseUseCase(courseID: courseID)
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var assignments: Store<GetAssignments> = {
        let useCase = GetAssignments(courseID: self.courseID, sort: sort)
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    init(env: AppEnvironment = .shared, view: SyllabusAssignmentListViewProtocol, courseID: String, sort: GetAssignments.Sort = .position) {
        self.courseID = courseID
        self.env = env
        self.view = view
        self.sort = sort
    }

    func viewIsReady() {
        assignments.refresh()
        course.refresh()
        update()
    }

    func update() {
        view?.update()
        loadColor()
    }

    func loadColor() {
        guard let course = course.first else { return }
        view?.updateNavBar(subtitle: course.name, color: course.color)
    }

    func select(_ assignment: Assignment, from: UIViewController) {
        env.router.route(to: assignment.htmlURL, from: from, options: nil)
    }

    func formattedDueDate(for: IndexPath) -> String {
        let assignment = assignments[`for`]
        var result = NSLocalizedString("No Due Date", comment: "")
        if let date = assignment?.dueAt {
            result = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
        }
        return result
    }

    func icon(for: IndexPath) -> UIImage? {
        let assignment = assignments[`for`]
        var image: UIImage? = .icon(.assignment, .line)
        if assignment?.quizID != nil {
            image = .icon(.quiz, .line)
        } else if assignment?.discussionTopic != nil {
            image = .icon(.discussion, .line)
        }
        return image
    }
}
