//
//  DiscussionTopicDVM.swift
//  Discussions
//
//  Created by Brandon Pluim on 4/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent

struct SimpleDiscussionTopicDVM: TableViewCellViewModel {
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

extension SimpleDiscussionTopicDVM: Equatable {}
func ==(lhs: SimpleDiscussionTopicDVM, rhs: SimpleDiscussionTopicDVM) -> Bool {
    return lhs.title == rhs.title
}
