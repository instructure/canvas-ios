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

protocol SyllabusActionableItemsViewProtocol: ErrorViewController, ColoredNavViewProtocol {
    func update(models: [SyllabusActionableItemsViewController.ViewModel])
}

class SyllabusActionableItemsPresenter {

    var sort: GetAssignments.Sort
    let courseID: String
    let env: AppEnvironment
    weak var view: SyllabusActionableItemsViewProtocol?
    var assignmentUpdateCount = 0
    var calendarEventUpdateCount = 0
    var assignmentViewModels: [SyllabusActionableItemsViewController.ViewModel] = []
    var calendarViewModels: [SyllabusActionableItemsViewController.ViewModel] = []

    lazy var course: Store<GetCourseUseCase> = {
        let useCase = GetCourseUseCase(courseID: courseID)
        return self.env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    private lazy var assignments: Store<GetAssignments> = {
        let useCase = GetAssignments(courseID: self.courseID, sort: sort)
        return self.env.subscribe(useCase) { [weak self] in
            self?.updateAssignments()
        }
    }()

    private lazy var calendarEvents: Store<GetCalendarEvents> = {
        let useCase = GetCalendarEvents(context: ContextModel(.course, id: courseID))
        return self.env.subscribe(useCase) { [weak self] in
            self?.updateCalendarEvents()
        }
    }()

    init(env: AppEnvironment = .shared, view: SyllabusActionableItemsViewProtocol, courseID: String, sort: GetAssignments.Sort = .position) {
        self.courseID = courseID
        self.env = env
        self.view = view
        self.sort = sort
    }

    func viewIsReady() {
        assignments.exhaust(while: { _ in true })
        calendarEvents.exhaust(while: { _ in true })
        course.refresh()
        update()
    }

    func update() {
        var models = assignmentViewModels + calendarViewModels
        models.sort { (a, b) -> Bool in
            return (a.dueDate ?? .distantFuture).compare(b.dueDate ?? .distantFuture) == .orderedAscending
        }
        view?.update(models: models)
        loadColor()
    }

    func updateAssignments() {
        assignmentUpdateCount += 1
        assignmentViewModels = assignments.map {
            SyllabusActionableItemsViewController.ViewModel(id: $0.id, htmlUrl: $0.htmlURL, title: $0.name, dueDate: $0.dueAt, formattedDate: formattedDueDate($0.dueAt), image: icon(for: $0))
        }
        signalUpdate()
    }

    func updateCalendarEvents() {
        calendarEventUpdateCount += 1
        calendarViewModels = calendarEvents.map {
            SyllabusActionableItemsViewController.ViewModel(id: $0.id, htmlUrl: URL(string: "calendar_events/\($0.id)")!,
                                                           title: $0.title, dueDate: $0.endAt, formattedDate: formattedDueDate($0.endAt), image: .icon(.calendarMonth, .line))
        }
        signalUpdate()
    }

    func signalUpdate() {
        let updateThreshold = 2
        if(assignmentUpdateCount >= updateThreshold && calendarEventUpdateCount >= updateThreshold) {
            update()
        }
    }

    func loadColor() {
        guard let course = course.first else { return }
        view?.updateNavBar(subtitle: course.name, color: course.color)
    }

    func select(_ htmlURL: URL, from: UIViewController) {
        env.router.route(to: htmlURL, from: from, options: nil)
    }

    func formattedDueDate(_ date: Date?) -> String {
        var result = NSLocalizedString("No Due Date", comment: "")
        if let date = date {
            result = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
        }
        return result
    }

    func icon(for: Assignment) -> UIImage? {
        let assignment = `for`
        var image: UIImage? = .icon(.assignment, .line)
        if assignment.quizID != nil {
            image = .icon(.quiz, .line)
        } else if assignment.discussionTopic != nil {
            image = .icon(.discussion, .line)
        }
        return image
    }
}
