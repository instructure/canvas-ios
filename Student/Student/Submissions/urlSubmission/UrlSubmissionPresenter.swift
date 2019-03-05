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

protocol UrlSubmissionViewProtocol: ErrorViewController {
    func loadUrl(url: URL)
    func dismiss()
}

class UrlSubmissionPresenter {
    weak var view: UrlSubmissionViewProtocol?
    let courseID: String
    let assignmentID: String
    let userID: String
    let env: AppEnvironment
    var store: Store<CreateSubmission>?

    init(view: UrlSubmissionViewProtocol?, courseID: String, assignmentID: String, userID: String, env: AppEnvironment = .shared) {
        self.view = view
        self.env = env
        self.assignmentID = assignmentID
        self.courseID = courseID
        self.userID = userID
    }

    func scrubUrl(text: String?) -> URL? {
        guard var text = text, URL(string: text) != nil else { return nil }

        if !text.hasPrefix("http") {
            text = "http://\(text)"
        }

        let components = URLComponents(string: text)
        return components?.url
    }

    func scrubAndLoadUrl(text: String?) {
        if let url = scrubUrl(text: text) {
            view?.loadUrl(url: url)
        }
    }

    func submit(_ text: String?) {
        if let url = scrubUrl(text: text) {
            let useCase = CreateSubmission(context: ContextModel(.course, id: courseID), assignmentID: assignmentID, userID: userID, submissionType: .online_url, url: url)
            store = env.subscribe(useCase) { [weak self] in
                if let error = self?.store?.error {
                    self?.view?.showError(error)
                } else {
                    self?.view?.dismiss()
                }
            }
            store?.refresh()
        } else {
            let error = NSError.instructureError(NSLocalizedString("Invalid url", comment: ""))
            view?.showError(error)
        }
    }
}
