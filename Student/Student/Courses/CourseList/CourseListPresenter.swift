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

struct CourseListViewModel {
    struct Course {
        let courseID: String
        let title: String
        let abbreviation: String
        let color: UIColor
        let imageUrl: URL?
    }

    var current: [Course]
    var past: [Course]
}

class CourseListPresenter {
    weak var view: CourseListViewProtocol?
    let environment: AppEnvironment
    let queue: OperationQueue
    let router: RouterProtocol
    var groupOperation: OperationSet?

    let coursesFetch: FetchedResultsController<Course>

    init(env: AppEnvironment = .shared, view: CourseListViewProtocol?) {
        self.environment = env
        self.queue = env.queue
        self.router = env.router
        self.view = view
        self.coursesFetch = env.subscribe(Course.self, .all)
        self.coursesFetch.delegate = self
    }

    func courseWasSelected(_ courseID: String, from controller: UIViewController) {
        router.route(to: .course(courseID), from: controller, options: nil)
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

    func refreshRequested() {
        loadDataFromServer()
    }

    func loadData() {
        coursesFetch.performFetch()

        // Get from cache to start
        fetchData()

        // Get from server
        loadDataFromServer()
    }

    func loadDataFromServer() {
        if let gop = self.groupOperation, !gop.isFinished {
            return
        }

        let getCourses = GetCourses(env: environment)
        let getColors = GetCustomColors(env: environment)
        getColors.addDependency(getCourses)

        let groupOperation = OperationSet(operations: [getCourses, getColors])
        groupOperation.completionBlock = { [weak self] in
            // Load data from data store once our big group finishes
            DispatchQueue.main.async {
                self?.fetchData()
            }
        }
        self.groupOperation = groupOperation

        queue.addOperationWithErrorHandling(groupOperation, sendErrorsTo: view)
    }

    func fetchData() {
        let courses = coursesFetch.fetchedObjects ?? []
        let vm = transformToViewModel(current: courses, past: courses)

        view?.update(courses: vm)
    }

    func transformToViewModel(current: [Course], past: [Course]) -> CourseListViewModel {
        let vms = current.compactMap { (course: Course) -> CourseListViewModel.Course? in
            guard let name = course.name, !course.id.isEmpty else {
                return nil
            }

            return CourseListViewModel.Course(courseID: course.id, title: name, abbreviation: course.courseCode ?? "", color: course.color, imageUrl: course.imageDownloadURL)
        }

        let vm = CourseListViewModel(current: vms, past: vms)
        return vm
    }
}

extension CourseListPresenter: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        guard let gop = groupOperation else {
            return
        }

        if gop.isFinished {
            fetchData()
        }
    }
}
