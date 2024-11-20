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

protocol ArcSubmissionView: ErrorViewController {
    func load(_ url: URL)
}

class ArcSubmissionPresenter {
    let env: AppEnvironment
    weak var view: ArcSubmissionView?
    let destination: SubmissionDestination
    let arcID: String

    init(environment: AppEnvironment = .shared, view: ArcSubmissionView, destination: SubmissionDestination, arcID: String) {
        self.env = environment
        self.view = view
        self.destination = destination
        self.arcID = arcID
    }

    func viewIsReady() {
        let context = destination.context
        let url = env.api.baseURL.appendingPathComponent("\(context.pathComponent)/external_tools/\(arcID)/resource_selection")
        view?.load(url)
    }

    func submit(form: Any, callback: @escaping (Error?) -> Void) {
        guard
            let form = form as? [String: Any],
            let itemsRaw = form["content_items"] as? String,
            let itemsData = itemsRaw.data(using: .utf8),
            let items = try? JSONSerialization.jsonObject(with: itemsData, options: []) as? [String: Any],
            let graph = items["@graph"] as? [[String: Any]],
            let urlRaw = graph.first?["url"] as? String,
            let url = URL(string: urlRaw)
        else {
            return
        }
        submit(url: url, callback: callback)
    }

    func submit(url: URL, callback: @escaping (Error?) -> Void) {
        CreateSubmission(
            destination: destination,
            submissionType: .basic_lti_launch,
            url: url
        ).fetch(environment: env) { _, _, error in
            callback(error)
        }
    }
}
