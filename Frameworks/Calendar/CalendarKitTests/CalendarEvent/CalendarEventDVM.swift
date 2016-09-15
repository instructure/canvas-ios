//
//  CalendarEventDVM.swift
//  Calendar
//
//  Created by Nathan Armstrong on 3/11/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import SoPersistent

struct SimpleCalendarEventDVM: TableViewCellViewModel {
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

extension SimpleCalendarEventDVM: Equatable {}
func ==(lhs: SimpleCalendarEventDVM, rhs: SimpleCalendarEventDVM) -> Bool {
    return lhs.title == rhs.title
}
