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

import Foundation
import XCTest
@testable import Core
@testable import Teacher
import TestsFoundation

class SubmissionWordCountInteractorTests: TeacherTestCase {

    private static let testData = (
        assignmentId: "some assignmentId",
        userId: "some userId"
    )
    private lazy var testData = Self.testData

    private var testee: SubmissionWordCountInteractorLive!

    override func setUp() {
        super.setUp()

        setupAPIMocks()

        testee = .init(
            assignmentId: testData.assignmentId,
            api: api
        )
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func test_properties() {
        XCTAssertEqual(testee.assignmentId, testData.assignmentId)
    }

    // MARK: - getWordCount

    func test_getWordCount_shouldReturnWordCountForGivenAssignmentAndUserAndAttempt() throws {
        XCTAssertSingleOutputEquals(testee.getWordCount(userId: testData.userId, attempt: 1), 101)
    }

    func test_getWordCount_whenSubmissionTypeIsTextEntry() throws {
        XCTAssertSingleOutputEquals(testee.getWordCount(userId: testData.userId, attempt: 1), 101)
        XCTAssertSingleOutputEquals(testee.getWordCount(userId: testData.userId, attempt: 2), 102)
        XCTAssertSingleOutputEquals(testee.getWordCount(userId: testData.userId, attempt: 3), 103)
        XCTAssertSingleOutputEquals(testee.getWordCount(userId: testData.userId, attempt: 4), 104)
        XCTAssertSingleOutputEquals(testee.getWordCount(userId: testData.userId, attempt: 5), nil)
        XCTAssertSingleOutputEquals(testee.getWordCount(userId: testData.userId, attempt: 10), 0)
    }

    func test_getWordCount_whenSubmissionTypeIsDifferent() throws {
        XCTAssertSingleOutputEquals(testee.getWordCount(userId: testData.userId, attempt: 21), nil)
        XCTAssertSingleOutputEquals(testee.getWordCount(userId: testData.userId, attempt: 22), nil)
        XCTAssertSingleOutputEquals(testee.getWordCount(userId: testData.userId, attempt: 23), nil)
    }

    // MARK: - Private helpers

    private func setupAPIMocks() {
        let textEntry = SubmissionType.online_text_entry.rawValue
        let onlineUpload = SubmissionType.online_upload.rawValue

        api.mock(
            GetSubmissionWordCountRequest(
                assignmentId: testData.assignmentId,
                userId: testData.userId
            ),
            value: .init(submissionAttempts: [
                .make(attempt: 1, wordCount: 101, submissionType: textEntry),
                .make(attempt: 2, wordCount: 102, submissionType: textEntry),
                .make(attempt: 3, wordCount: 103.5, submissionType: textEntry),
                .make(attempt: 4, wordCount: 104.8, submissionType: textEntry),
                .make(attempt: 5, wordCount: nil, submissionType: textEntry),
                .make(attempt: 10, wordCount: 0, submissionType: textEntry),

                .make(attempt: 21, wordCount: 121, submissionType: onlineUpload),
                .make(attempt: 22, wordCount: 122, submissionType: "not a submission type"),
                .make(attempt: 23, wordCount: 123, submissionType: nil)
            ])
        )

        api.mock(
            GetSubmissionWordCountRequest(
                assignmentId: testData.assignmentId,
                userId: "another userId"
            ),
            value: .init(submissionAttempts: [
                .make(attempt: 1, wordCount: 201, submissionType: textEntry)
            ])
        )

        api.mock(
            GetSubmissionWordCountRequest(
                assignmentId: "another assignmentId",
                userId: testData.userId
            ),
            value: .init(submissionAttempts: [
                .make(attempt: 1, wordCount: 301, submissionType: textEntry)
            ])
        )
    }
}
