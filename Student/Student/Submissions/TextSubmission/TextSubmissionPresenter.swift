//
// Copyright (C) 2019-present Instructure, Inc.
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

protocol TextSubmissionViewProtocol: class {
    func showError(_ error: Error)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

class TextSubmissionPresenter {
    let assignmentID: String
    let courseID: String
    let env: AppEnvironment
    let userID: String
    weak var view: TextSubmissionViewProtocol?

    init(env: AppEnvironment = .shared, view: TextSubmissionViewProtocol, courseID: String, assignmentID: String, userID: String) {
        self.assignmentID = assignmentID
        self.courseID = courseID
        self.env = env
        self.userID = userID
        self.view = view
    }

    func submit(_ text: String) {
        let useCase = CreateSubmission(context: ContextModel(.course, id: courseID), assignmentID: assignmentID, userID: userID, submissionType: .online_text_entry, body: text)
        useCase.fetch(environment: env) { [weak self] (_, _, error) in
            if let error = error {
                self?.view?.showError(error)
            } else {
                self?.view?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
