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
    func updateNavBar(title: String?, backgroundColor: UIColor?)
    func update()
}

protocol CourseNavigationViewModel: TabViewable {
    var label: String { get }
    var htmlURL: URL { get }
}

class CourseNavigationViewController: UITableViewController {
    var presenter: CourseNavigationPresenter!
    var color: UIColor?

    convenience init(env: AppEnvironment = .shared, courseID: String) {
        self.init(nibName: nil, bundle: nil)
        presenter = CourseNavigationPresenter(courseID: courseID, view: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        presenter.viewIsReady()
    }

    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension CourseNavigationViewController: CourseNavigationViewProtocol {
    func showError(_ error: Error) {
        print(error)
    }

    func update() {
        tableView.reloadData()
    }

    func updateNavBar(title: String?, backgroundColor: UIColor?) {
        navigationItem.title = title
        navigationController?.navigationBar.useContextColor(backgroundColor)
        color = backgroundColor?.ensureContrast(against: .named(.white))
    }
}

extension CourseNavigationViewController {

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.tabs.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = presenter?.tabs[indexPath.row]?.label
        cell.imageView?.image = presenter?.tabs[indexPath.row]?.icon
        cell.imageView?.tintColor = color
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < presenter?.tabs.count ?? 0, let tab = presenter?.tabs[indexPath.row] else { return }
        router.route(to: tab.htmlURL, from: self)
    }
}
