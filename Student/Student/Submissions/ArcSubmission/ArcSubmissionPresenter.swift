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

protocol ArcSubmissionView: ErrorViewController {
    func load(_ url: URL)
}

class ArcSubmissionPresenter {
    let env: AppEnvironment
    weak var view: ArcSubmissionView?
    let courseID: String
    let assignmentID: String
    let userID: String
    let arcID: String

    init(environment: AppEnvironment = .shared, view: ArcSubmissionView, courseID: String, assignmentID: String, userID: String, arcID: String) {
        self.env = environment
        self.view = view
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.userID = userID
        self.arcID = arcID
    }

    func viewIsReady() {
        let context = ContextModel(.course, id: courseID)
        let url = env.api.baseURL.appendingPathComponent("\(context.pathComponent)/external_tools/\(arcID)/resource_selection")
        env.api.makeRequest(GetWebSessionRequest(to: url)) { [weak self] session, _, error in
            guard let session = session, error == nil else {
                self?.view?.showError(error ?? NSError.internalError())
                return
            }
            self?.view?.load(session.session_url)
        }
    }
}
