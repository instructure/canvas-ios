//
//  SimpleAssignmentDVM.swift
//  Assignments
//
//  Created by Nathan Lambson on 6/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent

struct SimpleAssignmentDVM: TableViewCellViewModel {
    static var tableViewDidLoadWasCalled = false
    let title: String
    
    static func tableViewDidLoad(tableView: UITableView) {
        tableViewDidLoadWasCalled = true
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "dvm")
    }
    
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: "dvm")
        cell.textLabel!.text = title
        return cell
    }
}

extension SimpleAssignmentDVM: Equatable {}
func ==(lhs: SimpleAssignmentDVM, rhs: SimpleAssignmentDVM) -> Bool {
    return lhs.title == rhs.title
}