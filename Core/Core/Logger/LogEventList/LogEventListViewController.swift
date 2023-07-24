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

import Foundation
import UIKit

protocol LogEventListViewProtocol: ErrorViewController {
    func reloadData()
}

public class LogEventListViewController: UIViewController, LogEventListViewProtocol {
    @IBOutlet weak var tableView: UITableView!

    var env: AppEnvironment?
    var presenter: LogEventListPresenter?

    public static func create(env: AppEnvironment = .shared) -> LogEventListViewController {
        let controller = loadFromStoryboard()
        controller.env = env
        controller.presenter = LogEventListPresenter(env: env, view: controller)
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .automatic
        addDoneButton()
        presenter?.viewIsReady()
    }

    @IBAction
    func clearAll() {
        presenter?.clearAll()
    }

    @IBAction
    func filter(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)
        for type in LoggableType.allCases {
            let action = UIAlertAction(title: type.rawValue, style: .default) { _ in
                self.presenter?.applyFilter(type)
            }
            alert.addAction(action)
        }
        if presenter?.currentFilter != nil {
            let clear = UIAlertAction(title: "Clear filter", style: .destructive) { _ in
                self.presenter?.applyFilter(nil)
            }
            alert.addAction(clear)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.popoverPresentationController?.barButtonItem = sender
        present(alert, animated: true, completion: nil)
    }

    func reloadData() {
        tableView.reloadData()
    }

    public func showError(_ error: Error) {
        assertionFailure(error.localizedDescription)
    }
}

extension LogEventListViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter?.events.numberOfSections ?? 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.events.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(LoggableCell.self, for: indexPath)
        cell.backgroundColor = .backgroundLightest
        cell.loggable = presenter?.events[indexPath]
        return cell
    }
}
