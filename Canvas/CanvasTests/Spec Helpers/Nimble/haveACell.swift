//
//  haveACell.swift
//  Canvas
//
//  Created by Nathan Armstrong on 9/12/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import Nimble

protocol TestableTableViewController {
    var tableView: UITableView! { get }
    func cell(cell: UITableViewCell, matches text: String) -> Bool
}

typealias CellInSectionWithLabelMatcher = (labeled: String, inSection: Int)
typealias CellAtIndexPathWithLabelMatcher = (labeled: String, atRow: Int, inSection: Int)

func haveACell(expected: CellInSectionWithLabelMatcher) -> NonNilMatcherFunc<TestableTableViewController> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "cell to have text"
        guard let tvc = try actualExpression.evaluate() else {
            return false
        }

        let tableView = tvc.tableView
        let section = expected.inSection
        let label = expected.labeled

        for i in 0..<tableView.numberOfRowsInSection(section) {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: section)) where tvc.cell(cell, matches: label) {
                return true
            }
        }
        return false
    }
}

func haveACell(expected: CellAtIndexPathWithLabelMatcher) -> NonNilMatcherFunc<TestableTableViewController> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "cell to have text"
        guard let tvc = try actualExpression.evaluate() else {
            return false
        }

        let tableView = tvc.tableView
        let row = expected.atRow
        let section = expected.inSection
        let label = expected.labeled

        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section)) where tvc.cell(cell, matches: label) {
            return true
        }
        return false
    }
}
