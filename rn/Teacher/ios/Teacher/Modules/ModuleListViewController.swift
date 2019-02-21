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

protocol ModuleListViewProtocol: ErrorViewController, ColoredNavViewProtocol {
    func reloadModules()
    func reloadCourse()
}

class ModuleListViewController: UIViewController, ModuleListViewProtocol {
    @IBOutlet weak var tableView: UITableView!

    var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    var presenter: ModuleListPresenter?
    var color: UIColor?

    static func create(courseID: String) -> ModuleListViewController {
        let view = Bundle.loadController(self)
        let presenter = ModuleListPresenter(env: .shared, view: view, courseID: courseID)
        view.presenter = presenter
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitleViewInNavbar(title: NSLocalizedString("Modules", bundle: .teacher, comment: ""))

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        presenter?.viewIsReady()
    }

    func reloadModules() {
        tableView.reloadData()
    }

    func reloadCourse() {
        updateNavBar(subtitle: presenter?.course?.name, color: presenter?.course?.color)
    }
}

extension ModuleListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter?.modules.numberOfSections ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.modules.numberOfObjects(inSection: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(ModuleListCell.self, for: indexPath)
        cell.module = presenter?.modules[indexPath]
        return cell
    }
}

extension ModuleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: route to module details
    }
}
