//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Horizon
import XCTest

final class ProgressStatusTests: HorizonTestCase {

    // MARK: - Initialization from Progress Tests

    func test_init_withZeroProgress_shouldReturnNotStarted() {
        let status = ProgressStatus(progress: 0.0)

        XCTAssertEqual(status, .notStarted)
    }

    func test_init_with100Progress_shouldReturnCompleted() {
        let status = ProgressStatus(progress: 100.0)

        XCTAssertEqual(status, .completed)
    }

    func test_init_withPartialProgress_shouldReturnInProgress() {
        let testCases = [0.1, 25.0, 50.0, 75.0, 99.9]

        for progress in testCases {
            let status = ProgressStatus(progress: progress)
            XCTAssertEqual(status, .inProgress, "Progress \(progress) should be .inProgress")
        }
    }

    // MARK: - Initialization from RawValue Tests

    func test_init_withRawValue0_shouldReturnAll() {
        let status = ProgressStatus(rawValue: 0)

        XCTAssertEqual(status, .all)
    }

    func test_init_withRawValue1_shouldReturnNotStarted() {
        let status = ProgressStatus(rawValue: 1)

        XCTAssertEqual(status, .notStarted)
    }

    func test_init_withRawValue2_shouldReturnInProgress() {
        let status = ProgressStatus(rawValue: 2)

        XCTAssertEqual(status, .inProgress)
    }

    func test_init_withRawValue3OrHigher_shouldReturnCompleted() {
        let testCases = [3, 4, 5, 100]

        for rawValue in testCases {
            let status = ProgressStatus(rawValue: rawValue)
            XCTAssertEqual(status, .completed, "RawValue \(rawValue) should be .completed")
        }
    }

    // MARK: - Title Tests

    func test_title_forAllStatus_shouldReturnContext() {
        let status = ProgressStatus.all
        let context = "All courses"

        let title = status.title(for: context)

        XCTAssertEqual(title, context)
    }

    func test_title_forNotStartedStatus_shouldReturnNotStarted() {
        let status = ProgressStatus.notStarted

        let title = status.title(for: "All courses")

        XCTAssertEqual(title, String(localized: "Not started", bundle: .horizon))
    }

    func test_title_forInProgressStatus_shouldReturnInProgress() {
        let status = ProgressStatus.inProgress

        let title = status.title(for: "All courses")

        XCTAssertEqual(title, String(localized: "In progress", bundle: .horizon))
    }

    func test_title_forCompletedStatus_shouldReturnCompleted() {
        let status = ProgressStatus.completed

        let title = status.title(for: "All courses")

        XCTAssertEqual(title, String(localized: "Completed", bundle: .horizon))
    }

    // MARK: - Static Options Tests

    func test_courses_shouldReturnAllStatusOptions() {
        let options = ProgressStatus.courses

        XCTAssertEqual(options.count, 4)
        XCTAssertEqual(options[0].id, ProgressStatus.all.rawValue)
        XCTAssertEqual(options[1].id, ProgressStatus.notStarted.rawValue)
        XCTAssertEqual(options[2].id, ProgressStatus.inProgress.rawValue)
        XCTAssertEqual(options[3].id, ProgressStatus.completed.rawValue)
    }

    func test_courses_shouldContainAllCoursesAsFirstOption() {
        let options = ProgressStatus.courses

        XCTAssertEqual(options.first?.name, String(localized: "All courses"))
    }

    func test_programs_shouldReturnAllStatusOptions() {
        let options = ProgressStatus.programs

        XCTAssertEqual(options.count, 4)
        XCTAssertEqual(options[0].id, ProgressStatus.all.rawValue)
        XCTAssertEqual(options[1].id, ProgressStatus.notStarted.rawValue)
        XCTAssertEqual(options[2].id, ProgressStatus.inProgress.rawValue)
        XCTAssertEqual(options[3].id, ProgressStatus.completed.rawValue)
    }

    func test_programs_shouldContainAllProgramsAsFirstOption() {
        let options = ProgressStatus.programs

        XCTAssertEqual(options.first?.name, String(localized: "All programs"))
    }

    // MARK: - AllCases Tests

    func test_allCases_shouldContainAllStatuses() {
        let allCases = ProgressStatus.allCases

        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.all))
        XCTAssertTrue(allCases.contains(.notStarted))
        XCTAssertTrue(allCases.contains(.inProgress))
        XCTAssertTrue(allCases.contains(.completed))
    }

    // MARK: - RawValue Tests

    func test_rawValue_shouldMatchExpectedValues() {
        XCTAssertEqual(ProgressStatus.all.rawValue, 0)
        XCTAssertEqual(ProgressStatus.notStarted.rawValue, 1)
        XCTAssertEqual(ProgressStatus.inProgress.rawValue, 2)
        XCTAssertEqual(ProgressStatus.completed.rawValue, 3)
    }

    // MARK: - Edge Cases Tests

    func test_init_withNegativeProgress_shouldReturnInProgress() {
        let status = ProgressStatus(progress: -1.0)

        XCTAssertEqual(status, .inProgress)
    }

    func test_init_withProgressOver100_shouldReturnInProgress() {
        let status = ProgressStatus(progress: 150.0)

        XCTAssertEqual(status, .inProgress)
    }

    func test_init_withExactly0_shouldReturnNotStarted() {
        let status = ProgressStatus(progress: 0.0)

        XCTAssertEqual(status, .notStarted)
    }

    func test_init_withExactly100_shouldReturnCompleted() {
        let status = ProgressStatus(progress: 100.0)

        XCTAssertEqual(status, .completed)
    }
}
