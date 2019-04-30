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

struct DebugRoute {
    let path: String
    let options: Router.RouteOptions?

    init(_ path: String, _ options: Router.RouteOptions? = nil) {
        self.path = path
        self.options = options
    }
}

let routes = [
    DebugRoute("/login"),
    DebugRoute("/courses"),
    DebugRoute("/courses/177/assignments/1933"),
    DebugRoute("/courses/167/quizzes"),
    DebugRoute("/courses/162/assignments/1916/fileupload"),
    DebugRoute("courses/162/assignments/1901/submissions/12", [.modal, .embedInNav]),
    DebugRoute("courses/162/assignments/1901/submissions/12/urlsubmission", [.modal, .embedInNav]),
    DebugRoute("/logs", [.modal, .embedInNav]),
]

class RouterViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.title = "Router Debug"

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = routes[indexPath.row].path
        cell.accessibilityIdentifier = routes[indexPath.row].path
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let route = routes[indexPath.row]
        router.route(to: route.path, from: self, options: route.options)
    }
}
