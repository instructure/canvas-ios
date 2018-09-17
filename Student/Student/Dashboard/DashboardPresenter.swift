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

import UIKit
import Core

struct DashboardViewModel {
    struct Course {
        let courseID: String
        let title: String
        let abbreviation: String
        let color: UIColor
        let imageUrl: URL?
    }

    struct Group {
        let groupID: String
        let groupName: String
        let courseName: String?
        let term: String?
        let color: UIColor?
    }

    var navBackgroundColor: UIColor
    var navLogoUrl: URL
    var favorites: [Course]
    var groups: [Group]
}

protocol DashboardPresenterProtocol {
    func viewIsReady()
    func pageViewStarted()
    func pageViewEnded()
    func loadData()
    func refreshRequested()
    func courseWasSelected(_ courseID: String)
    func courseOptionsWasSelected(_ courseID: String)
    func groupWasSelected(_ groupID: String)
    func editButtonWasTapped()
    func seeAllWasTapped()
}

class DashboardPresenter: DashboardPresenterProtocol {
    weak var view: (DashboardViewProtocol & ErrorViewController)?
    let api: API
    let database: Persistence
    let router: RouterProtocol
    var groupOperation: OperationSet?

    lazy var coursesFetch: FetchedResultsController<Course> = {
        let predicate = NSPredicate(format: "isFavorite == YES")
        let sort = SortDescriptor(key: "name", ascending: true)
        let fetcher: FetchedResultsController<Course> = database.fetchedResultsController(predicate: predicate, sortDescriptors: [sort], sectionNameKeyPath: nil)
        fetcher.delegate = self
        return fetcher
    }()

    lazy var groupsFetch: FetchedResultsController<Group> = {
        let predicate = NSPredicate(format: "concluded == NO")
        let sort = SortDescriptor(key: "name", ascending: true)
        let fetcher: FetchedResultsController<Group> = database.fetchedResultsController(predicate: predicate, sortDescriptors: [sort], sectionNameKeyPath: nil)
        fetcher.delegate = self
        return fetcher
    }()

    init(env: AppEnvironment, view: (DashboardViewProtocol & ErrorViewController)?) {
        self.api = env.api
        self.database = env.database
        self.router = env.router
        self.view = view
    }

    func courseWasSelected(_ courseID: String) {
        // route to details screen
    }

    func editButtonWasTapped() {
        // route to edit screen
    }

    func viewIsReady() {
        loadData()
    }

    func pageViewStarted() {
        // log page view
    }

    func pageViewEnded() {
        // log page view
    }

    func courseOptionsWasSelected(_ courseID: String) {
        // route/modal
    }

    func groupWasSelected(_ groupID: String) {
        // route
    }

    func seeAllWasTapped() {
        // route
        if let vc = view as? UIViewController {
            router.route(to: .courses, from: vc)
        }
    }

    func refreshRequested() {
        loadDataFromServer(force: true)
    }

    func loadData() {
        do {
            try coursesFetch.performFetch()
            try groupsFetch.performFetch()
        } catch {
            view?.showError(error)
        }

        // Load data from cache, if any
        fetchData()

        // Make requests for updated data
        loadDataFromServer()
    }

    func loadDataFromServer(force: Bool = false) {
        if let gop = self.groupOperation, !gop.isFinished {
            return
        }

        let getColors = GetCustomColors(api: api, database: database)
        let getCourses = GetCourses(api: api, database: database, force: force)
        let getGroups = GetUserGroups(api: api, database: database)

        let group = OperationSet(operations: [getCourses, getGroups])
        getColors.addDependency(group)

        let groupOperation = OperationSet(operations: [group, getColors])
        groupOperation.completionBlock = { [weak self] in
            // Load data from data store once our big group finishes
            DispatchQueue.main.async { [weak self] in
                do {
                    try self?.coursesFetch.performFetch()
                    try self?.groupsFetch.performFetch()
                } catch {
                    self?.view?.showError(error)
                }
                self?.fetchData()
            }
        }
        self.groupOperation = groupOperation

        queue.addGroupOperationWithErrorHandling(groupOperation, sendErrorsTo: view)
    }

    func fetchData() {
        let courses = coursesFetch.fetchedObjects ?? []
        let groups = groupsFetch.fetchedObjects ?? []

        let vm = transformToViewModel(courses: courses, groups: groups)
        view?.updateDisplay(vm)
    }

    func transformToViewModel(courses: [Course], groups: [Group]) -> DashboardViewModel {
        let cs = courses.compactMap { (course: Course) -> DashboardViewModel.Course? in
            guard let name = course.name, !course.id.isEmpty else {
                return nil
            }

            var imageUrl: URL?
            if let urlString = course.imageDownloadUrl {
                imageUrl = URL(string: urlString)
            }

            return DashboardViewModel.Course(courseID: course.id, title: name, abbreviation: course.courseCode ?? "", color: UIColor(hexString: course.color) ?? .gray, imageUrl: imageUrl)
        }

        let gs = groups.compactMap { (group: Group) -> DashboardViewModel.Group? in
            if group.name.isEmpty || group.id.isEmpty {
                return nil
            }
            return DashboardViewModel.Group(groupID: group.id, groupName: group.name, courseName: nil, term: nil, color: UIColor(hexString: group.color) ?? .blue)
        }

        let navBackgroundColor: UIColor = .black
        let logo = URL(string: "https://emoji.slack-edge.com/T028ZAGUD/laugh/2d2ad81e3d71f12e.gif")!

        return DashboardViewModel(navBackgroundColor: navBackgroundColor, navLogoUrl: logo, favorites: cs, groups: gs)
    }
}

extension DashboardPresenter: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        guard let gop = groupOperation else {
            return
        }

        if gop.isFinished {
            fetchData()
        }
    }
}
