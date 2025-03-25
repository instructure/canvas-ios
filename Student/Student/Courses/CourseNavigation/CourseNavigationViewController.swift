//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import UIKit
import Core

protocol CourseNavigationViewProtocol: ErrorViewController {
    func updateNavBar(title: String?, backgroundColor: UIColor?)
    func update()
}

protocol CourseNavigationViewModel: TabViewable {
    var label: String { get }
    var htmlURL: URL? { get }
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
        color = backgroundColor?.ensureContrast(against: .textLightest.variantForLightMode)
    }
}

extension CourseNavigationViewController {

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.tabs.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .backgroundLightest
        cell.textLabel?.text = presenter?.tabs[indexPath.row]?.label
        cell.imageView?.image = presenter?.tabs[indexPath.row]?.icon
        cell.imageView?.tintColor = color
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < presenter?.tabs.count ?? 0,
            let tab = presenter?.tabs[indexPath.row],
            let htmlURL = tab.htmlURL else { return }
        router.route(to: htmlURL, from: self)
    }
}
