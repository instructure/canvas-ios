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

class CDSubAssignmentSubmissionTests: CoreTestCase {

    private static let testData = (
        submissionId: "some submissionId",
        userId: "some userId",
        subAssignmentTag: "some tag",
        statusId: "some statusId",
        lateSeconds: 42,
        score1: 85.5,
        score2: 90.0,
        score3: 92.5,
        grade1: "A",
        grade2: "B+",
        grade3: "A-"
    )
    private lazy var testData = Self.testData

    // MARK: - Save vs Update

    func test_save_shouldPersistModel() {
        let savedModel = saveModel(.make())
        let fetchedModel: CDSubAssignmentSubmission? = databaseClient.fetch().first

        XCTAssertEqual(savedModel.objectID, fetchedModel?.objectID)
    }

    func test_save_whenEntityNotExists_shouldCreateNewEntity() {
        let model111 = saveModel(.make(user_id: "user1", sub_assignment_tag: "tag1"), submissionId: "sub1")
        let model112 = saveModel(.make(user_id: "user1", sub_assignment_tag: "tag1"), submissionId: "sub2")
        let model121 = saveModel(.make(user_id: "user1", sub_assignment_tag: "tag2"), submissionId: "sub1")
        let model211 = saveModel(.make(user_id: "user2", sub_assignment_tag: "tag1"), submissionId: "sub1")

        XCTAssertNotEqual(model111.objectID, model112.objectID)
        XCTAssertNotEqual(model111.objectID, model121.objectID)
        XCTAssertNotEqual(model111.objectID, model211.objectID)
    }

    func test_save_whenEntityExists_shouldUpdateEntity() {
        let model1 = saveModel(.make(user_id: "1", sub_assignment_tag: "2", grade: "old grade"))
        let model2 = saveModel(.make(user_id: "1", sub_assignment_tag: "2", grade: "new grade"))

        XCTAssertEqual(model1.objectID, model2.objectID)
        XCTAssertEqual(model1.grade, "new grade")
    }

    // MARK: - Save Properties

    func test_saveBasicProperties() {
        let testee = saveModel(
            .make(
                user_id: testData.userId,
                sub_assignment_tag: testData.subAssignmentTag,
                excused: true,
                late: true,
                late_policy_status: .extended,
                seconds_late: testData.lateSeconds,
                missing: true,
                custom_grade_status_id: testData.statusId,
                entered_score: testData.score1,
                score: testData.score2,
                published_score: testData.score3,
                entered_grade: testData.grade1,
                grade: testData.grade2,
                published_grade: testData.grade3,
            ),
            submissionId: testData.submissionId
        )

        XCTAssertEqual(testee.submissionId, testData.submissionId)
        XCTAssertEqual(testee.userId, testData.userId)
        XCTAssertEqual(testee.subAssignmentTag, testData.subAssignmentTag)

        XCTAssertEqual(testee.isExcused, true)
        XCTAssertEqual(testee.isLate, true)
        XCTAssertEqual(testee.latePolicyStatus, .extended)
        XCTAssertEqual(testee.lateSeconds, testData.lateSeconds)
        XCTAssertEqual(testee.isMissing, true)
        XCTAssertEqual(testee.customGradeStatusId, testData.statusId)

        XCTAssertEqual(testee.enteredScore, testData.score1)
        XCTAssertEqual(testee.score, testData.score2)
        XCTAssertEqual(testee.publishedScore, testData.score3)

        XCTAssertEqual(testee.enteredGrade, testData.grade1)
        XCTAssertEqual(testee.grade, testData.grade2)
        XCTAssertEqual(testee.publishedGrade, testData.grade3)
    }

    func test_saveDefaultValues() {
        let testee = saveModel(.make())

        XCTAssertEqual(testee.isExcused, false)
        XCTAssertEqual(testee.isLate, false)
        XCTAssertEqual(testee.lateSeconds, 0)
        XCTAssertEqual(testee.isMissing, false)
        XCTAssertEqual(testee.gradeMatchesCurrentSubmission, false)
    }

    // MARK: - Status inputs

    func test_statusInput_isSubmitted() {
        var testee = saveModel(.make(submitted_at: Date()))
        XCTAssertEqual(testee.status.isSubmitted, true)

        testee = saveModel(.make(submitted_at: nil))
        XCTAssertEqual(testee.status.isSubmitted, false)
    }

    func test_statusInput_isGraded() {
        var testee = saveModel(.make(score: 42, grade_matches_current_submission: true))
        XCTAssertEqual(testee.status.hasGrade, true)

        testee = saveModel(.make(score: nil, grade_matches_current_submission: true))
        XCTAssertEqual(testee.status.hasGrade, false)

        testee = saveModel(.make(score: 42, grade_matches_current_submission: false))
        XCTAssertEqual(testee.status.hasGrade, false)
    }

    func test_statusInput_isLate() {
        var testee = saveModel(.make(late: true))
        XCTAssertEqual(testee.status.isLate, true)

        testee = saveModel(.make(late: false))
        XCTAssertEqual(testee.status.isLate, false)
    }

    func test_statusInput_isMissing() {
        var testee = saveModel(.make(missing: true))
        XCTAssertEqual(testee.status.isMissing, true)

        testee = saveModel(.make(missing: false))
        XCTAssertEqual(testee.status.isMissing, false)
    }

    func test_statusInput_isExcused() {
        var testee = saveModel(.make(excused: true))
        XCTAssertEqual(testee.status.isExcused, true)

        testee = saveModel(.make(excused: false))
        XCTAssertEqual(testee.status.isExcused, false)
    }

    func test_statusInput_customGradeStatus() {
        let customId = "some custom id"
        let customName = "some custom name"

        var testee = saveModel(.make(custom_grade_status_id: customId))
        testee.customGradeStatusName = customName
        XCTAssertEqual(testee.status.gradeStatus, .custom(id: customId, name: customName))

        testee = saveModel(.make(custom_grade_status_id: nil))
        testee.customGradeStatusName = customName
        XCTAssertEqual(testee.status.isCustom, false)

        testee = saveModel(.make(custom_grade_status_id: customId))
        testee.customGradeStatusName = nil
        XCTAssertEqual(testee.status.isCustom, false)
    }

    func test_statusInput_submissionType() {
        let testee = saveModel(.make())
        XCTAssertEqual(testee.status.nonSubmittableType, nil)
    }

    // MARK: - Private Helpers

    private func saveModel(
        _ item: APISubAssignmentSubmission,
        submissionId: String = testData.submissionId
    ) -> CDSubAssignmentSubmission {
        CDSubAssignmentSubmission.save(item, submissionId: submissionId, in: databaseClient)
    }
}
