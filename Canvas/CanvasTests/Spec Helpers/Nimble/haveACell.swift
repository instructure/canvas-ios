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
