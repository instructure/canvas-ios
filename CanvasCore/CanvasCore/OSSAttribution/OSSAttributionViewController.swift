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

@objc open class OSSAttributionViewController: UITableViewController {
    
    lazy var components: [(name: String, url: String?)] = {
        guard let url = Bundle.core.url(forResource: "components", withExtension: "plist") else {
            fatalError("components.plist is missing")
        }
        
        guard let components = NSArray(contentsOf: url) as? [[String: String]] else {
            fatalError("components.plist is missing")
        }
        
        return components.map {
            guard let name = $0["name"] else {
                fatalError("components.plist is malformed")
            }
            
            return (name, $0["url"])
        }.sorted {
            return $0.name.lowercased() < $1.name.lowercased()
        }
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.title = NSLocalizedString("Components", comment: "Title of a screen that shows all of our open source components")
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let component = components[indexPath.row]
        
        cell.textLabel?.text = component.name
        
        if let subtitle = component.url {
            cell.detailTextLabel?.text = subtitle
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let component = components[indexPath.row]
        if let stringURL = component.url,
            let url = URL(string: stringURL) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
