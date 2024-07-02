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
        testee = .init(plannable: inputPlannable, interactor: interactor)
    }

    override func tearDown() {
        inputPlannable = nil
        resultPlannable = nil
        interactor = nil
        testee = nil
        super.tearDown()
    }

    func testProperties() {
        XCTAssertEqual(testee.navigationTitle, String(localized: "To Do", bundle: .core))
    }

    func testGetToDo() {
        XCTAssertEqual(interactor.getToDoCallsCount, 1)
        XCTAssertEqual(interactor.getToDoInput, inputPlannable.id)
    }

    func testInitialValues() {
        XCTAssertEqual(testee.title, resultPlannable.title)
        XCTAssertEqual(testee.description, resultPlannable.details)
        XCTAssertEqual(testee.date, resultPlannable.date?.dateTimeString)
    }

    func testShowEditScreen() {
        let sourceVC = UIViewController()
        testee.showEditScreen(env: environment, from: .init(sourceVC))

        guard let lastPresentation = router.viewControllerCalls.last else {
            return XCTFail()
        }
        XCTAssertTrue(lastPresentation.0 is CoreHostingController<EditCalendarToDoScreen>)
        XCTAssertEqual(lastPresentation.1, sourceVC)
        XCTAssertEqual(lastPresentation.2, .modal(isDismissable: false, embedInNav: true))
    }
}
