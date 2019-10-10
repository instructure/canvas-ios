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

import Foundation

public class AccountListViewController: UIViewController, AccountListView {
    var presenter: AccountListPresenter?

    let tableView = UITableView(frame: .zero, style: .plain)

    public static func create() -> AccountListViewController {
        let controller = AccountListViewController()
        let presenter = AccountListPresenter()
        controller.presenter = presenter
        presenter.view = controller
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Accounts I Manage", comment: "")
        tableView.registerCell(UITableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        tableView.pin(inside: view)
        presenter?.viewIsReady()
    }

    public func reload() {
        tableView.reloadData()
    }
}

extension AccountListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.accounts.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(for: indexPath) as UITableViewCell
        cell.textLabel?.text = presenter?.accounts[indexPath]?.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let account = presenter?.accounts[indexPath] else { return }
        presenter?.show(account, from: self)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottomReached() {
            presenter?.accounts.getNextPage()
        }
    }
}
