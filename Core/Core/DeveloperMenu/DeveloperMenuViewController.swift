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

public class DeveloperMenuViewController: UIViewController {

    enum MenuOptions: String, CaseIterable {
        case crash
        case clearStorage
//        case logs

        func title() -> String {
            switch self {
            case .crash:
                return "Force Crash"
            case .clearStorage:
                return "Clear local cache"
//            case .logs:
//                return "Logs"
            }
        }
    }

    @IBOutlet var routeTextField: UITextField?
    @IBOutlet var routeMethod: UISegmentedControl?
    @IBOutlet var tableView: UITableView?

    var env: AppEnvironment?

    public static func create(env: AppEnvironment = .shared) -> DeveloperMenuViewController {
        let controller = self.loadFromStoryboard()
        controller.env = env
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "Developer Menu"
        addDismissBarButton(.done, side: .right)

        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView?.delegate = self
        tableView?.dataSource = self

        routeTextField?.addTarget(self, action: #selector(enterPressed), for: .editingDidEndOnExit)
    }

    @objc func enterPressed() {
        guard let route = routeTextField?.text else {
            return
        }
        showRoute(route)
        routeTextField?.resignFirstResponder()
    }

    func showRoute(_ route: String) {
        guard let routeMethod = routeMethod else { return }
        switch routeMethod.selectedSegmentIndex {
        case 0:
            env?.router.route(to: route, from: self, options: [.modal, .embedInNav])
        default:
            env?.router.route(to: route, from: self)
        }
    }

//    func shareLogs() {
//        guard let url: URL = FileLogDestination.defaultFileLogUrl else { return }
//        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//        activityViewController.excludedActivityTypes = [.postToTwitter, .postToFacebook]
//        self.present(activityViewController, animated: true, completion: nil)
//    }
}

extension DeveloperMenuViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = MenuOptions.allCases[indexPath.row].title()
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch MenuOptions.allCases[indexPath.row] {
        case .crash:
            fatalError("Forced a crash")
        case .clearStorage:
            UserDefaults.standard.removePersistentDomain(forName: Bundle.parentBundleID)
            UserDefaults.standard.synchronize()
//        case .logs:
//            shareLogs()
        }
    }
}
