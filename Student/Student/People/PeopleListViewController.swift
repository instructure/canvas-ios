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

import UIKit
import Core

protocol PeopleListViewProtocol: ColoredNavViewProtocol {
    func update()
}

class PeopleListViewController: UIViewController, PeopleListViewProtocol {
    var color: UIColor?

    var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    var presenter: PeopleListPresenter?

    @IBOutlet weak var tableView: UITableView!

    static func create(env: AppEnvironment = .shared, context: Context) -> PeopleListViewController {
        let vc = loadFromStoryboard()
        vc.presenter = PeopleListPresenter(env: env, viewController: vc, context: context)
        return vc
    }

    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self

        setupTitleViewInNavbar(title: NSLocalizedString("People", bundle: .student, comment: ""))

        presenter?.viewIsReady()
    }

    func update() {
        tableView.reloadData()
    }
}

extension PeopleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let recipient = presenter?.searchRecipients[indexPath.row] else {
            return
        }
        presenter?.select(recipient: recipient, from: self)
    }
}

extension PeopleListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.searchRecipients.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(PeopleListCell.self, for: indexPath)
        cell.update(searchRecipient: presenter?.searchRecipients[indexPath.row])
        return cell
    }
}
