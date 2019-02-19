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

protocol CourseNavigationViewProtocol: ErrorViewController {
    func updateNavBar(title: String, backgroundColor: UIColor)
    func showTabs(_ tabs: [CourseNavigationViewModel])
}

protocol CourseNavigationViewModel: TabViewable {
    var label: String { get }
    var htmlURL: URL { get }
}

class CourseNavigationTableViewController: UITableViewController {
    var presenter: CourseNavigationPresenter!
    var tabs: [CourseNavigationViewModel]?

    convenience init(env: AppEnvironment = .shared, courseID: String) {
        self.init(nibName: nil, bundle: nil)
        presenter = CourseNavigationPresenter(courseID: courseID, view: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        presenter.loadTabs()
    }

    func updateNavBar(title: String, backgroundColor: UIColor) {
        navigationItem.title = title
        navigationController?.navigationBar.useContextColor(backgroundColor)
    }

    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension CourseNavigationTableViewController: CourseNavigationViewProtocol {
    func showError(_ error: Error) {
        print(error)
    }

    func showTabs(_ tabs: [CourseNavigationViewModel]) {
        self.tabs = tabs
        tableView.reloadData()
    }
}

extension CourseNavigationTableViewController {

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabs?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tabs?[indexPath.row].label
        cell.imageView?.image = tabs?[indexPath.row].icon
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < tabs?.count ?? 0, let tab = tabs?[indexPath.row] else { return }
        router.route(to: tab.htmlURL, from: self)
    }
}
