//
//  SimpleRubricDVM.swift
//  Assignments
//
//  Created by Ben Kraus on 7/29/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent

struct SimpleRubricDVM: TableViewCellViewModel {
    static var tableViewDidLoadWasCalled = false
    let title: String
    let pointsPossible: NSNumber

    static func tableViewDidLoad(tableView: UITableView) {
        tableViewDidLoadWasCalled = true
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "dvm")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: "dvm")
        cell.textLabel!.text = "\(title) - \(pointsPossible) points possible"
        return cell
    }
}

extension SimpleRubricDVM: Equatable {}
func ==(lhs: SimpleRubricDVM, rhs: SimpleRubricDVM) -> Bool {
    return lhs.title == rhs.title && lhs.pointsPossible == rhs.pointsPossible
}