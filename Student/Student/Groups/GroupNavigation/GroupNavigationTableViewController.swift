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

protocol GroupNavigationViewModel: TabViewable {
    var label: String { get }
}

class GroupNavigationTableViewController: UITableViewController {
    var presenter: GroupNavigationPresenter!
    var tabs: [GroupNavigationViewModel]?
    var color: UIColor = .black

    convenience init(env: AppEnvironment = .shared, groupID: String) {
        self.init(nibName: nil, bundle: nil)
        presenter = GroupNavigationPresenter(groupID: groupID, view: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        presenter.loadTabs()
    }

    func updateNavBar(title: String, backgroundColor: UIColor) {
        color = backgroundColor.ensureContrast(against: .named(.white))
        navigationItem.title = title
        navigationController?.navigationBar.useContextColor(backgroundColor)
    }

    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension GroupNavigationTableViewController: GroupNavigationViewProtocol {
    func showError(_ error: Error) {
        print(error)
    }

    func showTabs(_ tabs: [GroupNavigationViewModel], color: UIColor) {
        self.tabs = tabs
        self.color = color
        tableView.reloadData()
    }
}

extension GroupNavigationTableViewController {

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabs?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tabs?[indexPath.row].label
        cell.imageView?.image = tabs?[indexPath.row].icon
        cell.imageView?.tintColor = color
        return cell
    }
}
