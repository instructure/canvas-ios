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
    func didHideGrades()
    func didPostGrades()
}

extension PostGradesViewProtocol {
    func didPostGrades() {}
    func didHideGrades() {}
}

class PostGradesPresenter {
    weak var view: PostGradesViewProtocol?
    let env: AppEnvironment
    let courseID: String
    let assignmentID: String

    init(courseID: String, assignmentID: String, view: PostGradesViewProtocol, env: AppEnvironment = .shared) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        refresh()
    }

    func refresh() {
        let req = GetAssignmentPostPolicyInfoRequest(courseID: courseID, assignmentID: assignmentID)
        env.api.makeRequest(req, callback: { [weak self] data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.view?.showError(APIError.from(data: nil, response: nil, error: error))
                } else if let data = data {
                    self?.view?.update(data)
                }
            }
        })
    }

    func postGrades(postPolicy: PostGradePolicy, sectionIDs: [String]) {
        let req = PostAssignmentGradesPostPolicyRequest(assignmentID: assignmentID, postPolicy: postPolicy, sections: sectionIDs)
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
        let req = HideAssignmentGradesPostPolicyRequest(assignmentID: assignmentID, sections: sectionIDs)
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
