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

import Foundation

protocol SyllabusActionableItemsViewProtocol: ErrorViewController {
    func update(models: [SyllabusActionableItemsViewController.ViewModel])
    func updateColor(_ color: UIColor?)
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
    var context: Context { ContextModel(.course, id: courseID) }

    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }

    lazy var color = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    public lazy var assignments = env.subscribe(GetAssignments(courseID: self.courseID, sort: sort, cacheKey: "syllabus")) { [weak self] in
        self?.updateAssignments()
    }

    public lazy var calendarEvents = env.subscribe(GetCalendarEvents(context: ContextModel(.course, id: courseID))) { [weak self] in
        self?.updateCalendarEvents()
    }

    init(env: AppEnvironment = .shared, view: SyllabusActionableItemsViewProtocol, courseID: String, sort: GetAssignments.Sort = .dueAt) {
        self.courseID = courseID
        self.env = env
        self.view = view
        self.sort = sort
    }

    func viewIsReady() {
        assignments.exhaust(while: { _ in true })
        calendarEvents.exhaust(while: { _ in true })
        course.refresh()
        color.refresh()
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
            SyllabusActionableItemsViewController.ViewModel(id: $0.id, htmlUrl: $0.htmlURL, title: $0.name, dueDate: $0.dueAt, formattedDate: formattedDueDate($0.dueAt), image: $0.icon)
        }
        signalUpdate()
    }

    func updateCalendarEvents() {
        calendarEventUpdateCount += 1
        calendarViewModels = calendarEvents.map {
            SyllabusActionableItemsViewController.ViewModel(id: $0.id, htmlUrl: $0.routingURL,
                                                           title: $0.title, dueDate: $0.endAt, formattedDate: formattedDueDate($0.startAt), image: .icon(.calendarMonth, .line))
        }
        signalUpdate()
    }

    func signalUpdate() {
        let updateThreshold = 2
        if assignmentUpdateCount >= updateThreshold && calendarEventUpdateCount >= updateThreshold {
            update()
        }
    }

    func loadColor() {
        guard let course = course.first else { return }
        view?.updateColor(course.color)
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
}
