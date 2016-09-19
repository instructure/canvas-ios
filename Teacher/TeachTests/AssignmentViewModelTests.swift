//
//  AssignmentViewModelTests.swift
//  Teach
//
//  Created by Derrick Hathaway on 6/23/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Quick
import Nimble
import AssignmentKit

class AssignmentViewModelSpec: QuickSpec {
    override func spec() {
        describe("AssignmentViewModel") {
            describe("#tableViewDidLoad") {
                it("registers AssignmentCell") {
                    let tableView = UITableView()
                    AssignmentViewModel.tableViewDidLoad(tableView)
                    let cell = tableView.dequeueReusableCellWithIdentifier("AssignmentCell")
                    expect(cell).to(beAKindOf(AssignmentCell))
                }
            }
        }
    }
}
