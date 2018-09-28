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

protocol GroupNavigationViewProtocol: ErrorViewController {
    func updateNavBar(title: String, backgroundColor: UIColor)
    func showTabs(_ tabs: [Tab])
}

class GroupNavigationTableViewController: UITableViewController {
    var presenter: GroupNavigationPresenter!
    var tabs: [Tab]?

    convenience init(env: AppEnvironment = .shared, groupID: String) {
        self.init(nibName: nil, bundle: nil)
        presenter = GroupNavigationPresenter(view: self, groupID: groupID)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        presenter.loadTabs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.pageViewStarted()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.pageViewEnded()
    }

    func updateNavBar(title: String, backgroundColor: UIColor) {
        navigationItem.title = title
        navigationController?.navigationBar.tintColor = .named(.white)
        navigationController?.navigationBar.barTintColor = backgroundColor.ensureContrast(against: .named(.white))
        navigationController?.navigationBar.barStyle = .black
    }

    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension GroupNavigationTableViewController: GroupNavigationViewProtocol {
    func showError(_ error: Error) {
        print(error)
    }

    func showTabs(_ tabs: [Tab]) {
        self.tabs = tabs
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
        return cell
    }
}
