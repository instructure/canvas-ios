//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import Combine

class AssignmentDueDatesViewModelTests: CoreTestCase {
    var mockInteractor: AssignmentDueDatesInteractorMock!
    var testee: AssignmentDueDatesViewModel!

    override func setUp() {
        super.setUp()
        mockInteractor = AssignmentDueDatesInteractorMock()
        testee = AssignmentDueDatesViewModel(interactor: mockInteractor)
    }

    func testReadsInteractorState() {
        mockInteractor.state.send(.error)

        XCTAssertEqual(testee.state, .error)
    }

    func testReadsInteractorData() {
        let dueDates = [
            AssignmentDate.save(.make(id: "1"), assignmentID: "1", in: databaseClient),
            AssignmentDate.save(.make(id: "2"), assignmentID: "1", in: databaseClient),
        ]
        mockInteractor.dueDates.send(dueDates)

        XCTAssertEqual(testee.dueDates.count, 2)
    }
}

class AssignmentDueDatesInteractorMock: AssignmentDueDatesInteractor {
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)
    public var dueDates = CurrentValueSubject<[AssignmentDate], Never>([])
}
