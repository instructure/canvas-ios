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
    func update(_ viewModel: PostGradesPresenter.ViewModel)
    func didUpdatePostGradesPolicy()
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
            if error != nil {
                self?.view?.showError(message: NSLocalizedString("An error ocurred", comment: ""))
            } else if let data = data {
                let model = ViewModel(data: data)
                DispatchQueue.main.async { self?.view?.update(model) }
            }
        })
    }

    func updatePostGradesPolicy(postPolicy: PostGradePolicy, sectionIDs: [String]) {
        let req = PostAssignmentGradesPostPolicyRequest(assignmentID: assignmentID, postPolicy: postPolicy, sections: sectionIDs)
        env.api.makeRequest(req, callback: { [weak self] _, _, error in
            if error != nil {
                self?.view?.showError(message: NSLocalizedString("An error ocurred", comment: ""))
            } else {
                self?.view?.didUpdatePostGradesPolicy()
            }
        })
    }

    struct ViewModel {
        var sections: [APIPostPolicyInfo.SectionNode] = []
        var gradesCurrentlyHidden: Int = 0

        init(data: APIPostPolicyInfo) {
            self.sections = data.sections
            let hidden = data.submissions.filter { $0.isHidden }
            gradesCurrentlyHidden = hidden.count
        }
    }
}
