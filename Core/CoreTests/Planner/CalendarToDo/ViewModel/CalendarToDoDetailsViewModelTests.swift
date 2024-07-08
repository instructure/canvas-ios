//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@testable import Core
import XCTest

class CalendarToDoDetailsViewModelTests: CoreTestCase {

    private var inputPlannable: Plannable!
    private var resultPlannable: Plannable!
    private var interactor: CalendarToDoInteractorPreview!
    private var testee: CalendarToDoDetailsViewModel!

    override func setUp() {
        super.setUp()
        inputPlannable = Plannable.save(
            .make(
                id: "input id",
                title: "input title",
                details: "input details",
                todo_date: DateComponents(calendar: .current, year: 1984).date!
            ),
            contextName: nil,
            in: databaseClient
        )
        resultPlannable = Plannable.save(
            .make(
                id: "result id",
                title: "result title",
                details: "result details",
                todo_date: DateComponents(calendar: .current, year: 2020).date!
            ),
            contextName: nil,
            in: databaseClient
        )

        interactor = .init()
        interactor.getToDoResult = .success(resultPlannable)
        testee = .init(plannable: inputPlannable, interactor: interactor, router: router)
    }

    override func tearDown() {
        inputPlannable = nil
        resultPlannable = nil
        interactor = nil
        testee = nil
        super.tearDown()
    }

    // MARK: - Initial values

    func testProperties() {
        XCTAssertEqual(testee.navigationTitle, String(localized: "To Do", bundle: .core))
    }

    func testGetToDo() {
        XCTAssertEqual(interactor.getToDoCallsCount, 1)
        XCTAssertEqual(interactor.getToDoInput, inputPlannable.id)
    }

    func testInitialValuesWhenGetToDoSucceeds() {
        XCTAssertEqual(testee.title, resultPlannable.title)
        XCTAssertEqual(testee.description, resultPlannable.details)
        XCTAssertEqual(testee.date, resultPlannable.date?.dateTimeString)

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.isMoreButtonEnabled, true)
        XCTAssertEqual(testee.shouldShowDeleteError, false)
        XCTAssertEqual(testee.shouldShowDeleteConfirmation, false)
    }

    func testInitialValuesWhenGetToDoFails() {
        interactor.getToDoResult = .failure(NSError.internalError())
        testee = .init(plannable: inputPlannable, interactor: interactor, router: router)

        XCTAssertEqual(testee.title, inputPlannable.title)
        XCTAssertEqual(testee.description, inputPlannable.details)
        XCTAssertEqual(testee.date, inputPlannable.date?.dateTimeString)

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.isMoreButtonEnabled, true)
        XCTAssertEqual(testee.shouldShowDeleteError, false)
        XCTAssertEqual(testee.shouldShowDeleteConfirmation, false)
    }

    // MARK: - Did Tap Edit

    func testDidTapEdit() {
        let sourceVC = UIViewController()
        testee.didTapEdit.send(WeakViewController(sourceVC))

        guard let lastPresentation = router.viewControllerCalls.last else {
            return XCTFail()
        }
        XCTAssertTrue(lastPresentation.0 is CoreHostingController<EditCalendarToDoScreen>)
        XCTAssertEqual(lastPresentation.1, sourceVC)
        XCTAssertEqual(lastPresentation.2, .modal(isDismissable: false, embedInNav: true))

        XCTAssertEqual(testee.shouldShowDeleteConfirmation, false)
    }

    // MARK: - Did Tap Delete

    func testDidTapDelete() {
        testee.didTapDelete.send(.init())

        XCTAssertEqual(testee.shouldShowDeleteConfirmation, true)
        XCTAssertEqual(testee.shouldShowDeleteError, false)
        XCTAssertEqual(interactor.deleteToDoCallsCount, 0)

        testee.deleteConfirmationAlert.notifyCompletion(isConfirmed: true)
        XCTAssertEqual(interactor.deleteToDoCallsCount, 1)
        XCTAssertEqual(testee.state, .data(loadingOverlay: true))
        XCTAssertEqual(testee.isMoreButtonEnabled, false)
    }

    func testDeleteToDoOnSuccess() {
        interactor.deleteToDoResult = .success

        let sourceVC = UIViewController()
        testee.didTapDelete.send(WeakViewController(sourceVC))
        testee.deleteConfirmationAlert.notifyCompletion(isConfirmed: true)

        XCTAssertEqual(router.popped, sourceVC)
    }

    func testDeleteToDoOnFailure() {
        interactor.deleteToDoResult = .failure(NSError.internalError())

        testee.didTapDelete.send(.init())
        testee.deleteConfirmationAlert.notifyCompletion(isConfirmed: true)

        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.isMoreButtonEnabled, true)
        XCTAssertEqual(testee.shouldShowDeleteError, true)
        XCTAssertEqual(router.popped, nil)
    }
}
