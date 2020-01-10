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

protocol PeopleListViewProtocol: ColoredNavViewProtocol {
    func update()
}

public class PeopleListViewController: UIViewController, PeopleListViewProtocol {
    public var color: UIColor?

    public var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    var presenter: PeopleListPresenter?

    @IBOutlet weak var tableView: UITableView!

    public static func create(env: AppEnvironment = .shared, context: Context) -> PeopleListViewController {
        let vc = loadFromStoryboard()
        vc.presenter = PeopleListPresenter(env: env, viewController: vc, context: context)
        return vc
    }

    public override func viewDidLoad() {
        view.backgroundColor = .named(.backgroundLightest)
        tableView.delegate = self
        tableView.dataSource = self

        setupTitleViewInNavbar(title: NSLocalizedString("People", bundle: .core, comment: ""))

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()

        presenter?.viewIsReady()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }

    func update() {
        tableView.reloadData()
    }

    @objc func refresh() {
        presenter?.users.refresh(force: true) { [weak self] _ in
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
}

extension PeopleListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = presenter?.users[indexPath.row] else {
            return
        }
        presenter?.select(user: user, from: self)
    }
}

extension PeopleListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.users.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(PeopleListCell.self, for: indexPath)
        cell.update(user: presenter?.users[indexPath.row])
        return cell
    }
}

extension PeopleListViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottomReached() {
            presenter?.users.getNextPage()
        }
    }
}
