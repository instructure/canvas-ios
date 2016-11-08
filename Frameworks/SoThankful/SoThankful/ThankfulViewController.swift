//
//  ThankfulViewController.swift
//  SoThankful
//
//  Created by Layne Moseley on 11/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit

public class ThankfulViewController: UITableViewController {
    
    lazy var components: [(name: String, url: String?)] = {
        guard let url = NSBundle.soThankfulBundle().URLForResource("components", withExtension: "plist") else {
            fatalError("components.plist is missing")
        }
        
        guard let components = NSArray(contentsOfURL: url) as? [[String: String]] else {
            fatalError("components.plist is missing")
        }
        
        return components.map {
            guard let name = $0["name"] else {
                fatalError("components.plist is malformed")
            }
            
            return (name, $0["url"])
        }.sort {
            return $0.name.lowercaseString < $1.name.lowercaseString
        }
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.title = NSLocalizedString("Components", comment: "Title of a screen that shows all of our open source components")
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        let component = components[indexPath.row]
        
        cell.textLabel?.text = component.name
        
        if let subtitle = component.url {
            cell.detailTextLabel?.text = subtitle
            cell.accessoryType = .DisclosureIndicator
        }
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let component = components[indexPath.row]
        if let stringURL = component.url,
            let url = NSURL(string: stringURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
