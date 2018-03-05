//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
