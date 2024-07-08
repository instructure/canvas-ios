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

    struct DeveloperUserDefaultKeys {
        static let route = "com.instructure.devMenu.route"
        static let modalSelection = "com.instructure.devMenu.modalSelection"
        static let routeHistory = "com.instructure.devMenu.routeHistory"
    }

    enum Section: Int, CaseIterable {
        case settings
        case routeHistory
    }

    enum SettingsRow: Int, CaseIterable {
        case experimentalFeatures
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
            case .experimentalFeatures:
                return "View experimental features"
            }
        }
    }

    @IBOutlet var routeTextField: UITextField?
    @IBOutlet var routeMethod: UISegmentedControl?
    @IBOutlet var tableView: UITableView?
    var routeHistory: [String] = []

    var env: AppEnvironment?

    public static func create(env: AppEnvironment = .shared) -> DeveloperMenuViewController {
        let controller = self.loadFromStoryboard()
        controller.env = env
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "🛠 Developer Menu"
        addDismissBarButton(.done, side: .right)

        tableView?.register(SwitchTableViewCell.self, forCellReuseIdentifier: String(describing: SwitchTableViewCell.self))
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView?.delegate = self
        tableView?.dataSource = self

        routeTextField?.addTarget(self, action: #selector(enterPressed), for: .editingDidEndOnExit)
        routeTextField?.text = restoreRoute()

        routeMethod?.selectedSegmentIndex = restoreModalSelection()

        routeHistory = DeveloperMenuViewController.restoreRouteHistory()
    }

    @objc func enterPressed() {
        guard let route = routeTextField?.text else {
            return
        }
        storeRouteInDefaults(route)
        storeModalSelection(routeMethod?.selectedSegmentIndex)
        showRoute(route)
        routeTextField?.resignFirstResponder()
    }

    func showRoute(_ route: String) {
        guard let routeMethod = routeMethod else { return }
        switch routeMethod.selectedSegmentIndex {
        case 0:
            env?.router.route(to: route, from: self, options: .modal(embedInNav: true))
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

    func restoreRoute() -> String? {
        return UserDefaults.standard.string(forKey: DeveloperUserDefaultKeys.route)
    }

    func storeRouteInDefaults(_ route: String?) {
        UserDefaults.standard.set(route, forKey: DeveloperUserDefaultKeys.route)
        UserDefaults.standard.synchronize()
    }

    func restoreModalSelection() -> Int {
        return UserDefaults.standard.integer(forKey: DeveloperUserDefaultKeys.modalSelection)
    }

    func storeModalSelection(_ selection: Int?) {
        UserDefaults.standard.set(selection, forKey: DeveloperUserDefaultKeys.modalSelection)
        UserDefaults.standard.synchronize()
    }
}

extension DeveloperMenuViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (routeHistory.count > 0 ? 1 : 0)
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: break
        case 1: return "Route History"
        default: break
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("invalid section") }

        if section == .settings {
            guard let menuItem = SettingsRow(rawValue: indexPath.row) else { fatalError("invalid menu item") }
            let cell = tableView.dequeue(for: indexPath) as UITableViewCell
            cell.textLabel?.text = menuItem.title()
            cell.backgroundColor = .backgroundLightest
            return cell
        } else {
            let cell = tableView.dequeue(for: indexPath)
            cell.textLabel?.text = URL(string: routeHistory[indexPath.row])?.path
            cell.backgroundColor = .backgroundLightest
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { fatalError("invalid section") }
        switch section {
        case .settings: return SettingsRow.allCases.count
        case .routeHistory: return routeHistory.count
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = Section(rawValue: indexPath.section) else { fatalError("invalid section") }
        if section == .settings {
            switch SettingsRow.allCases[indexPath.row] {
            case .crash:
                fatalError("Forced a crash")
            case .clearStorage:
                UserDefaults.standard.removePersistentDomain(forName: Bundle.parentBundleID)
                UserDefaults.standard.synchronize()
                //        case .logs:
            //            shareLogs()
            case .experimentalFeatures:
                env?.router.route(to: "/dev-menu/experimental-features", from: self)
            }
        } else {
            showRoute(routeHistory[indexPath.row])
        }
    }
}

extension DeveloperMenuViewController {

    static func restoreRouteHistory() -> [String] {
        let key = DeveloperMenuViewController.DeveloperUserDefaultKeys.routeHistory
        return UserDefaults.standard.array(forKey: key) as? [String] ?? []
    }

    static func recordRouteInHistory(_ route: String?) {
        guard let url = route else { return }
        let ignore = [
            "/dev-menu",
            "/profile"
        ]

        if ignore.contains(url) { return }

        var all = restoreRouteHistory()
        all.insert(url, at: 0)
        let saveSubset = Array( all.prefix(10) )

        UserDefaults.standard.set(saveSubset, forKey: DeveloperUserDefaultKeys.routeHistory)
        UserDefaults.standard.synchronize()
    }
}
