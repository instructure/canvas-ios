//
//  ColorfulViewModel.swift
//  Assignments
//
//  Created by Derrick Hathaway on 1/5/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
//import CakeBox

public struct ColorfulViewModel: TableViewCellViewModel {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ColorfulCell")
    }
    
    public func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ColorfulCell", forIndexPath: indexPath)
        cell.textLabel?.text = name
        return cell
    }
}
