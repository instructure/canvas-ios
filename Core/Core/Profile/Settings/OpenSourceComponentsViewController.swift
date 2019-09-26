//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

class OpenSourceComponentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let components = [
        (name: "AFNetworking", url: "https://github.com/AFNetworking/AFNetworking"),
        (name: "Cartography", url: "https://github.com/robb/Cartography"),
        (name: "Eureka", url: "https://github.com/xmartlabs/Eureka"),
        (name: "libextobjc", url: "https://github.com/jspahrsummers/libextobjc"),
        (name: "Mantle", url: "https://github.com/Mantle/Mantle"),
        (name: "Marshal", url: "https://github.com/utahiosmac/Marshal"),
        (name: "ReactiveCocoa", url: "https://github.com/ReactiveCocoa/ReactiveCocoa"),
        (name: "React Native", url: "https://github.com/facebook/react-native"),
    ]
    let env = AppEnvironment.shared

    let tableView = UITableView()

    static func create() -> OpenSourceComponentsViewController {
        return OpenSourceComponentsViewController()
    }

    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Open Source Components", bundle: .core, comment: "")

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let component = components[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = component.name
        cell.textLabel?.textColor = .named(.textDarkest)
        cell.textLabel?.font = .scaledNamedFont(.semibold16)
        cell.detailTextLabel?.text = component.url
        cell.detailTextLabel?.textColor = .named(.textDark)
        cell.detailTextLabel?.font = .scaledNamedFont(.medium14)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        env.router.route(to: components[indexPath.row].url, from: self, options: nil)
    }
}
