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

import Foundation

protocol LogEventListViewProtocol: ErrorViewController {
    func reloadData()
}

public class LogEventListViewController: UIViewController, LogEventListViewProtocol {
    @IBOutlet weak var tableView: UITableView!

    var env: AppEnvironment?
    var presenter: LogEventListPresenter?

    public static func create(env: AppEnvironment = .shared) -> LogEventListViewController {
        let controller = Bundle.loadController(self)
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
    func filter() {
        let alert = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)
        for type in LoggableType.allCases {
            let action = UIAlertAction(title: type.rawValue, style: .default) { _ in
                self.presenter?.applyFilter(.type(type))
            }
            alert.addAction(action)
        }
        if presenter?.currentFilter != nil {
            let clear = UIAlertAction(title: "Clear filter", style: .destructive) { _ in
                self.presenter?.applyFilter(.all)
            }
            alert.addAction(clear)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
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
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfEvents ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(LoggableCell.self, for: indexPath)
        cell.loggable = presenter?.logEvent(for: indexPath)
        return cell
    }
}
