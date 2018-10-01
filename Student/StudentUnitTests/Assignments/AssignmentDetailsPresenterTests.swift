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
@testable import Student
import Core
import TestsFoundation

class AssignmentDetailsPresenterTests: XCTestCase {

    var resultingError: NSError?
    var resultingAssignment: AssignmentDetailsViewModel?
    var presenter: AssignmentDetailsPresenter!
    var env: AppEnvironment = testEnvironment()
    var expectation = XCTestExpectation(description: "expectation")
    var mockUseCase: MockUseCase!
    var frc: MockFetchedResultsController<Assignment>?
    var frcCallCount = 0

    override func setUp() {
        expectation = XCTestExpectation(description: "expectation")
        env = testEnvironment()
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", useCaseFactory: { [weak self] (_, _) -> PresenterUseCase in
            return self!.mockUseCase
        })
        mockUseCase = MockUseCase()
        presenter.useCase = mockUseCase
        frc = presenter.frc as? MockFetchedResultsController<Assignment>
        frc?.delegate = presenter
    }

    func testLoadAssignment() {
        //  given
        let a = Assignment.make()
        let expected = AssignmentDetailsViewModel(name: a.name, pointsPossible: a.pointsPossible, dueAt: a.dueAt, submissionTypes: a.submissionTypes)

        frc?.mockObjects = [a]

        //  when
        presenter.loadAssignment()

        //  then
        XCTAssertEqual(resultingAssignment, expected)
    }

    func testErrorInLoadingTabs() {
        //  given
        let expected = NSError.instructureError("InternalError")
        frc?.error = expected

        //  when
        presenter.loadAssignment()

        //  then
        XCTAssertEqual(resultingError, expected)
    }

    func testFrcParameters() {
        XCTAssertEqual(frc?.sortDescriptors, nil)
        XCTAssertEqual(frc?.predicate, NSPredicate.id("1"))
    }

    func testUseCaseFetchesData() {
        //  given
        resultingAssignment = nil
        self.frc?.delegate = self
        let expectation = XCTestExpectation(description: "expectation")
        let workOp = BlockOperation { [weak self] in
            self?.frc?.mockObjects = [Assignment.make()]
            self?.frc?.delegate?.controllerDidChangeContent(self!.frc!)
            expectation.fulfill()
        }
        mockUseCase.addOperations([workOp])

        //   when
        presenter.loadDataFromServer()
        wait(for: [expectation], timeout: 0.1)

        //  then
        XCTAssertEqual(resultingAssignment?.name, Assignment.make().name)

        //  when
        presenter.loadAssignment()

        //  then
        XCTAssertEqual(frcCallCount, 1) //  this attempts to assure that loadFromServer is only called once
    }
}

extension AssignmentDetailsPresenterTests: AssignmentDetailsViewProtocol {
    func update(assignment: AssignmentDetailsViewModel) {
        resultingAssignment = assignment
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }

    func updateNavBar(subtitle: String, backgroundColor: UIColor) {
    }
}

extension AssignmentDetailsPresenterTests: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        frcCallCount += 1
        presenter.loadAssignment()
    }
}
