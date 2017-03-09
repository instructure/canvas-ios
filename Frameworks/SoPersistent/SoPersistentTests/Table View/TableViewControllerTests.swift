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
    
    

import Foundation
import SoAutomated
import SoPersistent
import SoLazy

class TableViewControllerTests: XCTestCase {

    func testDescribeTableViewController() {
        let dataSource = SimpleTableViewDataSource()
        let vc = TableViewController(dataSource: dataSource)

        describe("selecting an item") {
            it("has a hook for when an item is selected") {
                var indexPath: IndexPath?
                vc.didSelectItemAtIndexPath = { indexPath = $0 }
                let tableView = vc.tableView

                let delegate = vc as UITableViewDelegate
                delegate.tableView?(tableView!, didSelectRowAt: IndexPath(row: 0, section: 0))

                XCTAssertNotNil(indexPath)
                XCTAssertEqual(IndexPath(row: 0, section: 0), indexPath)
            }
        }

        describe("data source") {
            context("when the view has loaded") {
                let _ = vc.view // triggers viewDidLoad

                it("setting the data source calls viewDidLoad on the data source") {
                    dataSource.viewDidLoadWasCalled = false
                    vc.dataSource = nil

                    vc.dataSource = dataSource

                    XCTAssert(dataSource.viewDidLoadWasCalled)
                }
            }
        }

        describe("refresher") {
            it("makes refresher when set") {
                let refresher = SimpleRefresher()
                vc.refresher = refresher
                XCTAssert(refresher.makeRefreshableWasCalled)
            }

            it("sets refreshCompleted to one that presents the error") {
                var presented = false
                ErrorReporter.setErrorHandler { _ in
                    presented = true
                }
                let error = NSError(subdomain: "blah", description: "blah")

                let refresher = SimpleRefresher()
                vc.refresher = refresher
                refresher.refreshingCompletedObserver.send(value: error)

                XCTAssert(presented)
            }

            it("sets refreshCompleted to one that presents the error on init") {
                var presented = false
                ErrorReporter.setErrorHandler { _ in
                    presented = true
                }
                let error = NSError(subdomain: "blah", description: "blah")

                let refresher = SimpleRefresher()
                let vc = TableViewController(dataSource: dataSource, refresher: refresher)
                refresher.refreshingCompletedObserver.send(value: error)

                XCTAssert(presented)
            }
        }
    }
}
