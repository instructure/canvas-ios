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
