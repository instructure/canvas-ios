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

public class ExperimentalFeaturesViewController: UITableViewController {
    public var readOnly: Bool = false
    public var afterToggle: (() -> Void)?

    override public func viewDidLoad() {
        super.viewDidLoad()

        let barButtonItem = UIBarButtonItem(title: "Toggle All", style: .plain, target: self, action: #selector(toggleAll(_:)))
        if !readOnly {
            navigationItem.rightBarButtonItem = barButtonItem
        }

        title = String(localized: "Experimental Features", bundle: .core)
        tableView?.registerCell(SwitchTableViewCell.self)
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ExperimentalFeature.allCases.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feature = ExperimentalFeature.allCases[indexPath.row]
        let cell = tableView.dequeue(for: indexPath) as SwitchTableViewCell
        cell.textLabel?.text = feature.rawValue
        cell.toggle.tag = indexPath.row
        cell.toggle.isOn = feature.isEnabled
        cell.toggle.addTarget(self, action: #selector(toggleFeature(_:)), for: .valueChanged)
        cell.toggle.isEnabled = !readOnly
        cell.toggle.accessibilityLabel = feature.rawValue
        cell.isUserInteractionEnabled = !readOnly
        return cell
    }

    @objc
    func toggleFeature(_ sender: CoreSwitch) {
        ExperimentalFeature.allCases[sender.tag].isEnabled = sender.isOn
        afterToggle?()
    }

    @objc
    func toggleAll(_ sender: UIBarButtonItem) {
        ExperimentalFeature.allEnabled = !ExperimentalFeature.allEnabled
        tableView.reloadData()
        afterToggle?()
    }
}
