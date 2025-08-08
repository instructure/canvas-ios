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

@testable import Core
import Foundation
import TestsFoundation
import XCTest

class GradingStandardInteractorLiveTests: CoreTestCase {
    let courseLevelApiGradingSchemeEntry: APIGradingSchemeEntry = .init(name: "Course Scheme", value: 1)
    let accountLevelApiGradingSchemeEntry: APIGradingSchemeEntry = .init(name: "Account Scheme", value: 2)
    let courseDefaultGradingSchemeRaw: [[TypeSafeCodable<String, Double>]] = [[
        .init(value1: "A", value2: 0.983),
        .init(value1: "A-", value2: 0.882),
        .init(value1: "B+", value2: 0.8712),
        .init(value1: "B", value2: 0.8549),
        .init(value1: "B-", value2: 0.8099),
        .init(value1: "C+", value2: 0.775),
        .init(value1: "C", value2: 0.74),
        .init(value1: "C-", value2: 0.703),
        .init(value1: "D+", value2: 0.67),
        .init(value1: "D", value2: 0.64),
        .init(value1: "D-", value2: 0.61),
        .init(value1: "F", value2: 0)
    ]]

    func mockGradingStandard(
        gradingStandardId: String,
        courseId: String? = nil,
        apiGradingSchemeEntry: APIGradingSchemeEntry
    ) {
        api.mock(
            GetGradingStandard(id: gradingStandardId, courseId: courseId),
            value: .init(
                id: ID(gradingStandardId),
                title: "A",
                context_type: "whatever",
                context_id: ID("1"),
                points_based: true,
                scaling_factor: 1,
                grading_scheme: [apiGradingSchemeEntry]
            )
        )
    }

    func mockCourseWithGradingScheme() {
        let responseValue: APICourse = .make(
            id: "1",
            grading_scheme: courseDefaultGradingSchemeRaw,
            scaling_factor: 1.0,
            points_based_grading_scheme: false
        )
        api.mock(GetCourseWithGradingSchemeOnly(courseId: "1"), value: responseValue)
    }

    override func setUp() {
        super.setUp()
        mockCourseWithGradingScheme()
    }

    func testCourseLevelGradingScheme() {
        mockGradingStandard(
            gradingStandardId: "1",
            courseId: "1",
            apiGradingSchemeEntry: courseLevelApiGradingSchemeEntry
        )

        let testee = GradingStandardInteractorLive(
            courseId: "1",
            gradingStandardId: "1",
            env: environment
        )

        let courseLevelGradingSchemeEntries: [GradingSchemeEntry] = [
            .init(courseLevelApiGradingSchemeEntry)
        ]
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.gradingScheme
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data?.entries, courseLevelGradingSchemeEntries)
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testAccountLevelGradingScheme() {
        mockGradingStandard(
            gradingStandardId: "2",
            apiGradingSchemeEntry: accountLevelApiGradingSchemeEntry
        )

        let testee = GradingStandardInteractorLive(
            courseId: "1",
            gradingStandardId: "2",
            env: environment
        )
        let accountLevelGradingSchemeEntries: [GradingSchemeEntry] = [
            .init(accountLevelApiGradingSchemeEntry)
        ]
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.gradingScheme
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data?.entries, accountLevelGradingSchemeEntries)
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testFallbackToCourseDefaultGradingScheme() {
        let testee = GradingStandardInteractorLive(
            courseId: "1",
            env: environment
        )
        let courseDefaultGradingSchemeEntries: [GradingSchemeEntry] = courseDefaultGradingSchemeRaw.compactMap(GradingSchemeEntry.init)
        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee.gradingScheme
            .sink(
                receiveCompletion: { _ in }) { data in
                    XCTAssertEqual(data?.entries, courseDefaultGradingSchemeEntries)
                    expectation.fulfill()
                }
        drainMainQueue()
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }
}
