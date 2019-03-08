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

class GroupNavigationViewController: UITableViewController {
    var presenter: GroupNavigationPresenter!
    var color: UIColor = .black

    convenience init(env: AppEnvironment = .shared, groupID: String) {
        self.init(nibName: nil, bundle: nil)
        presenter = GroupNavigationPresenter(groupID: groupID, view: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        presenter.viewIsReady()
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

extension GroupNavigationViewController: GroupNavigationViewProtocol {
    func showError(_ error: Error) {
        print(error)
    }

    func update(color: UIColor) {
        self.color = color
        tableView.reloadData()
    }
}

extension GroupNavigationViewController {

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.tabs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = presenter.tabs[indexPath.row]?.label
        cell.imageView?.image = presenter.tabs[indexPath.row]?.icon
        cell.imageView?.tintColor = color
        return cell
    }
}
