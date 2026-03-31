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

@testable import Horizon
import XCTest

final class ReportBugFormValidatorTests: XCTestCase {

    private var testee: ReportBugFormValidator!

    override func setUp() {
        super.setUp()
        testee = ReportBugFormValidator()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_initialState_givenValidatorCreated_thenIsValidIsFalse() {
        XCTAssertEqual(testee.isValid, false)
        XCTAssertNil(testee.topicError)
        XCTAssertNil(testee.subjectError)
        XCTAssertNil(testee.descriptionError)
    }

    // MARK: - All Fields Empty

    func test_validationErrors_givenAllFieldsEmpty_thenAllErrorsAreSetAndIsValidIsFalse() {
        testee.validationErrors(
            selectedTopic: "",
            subject: "",
            description: ""
        )

        XCTAssertEqual(testee.isValid, false)
        XCTAssertEqual(testee.topicError, "Select a topic")
        XCTAssertEqual(testee.subjectError, "Enter a subject")
        XCTAssertEqual(testee.descriptionError, "Enter a description")
    }

    // MARK: - Individual Field Validation

    func test_validationErrors_givenOnlyTopicEmpty_thenOnlyTopicErrorIsSet() {
        testee.validationErrors(
            selectedTopic: "",
            subject: "Some subject",
            description: "Some description"
        )

        XCTAssertEqual(testee.isValid, false)
        XCTAssertEqual(testee.topicError, "Select a topic")
        XCTAssertNil(testee.subjectError)
        XCTAssertNil(testee.descriptionError)
    }

    func test_validationErrors_givenOnlySubjectEmpty_thenOnlySubjectErrorIsSet() {
        testee.validationErrors(
            selectedTopic: "General help",
            subject: "",
            description: "Some description"
        )

        XCTAssertEqual(testee.isValid, false)
        XCTAssertNil(testee.topicError)
        XCTAssertEqual(testee.subjectError, "Enter a subject")
        XCTAssertNil(testee.descriptionError)
    }

    func test_validationErrors_givenOnlyDescriptionEmpty_thenOnlyDescriptionErrorIsSet() {
        testee.validationErrors(
            selectedTopic: "General help",
            subject: "Some subject",
            description: ""
        )

        XCTAssertEqual(testee.isValid, false)
        XCTAssertNil(testee.topicError)
        XCTAssertNil(testee.subjectError)
        XCTAssertEqual(testee.descriptionError, "Enter a description")
    }

    // MARK: - All Fields Valid

    func test_validationErrors_givenAllFieldsValid_thenNoErrorsAndIsValidIsTrue() {
        testee.validationErrors(
            selectedTopic: "General help",
            subject: "Some subject",
            description: "Some description"
        )

        XCTAssertEqual(testee.isValid, true)
        XCTAssertNil(testee.topicError)
        XCTAssertNil(testee.subjectError)
        XCTAssertNil(testee.descriptionError)
    }

    // MARK: - Whitespace Handling

    func test_validationErrors_givenFieldsWithOnlyWhitespace_thenErrorsAreSet() {
        testee.validationErrors(
            selectedTopic: "   ",
            subject: "  \n  ",
            description: "\n\n"
        )

        XCTAssertEqual(testee.isValid, false)
        XCTAssertEqual(testee.topicError, "Select a topic")
        XCTAssertEqual(testee.subjectError, "Enter a subject")
        XCTAssertEqual(testee.descriptionError, "Enter a description")
    }

    func test_validationErrors_givenFieldsWithValidContentAndWhitespace_thenNoErrors() {
        testee.validationErrors(
            selectedTopic: "  General help  ",
            subject: "\nSome subject\n",
            description: "  Some description  "
        )

        XCTAssertEqual(testee.isValid, true)
        XCTAssertNil(testee.topicError)
        XCTAssertNil(testee.subjectError)
        XCTAssertNil(testee.descriptionError)
    }

    // MARK: - Multiple Validation Calls

    func test_validationErrors_givenMultipleCalls_thenErrorsAreUpdatedCorrectly() {
        testee.validationErrors(
            selectedTopic: "",
            subject: "",
            description: ""
        )

        XCTAssertEqual(testee.isValid, false)
        XCTAssertNotNil(testee.topicError)

        testee.validationErrors(
            selectedTopic: "General help",
            subject: "Some subject",
            description: "Some description"
        )

        XCTAssertEqual(testee.isValid, true)
        XCTAssertNil(testee.topicError)
        XCTAssertNil(testee.subjectError)
        XCTAssertNil(testee.descriptionError)
    }

    func test_validationErrors_givenValidThenInvalid_thenErrorsAreSetAgain() {
        testee.validationErrors(
            selectedTopic: "General help",
            subject: "Some subject",
            description: "Some description"
        )

        XCTAssertEqual(testee.isValid, true)

        testee.validationErrors(
            selectedTopic: "",
            subject: "Some subject",
            description: "Some description"
        )

        XCTAssertEqual(testee.isValid, false)
        XCTAssertNotNil(testee.topicError)
        XCTAssertNil(testee.subjectError)
        XCTAssertNil(testee.descriptionError)
    }

    // MARK: - Edge Cases

    func test_validationErrors_givenTopicAndSubjectValid_butDescriptionEmpty_thenIsValidIsFalse() {
        testee.validationErrors(
            selectedTopic: "General help",
            subject: "Some subject",
            description: ""
        )

        XCTAssertEqual(testee.isValid, false)
    }

    func test_validationErrors_givenTopicAndDescriptionValid_butSubjectEmpty_thenIsValidIsFalse() {
        testee.validationErrors(
            selectedTopic: "General help",
            subject: "",
            description: "Some description"
        )

        XCTAssertEqual(testee.isValid, false)
    }

    func test_validationErrors_givenSubjectAndDescriptionValid_butTopicEmpty_thenIsValidIsFalse() {
        testee.validationErrors(
            selectedTopic: "",
            subject: "Some subject",
            description: "Some description"
        )

        XCTAssertEqual(testee.isValid, false)
    }
}
