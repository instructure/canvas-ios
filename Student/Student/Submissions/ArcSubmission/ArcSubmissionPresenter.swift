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

private struct FormBody: Codable {
    struct ContentItems: Codable {
        let graph: [Item]

        enum CodingKeys: String, CodingKey {
            case graph = "@graph"
        }
    }

    struct Item: Codable {
        let url: URL
    }

    let contentItems: ContentItems

    enum CodingKeys: String, CodingKey {
        case contentItems = "content_items"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let string = try container.decode(String.self, forKey: .contentItems)
        guard let data = string.data(using: .utf8) else {
            throw NSError.internalError()
        }
        contentItems = try JSONDecoder().decode(ContentItems.self, from: data)
    }
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
        view?.load(url)
    }

    func submit(form: Any, callback: @escaping (Error?) -> Void) {
        do {
            let data = try JSONSerialization.data(withJSONObject: form, options: [])
            let body = try JSONDecoder().decode(FormBody.self, from: data)
            guard let url = body.contentItems.graph.first?.url else {
                callback(NSError.internalError())
                return
            }
            submit(url: url, callback: callback)
        } catch {
            callback(error)
        }
    }

    func submit(url: URL, callback: @escaping (Error?) -> Void) {
        CreateSubmission(
            context: ContextModel(.course, id: courseID),
            assignmentID: assignmentID,
            userID: userID,
            submissionType: .basic_lti_launch,
            url: url
        ).fetch(environment: env) { _, _, error in
            callback(error)
        }
    }
}
