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

final class SubmissionStatusTests: CoreTestCase {

    private static let testData = (
        customStatusId: "custom-id-1",
        customStatusName: "custom status name"
    )
    private lazy var testData = Self.testData

    // MARK: - Init - isSubmitted

    func test_init_shouldSetIsSubmitted() {
        var testee = SubmissionStatus.make(
            isSubmitted: true
        )
        XCTAssertEqual(testee.isSubmitted, true)

        testee = SubmissionStatus.make(
            isSubmitted: false
        )
        XCTAssertEqual(testee.isSubmitted, false)
    }

    // MARK: - Init - gradeStatus

    func test_init_whenExcused_shouldSetGradeStatusToExcused() {
        let testee = SubmissionStatus.make(
            isExcused: true
        )

        XCTAssertEqual(testee.gradeStatus, .excused)
    }

    func test_init_whenCustomStatus_shouldSetGradeStatusToCustom() {
        let testee = SubmissionStatus.make(
            customStatusId: testData.customStatusId,
            customStatusName: testData.customStatusName
        )

        XCTAssertEqual(testee.gradeStatus, .custom(id: testData.customStatusId, name: testData.customStatusName))
    }

    func test_init_whenLate_shouldSetGradeStatusToLate() {
        let testee = SubmissionStatus.make(
            isLate: true
        )

        XCTAssertEqual(testee.gradeStatus, .late)
    }

    func test_init_whenMissing_shouldSetGradeStatusToMissing() {
        let testee = SubmissionStatus.make(
            isMissing: true
        )

        XCTAssertEqual(testee.gradeStatus, .missing)
    }

    func test_init_whenMultipleGradeStatuses_shouldRespectPriorityOrder() {
        let testee = SubmissionStatus.make(
            isLate: true,
            isMissing: true,
            isExcused: true,
            customStatusId: testData.customStatusId,
            customStatusName: testData.customStatusName
        )

        XCTAssertEqual(testee.gradeStatus, .excused)
    }

    func test_init_whenNoGradeStatus_shouldSetGradeStatusToNil() {
        let testee = SubmissionStatus.make(
            isLate: false,
            isMissing: false,
            isExcused: false,
            customStatusId: nil
        )

        XCTAssertEqual(testee.gradeStatus, nil)
    }

    func test_init_whenCustomStatusIdNil_shouldNotSetCustomStatus() {
        let testee = SubmissionStatus.make(
            customStatusId: nil,
            customStatusName: testData.customStatusName
        )

        XCTAssertEqual(testee.gradeStatus, nil)
    }

    func test_init_whenCustomStatusNameNil_shouldNotSetCustomStatus() {
        let testee = SubmissionStatus.make(
            customStatusId: testData.customStatusId,
            customStatusName: nil
        )

        XCTAssertEqual(testee.gradeStatus, nil)
    }

    // MARK: - Init - hasGrade

    func test_hasGrade_whenGradedAndBelongsToCurrentSubmission_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isGraded: true,
            isGradeBelongsToCurrentSubmission: true
        )

        XCTAssertEqual(testee.hasGrade, true)
    }

    func test_hasGrade_whenGradedButNotBelongsToCurrentSubmission_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isGraded: true,
            isGradeBelongsToCurrentSubmission: false
        )

        XCTAssertEqual(testee.hasGrade, false)
    }

    func test_hasGrade_whenNotGraded_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isGraded: false
        )

        XCTAssertEqual(testee.hasGrade, false)
    }

    // MARK: - Init - nonSubmittableType

    func test_nonSubmittableType_whenOnPaper_shouldBeOnPaper() {
        let testee = SubmissionStatus.make(
            submissionType: .on_paper
        )

        XCTAssertEqual(testee.nonSubmittableType, .onPaper)
    }

    func test_nonSubmittableType_whenNoSubmission_shouldBeNoSubmission() {
        let testee = SubmissionStatus.make(
            submissionType: SubmissionType.none
        )

        XCTAssertEqual(testee.nonSubmittableType, .noSubmission)
    }

    func test_nonSubmittableType_whenNotGraded_shouldBeNotGradable() {
        let testee = SubmissionStatus.make(
            submissionType: .not_graded
        )

        XCTAssertEqual(testee.nonSubmittableType, .notGradable)
    }

    func test_nonSubmittableType_whenOnlineSubmissionType_shouldBeNil() {
        let testee = SubmissionStatus.make(
            submissionType: .online_upload
        )

        XCTAssertEqual(testee.nonSubmittableType, nil)
    }

    func test_nonSubmittableType_whenNilSubmissionType_shouldBeNil() {
        let testee = SubmissionStatus.make(
            submissionType: nil
        )

        XCTAssertEqual(testee.nonSubmittableType, nil)
    }

    // MARK: - Default value

    func test_notSubmitted_shouldHaveExpectedValues() {
        let testee = SubmissionStatus.notSubmitted

        XCTAssertEqual(testee.isSubmitted, false)
        XCTAssertEqual(testee.hasGrade, false)
        XCTAssertEqual(testee.gradeStatus, nil)
        XCTAssertEqual(testee.nonSubmittableType, nil)
    }

    // MARK: - Computed properties - grade status checks

    func test_isExcused_whenGradeStatusIsExcused_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .excused
        )

        XCTAssertEqual(testee.isExcused, true)
    }

    func test_isExcused_whenGradeStatusIsNotExcused_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil
        )

        XCTAssertEqual(testee.isExcused, false)
    }

    func test_isCustom_whenGradeStatusIsCustom_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .custom(id: testData.customStatusId, name: testData.customStatusName)
        )

        XCTAssertEqual(testee.isCustom, true)
    }

    func test_isCustom_whenGradeStatusIsNotCustom_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil
        )

        XCTAssertEqual(testee.isCustom, false)
    }

    func test_isLate_whenGradeStatusIsLate_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .late
        )

        XCTAssertEqual(testee.isLate, true)
    }

    func test_isLate_whenGradeStatusIsNotLate_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil
        )

        XCTAssertEqual(testee.isLate, false)
    }

    func test_isMissing_whenGradeStatusIsMissing_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .missing
        )

        XCTAssertEqual(testee.isMissing, true)
    }

    func test_isMissing_whenGradeStatusIsNotMissing_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil
        )

        XCTAssertEqual(testee.isMissing, false)
    }

    // MARK: - Computed properties - isGraded

    func test_isGraded_whenHasGrade_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: true,
            gradeStatus: nil
        )

        XCTAssertEqual(testee.isGraded, true)
    }

    func test_isGraded_whenExcused_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .excused
        )

        XCTAssertEqual(testee.isGraded, true)
    }

    func test_isGraded_whenCustomStatus_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .custom(id: testData.customStatusId, name: testData.customStatusName)
        )

        XCTAssertEqual(testee.isGraded, true)
    }

    func test_isGraded_whenNotGradedAndNoGradeStatus_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil
        )

        XCTAssertEqual(testee.isGraded, false)
    }

    // MARK: - Computed properties - needsGrading

    func test_needsGrading_whenSubmittedAndNotGraded_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isSubmitted: true,
            hasGrade: false,
            gradeStatus: nil
        )

        XCTAssertEqual(testee.needsGrading, true)
    }

    func test_needsGrading_whenNotSubmitted_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil
        )

        XCTAssertEqual(testee.needsGrading, false)
    }

    func test_needsGrading_whenGraded_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: true,
            hasGrade: true,
            gradeStatus: nil
        )

        XCTAssertEqual(testee.needsGrading, false)
    }

    func test_needsGrading_whenExcused_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: true,
            hasGrade: false,
            gradeStatus: .excused
        )

        XCTAssertEqual(testee.needsGrading, false)
    }

    func test_needsGrading_whenCustomStatus_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: true,
            hasGrade: false,
            gradeStatus: .custom(id: testData.customStatusId, name: testData.customStatusName)
        )

        XCTAssertEqual(testee.needsGrading, false)
    }

    // MARK: - Computed properties - needsSubmission

    func test_needsSubmission_whenNotSubmittedAndSubmittableAndNotGraded_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: nil
        )

        XCTAssertEqual(testee.needsSubmission, true)
    }

    func test_needsSubmission_whenSubmitted_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: true,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: nil
        )

        XCTAssertEqual(testee.needsSubmission, false)
    }

    func test_needsSubmission_whenNotSubmittable_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: .onPaper
        )

        XCTAssertEqual(testee.needsSubmission, false)
    }

    func test_needsSubmission_whenGraded_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: true,
            gradeStatus: nil,
            nonSubmittableType: nil
        )

        XCTAssertEqual(testee.needsSubmission, false)
    }

    // MARK: - Computed properties - isTypeSubmittable

    func test_isTypeSubmittable_whenNonSubmittableTypeIsNil_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: nil
        )

        XCTAssertEqual(testee.isTypeSubmittable, true)
    }

    func test_isTypeSubmittable_whenNonSubmittableTypeIsNotNil_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: .onPaper
        )

        XCTAssertEqual(testee.isTypeSubmittable, false)
    }

    // MARK: - Computed properties - isNotSubmittableWithNoGradeNoGradeStatus

    func test_isNotSubmittableWithNoGradeNoGradeStatus_whenConditionsMet_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: .onPaper
        )

        XCTAssertEqual(testee.isNotSubmittableWithNoGradeNoGradeStatus, true)
    }

    func test_isNotSubmittableWithNoGradeNoGradeStatus_whenSubmittable_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: nil
        )

        XCTAssertEqual(testee.isNotSubmittableWithNoGradeNoGradeStatus, false)
    }

    func test_isNotSubmittableWithNoGradeNoGradeStatus_whenHasGrade_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: true,
            gradeStatus: nil,
            nonSubmittableType: .onPaper
        )

        XCTAssertEqual(testee.isNotSubmittableWithNoGradeNoGradeStatus, false)
    }

    func test_isNotSubmittableWithNoGradeNoGradeStatus_whenHasGradeStatus_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .excused,
            nonSubmittableType: .onPaper
        )

        XCTAssertEqual(testee.isNotSubmittableWithNoGradeNoGradeStatus, false)
    }

    // MARK: - Computed properties - isNotGradableWithNoGradeStatus

    func test_isNotGradableWithNoGradeStatus_whenConditionsMet_shouldBeTrue() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: .notGradable
        )

        XCTAssertEqual(testee.isNotGradableWithNoGradeStatus, true)
    }

    func test_isNotGradableWithNoGradeStatus_whenNotGradableTypeButHasGradeStatus_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .excused,
            nonSubmittableType: .notGradable
        )

        XCTAssertEqual(testee.isNotGradableWithNoGradeStatus, false)
    }

    func test_isNotGradableWithNoGradeStatus_whenNotNotGradableType_shouldBeFalse() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: .onPaper
        )

        XCTAssertEqual(testee.isNotGradableWithNoGradeStatus, false)
    }

    // MARK: - View Model - labelModel

    func test_labelModel_whenExcused_shouldReturnExcused() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .excused
        )

        XCTAssertEqual(testee.labelModel, .excused)
    }

    func test_labelModel_whenCustom_shouldReturnCustomWithName() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .custom(id: testData.customStatusId, name: testData.customStatusName)
        )

        XCTAssertEqual(testee.labelModel, .custom(testData.customStatusName))
    }

    func test_labelModel_whenLate_shouldReturnLate() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .late
        )

        XCTAssertEqual(testee.labelModel, .late)
    }

    func test_labelModel_whenMissing_shouldReturnMissing() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .missing
        )

        XCTAssertEqual(testee.labelModel, .missing)
    }

    func test_labelModel_whenHasGrade_shouldReturnGraded() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: true,
            gradeStatus: nil
        )

        XCTAssertEqual(testee.labelModel, .graded)
    }

    func test_labelModel_whenSubmitted_shouldReturnSubmitted() {
        let testee = SubmissionStatus.make(
            isSubmitted: true,
            hasGrade: false,
            gradeStatus: nil
        )

        XCTAssertEqual(testee.labelModel, .submitted)
    }

    func test_labelModel_whenOnPaper_shouldReturnOnPaper() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: .onPaper
        )

        XCTAssertEqual(testee.labelModel, .onPaper)
    }

    func test_labelModel_whenNoSubmission_shouldReturnNoSubmission() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: .noSubmission
        )

        XCTAssertEqual(testee.labelModel, .noSubmission)
    }

    func test_labelModel_whenNotGradable_shouldReturnNotGradable() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: .notGradable
        )

        XCTAssertEqual(testee.labelModel, .notGradable)
    }

    func test_labelModel_whenNotSubmitted_shouldReturnNotSubmitted() {
        let testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil,
            nonSubmittableType: nil
        )

        XCTAssertEqual(testee.labelModel, .notSubmitted)
    }

    func test_labelModel_shouldRespectPriorityOrder() {
        let testee = SubmissionStatus.make(
            isSubmitted: true,
            hasGrade: true,
            gradeStatus: .excused,
            nonSubmittableType: .onPaper
        )

        XCTAssertEqual(testee.labelModel, .excused)
    }

    // MARK: - View Model - uiImageIcon

    func test_uiImageIcon_shouldMatchLabelModelIcon() {
        var testee = SubmissionStatus.make(
            hasGrade: true
        )
        XCTAssertEqual(testee.uiImageIcon, .completeSolid)

        testee = SubmissionStatus.make(
            isSubmitted: true
        )
        XCTAssertEqual(testee.uiImageIcon, .completeLine)

        testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: nil
        )
        XCTAssertEqual(testee.uiImageIcon, .noSolid)

        testee = SubmissionStatus.make(
            customStatusId: "",
            customStatusName: ""
        )
        XCTAssertEqual(testee.uiImageIcon, .flagLine)

        testee = SubmissionStatus.make(
            isSubmitted: false,
            hasGrade: false,
            gradeStatus: .late
        )
        XCTAssertEqual(testee.uiImageIcon, .clockLine)
    }
}
