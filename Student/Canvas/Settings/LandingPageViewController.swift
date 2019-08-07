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

open class LandingPageViewController: UITableViewController {
    typealias LandingPage = UserPreferences.LandingPage
    private var userID: String
    private var selected: LandingPage

    @objc init (currentUserID: String) {
        userID = currentUserID
        selected = UserPreferences.landingPage(currentUserID)
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)

    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LandingPage.allCases.count
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = LandingPage.allCases[indexPath.row]
        let cell = UITableViewCell()
        cell.accessibilityIdentifier = "LandingPageCell.\(indexPath.row)"
        cell.textLabel?.text = item.description
        if selected == item {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            cell.setSelected(true, animated: false)
        }
        return cell
    }

    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Choose Landing Page", comment: "Button to select a landing page")
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = LandingPage.allCases[indexPath.row]
        UserPreferences.setLandingPage(userID, page: selected)
        tableView.reloadData()
    }

    open override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
    }
}
