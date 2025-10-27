//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

@testable import Horizon
import XCTest

final class UnenrolledProgramListWidgetViewModelTests: XCTestCase {

    // MARK: - Initialization
    func testInitWithEmptyProgramsSetsEmptyState() {
        let testee = UnenrolledProgramListWidgetViewModel(programs: [])
        XCTAssertEqual(testee.programs.count, 0)
        XCTAssertNil(testee.currentProgram)
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertFalse(testee.isNavigationButtonVisible)
        XCTAssertFalse(testee.isNextButtonEnabled)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
    }

    func testInitWithSingleProgramSetsFirstProgramAndDisablesButtons() {
        let testee = UnenrolledProgramListWidgetViewModel(programs: [makeProgram(id: 1)])
        XCTAssertEqual(testee.programs.count, 1)
        XCTAssertEqual(testee.currentProgram?.id, "program-1")
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertFalse(testee.isNavigationButtonVisible)
        XCTAssertFalse(testee.isNextButtonEnabled)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
    }

    func testInitWithMultipleProgramsSetsFirstProgramAndEnablesNext() {
        let programs = (1...3).map(makeProgram)
        let testee = UnenrolledProgramListWidgetViewModel(programs: programs)
        XCTAssertEqual(testee.programs.count, 3)
        XCTAssertEqual(testee.currentProgram?.id, "program-1")
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertTrue(testee.isNavigationButtonVisible)
        XCTAssertTrue(testee.isNextButtonEnabled)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
    }

    // MARK: - Navigation Forward
    func testGoNextProgramAdvancesIndexUntilLastThenDisablesNext() {
        let testee = UnenrolledProgramListWidgetViewModel(programs: (1...3).map(makeProgram))
        testee.goNextProgram()
        XCTAssertEqual(testee.currentInex, 1)
        XCTAssertEqual(testee.currentProgram?.id, "program-2")
        XCTAssertTrue(testee.isPreviousButtonEnabled)
        XCTAssertTrue(testee.isNextButtonEnabled)

        testee.goNextProgram()
        XCTAssertEqual(testee.currentInex, 2)
        XCTAssertEqual(testee.currentProgram?.id, "program-3")
        XCTAssertTrue(testee.isPreviousButtonEnabled)
        XCTAssertFalse(testee.isNextButtonEnabled)

        testee.goNextProgram()
        XCTAssertEqual(testee.currentInex, 2)
        XCTAssertEqual(testee.currentProgram?.id, "program-3")
    }

    // MARK: - Navigation Backward
    func testPreviousProgramMovesBackUntilFirstThenDisablesPrevious() {
        let testee = UnenrolledProgramListWidgetViewModel(programs: (1...3).map(makeProgram))
        testee.goNextProgram()
        testee.goNextProgram()
        XCTAssertEqual(testee.currentInex, 2)

        testee.goPreviousProgram() // to index 1
        XCTAssertEqual(testee.currentInex, 1)
        XCTAssertEqual(testee.currentProgram?.id, "program-2")
        XCTAssertTrue(testee.isPreviousButtonEnabled)
        XCTAssertTrue(testee.isNextButtonEnabled)

        testee.goPreviousProgram() // to index 0
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertEqual(testee.currentProgram?.id, "program-1")
        XCTAssertFalse(testee.isPreviousButtonEnabled)
        XCTAssertTrue(testee.isNextButtonEnabled)

        // Boundary: additional call should not change state
        testee.goPreviousProgram()
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertEqual(testee.currentProgram?.id, "program-1")
    }

    // MARK: - Navigation on Empty Data
    func testGoNextProgramOnEmptyProgramsDoesNothing() {
        let testee = UnenrolledProgramListWidgetViewModel(programs: [])
        testee.goNextProgram()
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertNil(testee.currentProgram)
        XCTAssertFalse(testee.isNextButtonEnabled)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
    }

    func testGoPreviousProgramOnEmptyProgramsDoesNothing() {
        let testee = UnenrolledProgramListWidgetViewModel(programs: [])
        testee.goPreviousProgram()
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertNil(testee.currentProgram)
        XCTAssertFalse(testee.isNextButtonEnabled)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
    }

    // MARK: - Update Programs
    func test_UpdateProgramsReplacesDataAndResetsState() {
        let testee = UnenrolledProgramListWidgetViewModel(programs: [makeProgram(id: 1), makeProgram(id: 2)])
        testee.goNextProgram() // move to index 1
        XCTAssertEqual(testee.currentInex, 1)

        let newPrograms = [makeProgram(id: 10), makeProgram(id: 11), makeProgram(id: 12)]
        testee.updatePrograms(newPrograms)

        XCTAssertEqual(testee.programs.map { $0.id }, ["program-10", "program-11", "program-12"])
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertEqual(testee.currentProgram?.id, "program-10")
        XCTAssertTrue(testee.isNextButtonEnabled)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
        XCTAssertTrue(testee.isNavigationButtonVisible)
    }

    func testUpdateProgramsToEmptyResetsToEmptyState() {
        let testee = UnenrolledProgramListWidgetViewModel(programs: [makeProgram(id: 1), makeProgram(id: 2)])
        testee.updatePrograms([])
        XCTAssertTrue(testee.programs.isEmpty)
        XCTAssertNil(testee.currentProgram)
        XCTAssertEqual(testee.currentInex, 0)
        XCTAssertFalse(testee.isNavigationButtonVisible)
        XCTAssertFalse(testee.isNextButtonEnabled)
        XCTAssertFalse(testee.isPreviousButtonEnabled)
    }

    // MARK: - Button States While Navigating
    func testButtonStatesUpdateCorrectlyDuringNavigation() {
        let testee = UnenrolledProgramListWidgetViewModel(programs: (1...4).map(makeProgram))
        // Start
        XCTAssertTrue(testee.isNextButtonEnabled)
        XCTAssertFalse(testee.isPreviousButtonEnabled)

        testee.goNextProgram() // index 1
        XCTAssertTrue(testee.isNextButtonEnabled)
        XCTAssertTrue(testee.isPreviousButtonEnabled)

        testee.goNextProgram() // index 2
        XCTAssertTrue(testee.isNextButtonEnabled)
        XCTAssertTrue(testee.isPreviousButtonEnabled)

        testee.goNextProgram() // index 3 (last)
        XCTAssertFalse(testee.isNextButtonEnabled)
        XCTAssertTrue(testee.isPreviousButtonEnabled)

        testee.goPreviousProgram() // back to 2
        XCTAssertTrue(testee.isNextButtonEnabled)
        XCTAssertTrue(testee.isPreviousButtonEnabled)
    }

    private func makeProgram(id: Int) -> Program {
        Program(
            id: "program-\(id)",
            name: "Program \(id)",
            variant: "",
            description: nil,
            date: nil,
            courseCompletionCount: nil,
            courses: []
        )
    }
}
