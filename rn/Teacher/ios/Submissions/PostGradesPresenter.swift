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

protocol PostGradesViewProtocol: ErrorViewController {
    func update(_ viewModel: APIPostPolicyInfo)
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
        let req = GetAssignmentPostPolicyInfoRequest(courseID: courseID, assignmentID: assignmentID)
        env.api.makeRequest(req, callback: { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.view?.showError(APIError.from(data: nil, response: nil, error: error))
                } else if let data = data {
                    self?.updateView(data: data)
                }
            }
        })
    }

    func updateView(data: APIPostPolicyInfo) {
        if data.submissions.count == data.submissions.hiddenCount {
            view?.showAllHiddenView()
        } else if data.submissions.count == data.submissions.postedCount {
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
