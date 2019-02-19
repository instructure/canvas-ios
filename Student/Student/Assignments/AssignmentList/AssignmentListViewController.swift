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

class AssignmentListViewController: UITableViewController {

    var presenter: AssignmentListPresenter?
    var assignments: [Assignment]?
    var color: UIColor?
    var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    convenience init(env: AppEnvironment = .shared, courseID: String) {
        self.init(nibName: nil, bundle: nil)
        presenter = AssignmentListPresenter(view: self, courseID: courseID)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: NSLocalizedString("Assignments", comment: ""))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        presenter?.loadDataFromServer()
        presenter?.loadDataForView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignments?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, for: indexPath)
        cell.textLabel?.text = assignments?[indexPath.row].name
        cell.imageView?.image = .icon(.assignment, .line)
        cell.imageView?.tintColor = color
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let assignment = assignments?[indexPath.row] else { return }
        presenter?.select(assignment, from: self)
    }
}

extension AssignmentListViewController: AssignmentListViewProtocol {
    func update(list: [Assignment]) {
        assignments = list
        tableView.reloadData()
    }
}
