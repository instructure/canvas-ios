//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
import Core
@testable import Student
import TestsFoundation
import RealmSwift

class GroupNavigationPresenterTests: XCTestCase {

    var resultingTabs: [Tab]?
    var presenter: GroupNavigationPresenter!
    var resultingError: NSError?
    var frc: MockFetchedResultsController<Tab>?

    override func setUp() {
        super.setUp()

        setupPresenter(MockPersistence())
        frc = presenter.frc as? MockFetchedResultsController<Tab>
    }

    func setupPresenter(_ persistence: Persistence) {
        presenter = GroupNavigationPresenter(persistence: persistence)
        presenter.view = self
    }

    func testLoadTabs() {
        //  given
        let expected = [Tab.make()]
        frc?.mockObjects = expected

        //  when
        presenter.loadTabs()

        //  then
        XCTAssertEqual(resultingTabs, expected)
    }

    func testErrorInLoadingTabs() {
        //  given
        let expected = NSError.instructureError("InternalError")
        frc?.error = expected

        //  when
        presenter.loadTabs()

        //  then
        XCTAssertEqual(resultingError, expected)
    }

    func testTabsAreOrderedByPosition() {
        let expected = SortDescriptor(key: "position", ascending: true)
        XCTAssertEqual(frc?.sortDescriptors, [expected])
    }
}

extension GroupNavigationPresenterTests: GroupNavigationViewCompositeDelegate {
    func showTabs(_ tabs: [Tab]) {
        resultingTabs = tabs
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
