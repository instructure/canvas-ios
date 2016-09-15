//
//  SimpleTodoDVM.swift
//  Todo
//
//  Created by Joseph Davison on 6/27/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent

struct SimpleTodoDVM: TableViewCellViewModel {
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

extension SimpleTodoDVM: Equatable {}
func ==(lhs: SimpleTodoDVM, rhs: SimpleTodoDVM) -> Bool {
    return lhs.title == rhs.title
}