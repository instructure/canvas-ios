//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import Core
import Combine

protocol PostGradesViewProtocol: ErrorViewController {
    func update(_ viewModel: APIPostPolicy)
    func nextPageLoaded(_ viewModel: APIPostPolicy)
    func updateCourseColor(_ color: UIColor)
    func didHideGrades()
    func didPostGrades()
    func showAllPostedView()
    func showAllHiddenView()
}

extension PostGradesViewProtocol {
    func didPostGrades() {}
    func didHideGrades() {}
    func showAllPostedView() {}
    func showAllHiddenView() {}
}

class PostGradesPresenter {
    weak var view: PostGradesViewProtocol?
    let env: AppEnvironment
    let courseID: String
    let assignmentID: String

    private var subscriptions = Set<AnyCancellable>()

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateColor()
    }

    lazy var courses = env.subscribe(GetCourse(courseID: courseID), { [weak self] in
        self?.updateColor()
    })

    init(courseID: String, assignmentID: String, view: PostGradesViewProtocol, env: AppEnvironment = .shared) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        colors.refresh()
        refresh()
    }

    func updateColor() {
        if colors.pending == false {
            if let course = courses.first {
                view?.updateCourseColor(course.color)
            }
        }
    }

    func refresh() {
        let courseSections = env.api
            .makeRequest(GetPostPolicyCourseSectionsRequest(courseID: courseID))
            .map({ $0.body })
        let assignmentSubmissions = env.api
            .makeRequest(GetPostPolicyAssignmentSubmissionsRequest(assignmentID: assignmentID))
            .map({ $0.body })

        courseSections
            .combineLatest(assignmentSubmissions)
            .map { (sections, submissions) in
                return APIPostPolicy(assignment: submissions, course: sections)
            }
            .mapError({ APIError.from(data: nil, response: nil, error: $0) })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.view?.showError(error)
                }
            } receiveValue: { [weak self] policy in
                self?.updateView(data: policy)
            }
            .store(in: &subscriptions)
    }

    func fetchNextPage(to data: APIPostPolicy) {
        guard let course = data.course,
              let pageInfo = course.pageInfo
        else { return }

        env.api
            .makeRequest(
                GetPostPolicyCourseSectionsRequest(courseID: courseID, cursor: pageInfo.endCursor)
            )
            .map { result in
                var courseCopy = course
                courseCopy.appendSections(result.body)

                return APIPostPolicy(
                    assignment: data.assignment,
                    course: courseCopy
                )
            }
            .mapError({ APIError.from(data: nil, response: nil, error: $0) })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.view?.showError(error)
                }
            } receiveValue: { [weak self] policy in
                self?.view?.nextPageLoaded(policy)
            }
            .store(in: &subscriptions)
    }

    func updateView(data: APIPostPolicy) {
        if data.submissionsCount == data.submissions?.hiddenCount {
            view?.showAllHiddenView()
        } else if data.submissionsCount == data.submissions?.postedCount {
            view?.showAllPostedView()
        }

        view?.update(data)
    }

    func postGrades(postPolicy: PostGradePolicy, sectionIDs: [String]) {
        let req: PostAssignmentGradesPostPolicyRequest
        if sectionIDs.isEmpty {
            req = PostAssignmentGradesPostPolicyRequest(assignmentID: assignmentID, postPolicy: postPolicy)
        } else {
            req = PostAssignmentGradesForSectionsPostPolicyRequest(assignmentID: assignmentID, postPolicy: postPolicy, sections: sectionIDs)
        }
        env.api.makeRequest(req, callback: { [weak self] _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.view?.showError(APIError.from(data: nil, response: nil, error: error))
                } else {
                    self?.view?.didPostGrades()
                }
            }
        })
    }

    func hideGrades(sectionIDs: [String]) {
        let req: HideAssignmentGradesPostPolicyRequest
        if sectionIDs.isEmpty {
            req = HideAssignmentGradesPostPolicyRequest(assignmentID: assignmentID)
        } else {
            req = HideAssignmentGradesForSectionsPostPolicyRequest(assignmentID: assignmentID, sections: sectionIDs)
        }
        env.api.makeRequest(req, callback: { [weak self] _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.view?.showError(APIError.from(data: nil, response: nil, error: error))
                } else {
                    self?.view?.didHideGrades()
                }
            }
        })
    }
}
