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

    class MockUseCase: PresenterUseCase {
    }

    var resultingTabs: [Tab]?
    var presenter: GroupNavigationPresenter!
    var resultingError: NSError?
    var frc: MockFetchedResultsController<Tab>?
    var env: AppEnvironment = testEnvironment()
    var mockUseCase: MockUseCase!
    var expectation = XCTestExpectation(description: "expectation")
    var frcCallCount = 0

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        env = testEnvironment()
        presenter = GroupNavigationPresenter(env: env, view: self, groupID: Group.make().id)
        mockUseCase = MockUseCase()
        presenter.useCase = mockUseCase
        frc = presenter.frc as? MockFetchedResultsController<Tab>
        frc?.delegate = presenter
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

    func testUseCaseFetchesData() {
        //  given
        resultingTabs = nil
        self.frc?.delegate = self
        let expectation = XCTestExpectation(description: "expectation")
        let workOp = BlockOperation { [weak self] in
            self?.frc?.mockObjects = [Tab.make()]
            self?.frc?.delegate?.controllerDidChangeContent(self!.frc!)
            expectation.fulfill()
        }
        mockUseCase.addOperations([workOp])

       //   when
        presenter.loadTabs()
        wait(for: [expectation], timeout: 0.1)

        //  then
        XCTAssertEqual(resultingTabs?.first?.fullUrl, Tab.make().fullUrl)

        //  when
        presenter.loadTabs()

        //  then
        XCTAssertEqual(frcCallCount, 1) //  this attempts to assure that loadFromServer is only called once
    }
}

extension GroupNavigationPresenterTests: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        frcCallCount += 1
        presenter.loadTabs()
    }
}

extension GroupNavigationPresenterTests: GroupNavigationViewProtocol {
    func updateNavBar(title: String, backgroundColor: UIColor) {
    }

    func showTabs(_ tabs: [Tab]) {
        resultingTabs = tabs
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
