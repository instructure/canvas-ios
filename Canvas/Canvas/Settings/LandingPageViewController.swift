//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import UIKit

let landingPageOptions: [LandingPageOptions] = [
    .courses,
    .calendar,
    .todo,
    .notifications,
    .messages
]

enum LandingPageOptions: String {
    // The values are the keys stored in NSUserDefaults.
    case courses = "Courses"
    case calendar = "Calendar"
    case todo = "To-Do List"
    case notifications = "Notifications"
    case messages = "Messages"

    var description: String {
        switch self {
        case .courses:
            return NSLocalizedString("Courses", comment: "Courses landing page title")
        case .calendar:
            return NSLocalizedString("Calendar", comment: "Calendar landing page title")
        case .todo:
            return NSLocalizedString("To-Do List", comment: "To-Do List landing page title")
        case .notifications:
            return NSLocalizedString("Notifications", comment: "Notifications tab title")
        case .messages:
            return NSLocalizedString("Messages", comment: "Messages landing page title")
        }
    }
}

open class LandingPageViewController: UITableViewController {
    fileprivate var currentUsersID: String
    fileprivate var currentLandingPageSettingsDictionary: [String : String]
    fileprivate var currentUserLandingPageSettings: LandingPageOptions
    
    // ---------------------------------------------
    // MARK: - Inits
    // ---------------------------------------------
    
    init (currentUserID: String) {
        currentUsersID = currentUserID
        currentLandingPageSettingsDictionary = [:]
        currentUserLandingPageSettings = LandingPageOptions.courses
        if let settingsDictionary = UserDefaults.standard.object(forKey: "landingPageSettings") as? [String : String] {
            currentLandingPageSettingsDictionary = settingsDictionary
            for (userID, landingPageSetting) in currentLandingPageSettingsDictionary {
                if userID == currentUsersID {
                    currentUserLandingPageSettings = LandingPageOptions(rawValue: landingPageSetting) ?? .courses
                    break
                } else {
                    currentUserLandingPageSettings = LandingPageOptions.courses
                }
            }
        }
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // ---------------------------------------------
    // MARK: - Life Cycle
    // ---------------------------------------------
    
    open override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)

    }
    
    // ---------------------------------------------
    // MARK: - Delegate Methods
    // ---------------------------------------------
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landingPageOptions.count
    }
    
    fileprivate static let cellReuseIdentifier = "LandingPageSettingsCell"
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = landingPageOptions[indexPath.row].description
        if currentUserLandingPageSettings == landingPageOptions[indexPath.row] {
            cell.accessoryType  = UITableViewCellAccessoryType.checkmark
            cell.setSelected(true, animated: false)
        }
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Choose Landing Page", comment: "Button to select a landing page")
        } else {
            return nil
        }
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentUserLandingPageSettings = landingPageOptions[indexPath.row]
        currentLandingPageSettingsDictionary[currentUsersID] = landingPageOptions[indexPath.row].description
        UserDefaults.standard.set(currentLandingPageSettingsDictionary, forKey: "landingPageSettings")
        tableView.reloadData()
    }
    
    open override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
    }
    
}
