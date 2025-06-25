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
import XCTest

class UserNameModelTests: CoreTestCase {

    private enum TestConstants {
        static let userName = "some userName"
        static let initials = "T P"
        static let url = URL(string: "some/url")!
        static let groupName = "some groupName"
    }

    private var assignment: Assignment!
    private var submission: Submission!
    private var user: User!
    private var testee: UserNameModel!

    override func setUp() {
        super.setUp()

        assignment = Assignment(context: databaseClient)
        submission = Submission(context: databaseClient)
        user = User(context: databaseClient)

        submission.user = user
        submission.groupName = TestConstants.groupName
        submission.groupID = "something"

        user.name = TestConstants.userName
        user.avatarURL = TestConstants.url
    }

    override func tearDown() {
        assignment = nil
        submission = nil
        user = nil
        testee = nil
        super.tearDown()
    }

    // MARK: - Memberwise init

    func test_init_memberwise() {
        testee = .init(
            name: TestConstants.userName,
            initials: nil,
            avatarUrl: TestConstants.url,
            isGroup: true
        )

        XCTAssertEqual(testee.name, TestConstants.userName)
        XCTAssertEqual(testee.initials, nil)
        XCTAssertEqual(testee.avatarUrl, TestConstants.url)
        XCTAssertEqual(testee.isGroup, true)
    }

    func test_init_withIgnorableAvatarUrl() {
        testee = .make(avatarUrl: URL(string: "images/dotted_pic.png")!)

        XCTAssertEqual(testee.avatarUrl, nil)
    }

    func test_init_whenNameIsNil() {
        testee = .make(name: nil, isGroup: false)
        XCTAssertEqual(testee.name, "Student")

        testee = .make(name: nil, isGroup: true)
        XCTAssertEqual(testee.name, "Group")
    }

    // MARK: - User init

    func test_init_withUser() {
        let user = UserNameProviderMock(
            displayName: TestConstants.userName,
            initials: TestConstants.initials,
            avatarURL: TestConstants.url
        )

        testee = .init(user: user)

        XCTAssertEqual(testee.name, TestConstants.userName)
        XCTAssertEqual(testee.initials, TestConstants.initials)
        XCTAssertEqual(testee.avatarUrl, TestConstants.url)
    }

    // MARK: - Submission init

    func test_initWithSubmission_whenAnonymousUser() {
        testee = .init(submission: submission, isAnonymous: true, isGroup: false)
        XCTAssertEqual(testee.name, "Student")
        XCTAssertEqual(testee.initials, nil)
        XCTAssertEqual(testee.avatarUrl, nil)
        XCTAssertEqual(testee.isGroup, false)

        testee = .init(submission: submission, isAnonymous: true, isGroup: false, displayIndex: 42)
        XCTAssertEqual(testee.name, "Student 42")
        XCTAssertEqual(testee.initials, nil)
        XCTAssertEqual(testee.avatarUrl, nil)
        XCTAssertEqual(testee.isGroup, false)
    }

    func test_initWithSubmission_whenAnonymousGroup() {
        testee = .init(submission: submission, isAnonymous: true, isGroup: true)
        XCTAssertEqual(testee.name, "Group")
        XCTAssertEqual(testee.initials, nil)
        XCTAssertEqual(testee.avatarUrl, nil)
        XCTAssertEqual(testee.isGroup, true)

        testee = .init(submission: submission, isAnonymous: true, isGroup: true, displayIndex: 42)
        XCTAssertEqual(testee.name, "Group 42")
        XCTAssertEqual(testee.initials, nil)
        XCTAssertEqual(testee.avatarUrl, nil)
        XCTAssertEqual(testee.isGroup, true)
    }

    func test_initWithSubmission_whenNotAnonymousUser() {
        testee = .init(submission: submission, isAnonymous: false, isGroup: false)
        XCTAssertEqual(testee.name, TestConstants.userName)
        XCTAssertEqual(testee.initials, "SU")
        XCTAssertEqual(testee.avatarUrl, TestConstants.url)
        XCTAssertEqual(testee.isGroup, false)

        testee = .init(submission: submission, isAnonymous: false, isGroup: false, displayIndex: 42)
        XCTAssertEqual(testee.name, TestConstants.userName)
    }

    func test_initWithSubmission_whenNotAnonymousGroup() {
        testee = .init(submission: submission, isAnonymous: false, isGroup: true)
        XCTAssertEqual(testee.name, TestConstants.groupName)
        XCTAssertEqual(testee.initials, "SG")
        XCTAssertEqual(testee.avatarUrl, nil)
        XCTAssertEqual(testee.isGroup, true)

        testee = .init(submission: submission, isAnonymous: false, isGroup: true, displayIndex: 42)
        XCTAssertEqual(testee.name, TestConstants.groupName)
    }

    // MARK: - Submission and Assignment init

    func test_initWithSubmissionAndAssignment_whenAnonymousUser() {
        assignment.anonymizeStudents = true
        testee = .init(submission: submission, assignment: assignment)
        XCTAssertEqual(testee.name, "Student")
    }

    func test_initWithSubmissionAndAssignment_whenNotAnonymousUser() {
        assignment.anonymizeStudents = false
        testee = .init(submission: submission, assignment: assignment)
        XCTAssertEqual(testee.name, TestConstants.userName)

        testee = .init(submission: submission, assignment: nil)
        XCTAssertEqual(testee.name, TestConstants.userName)
    }

    func test_initWithSubmissionAndAssignment_whenGroupAssignment() {
        assignment.gradedIndividually = false
        submission.groupID = "something"
        testee = .init(submission: submission, assignment: assignment)
        XCTAssertEqual(testee.name, TestConstants.groupName)
    }

    func test_initWithSubmissionAndAssignment_whenNotGroupAssignment() {
        assignment.gradedIndividually = true
        submission.groupID = "something"
        testee = .init(submission: submission, assignment: assignment)
        XCTAssertEqual(testee.name, TestConstants.userName)

        submission.groupID = "something"
        testee = .init(submission: submission, assignment: nil)
        XCTAssertEqual(testee.name, TestConstants.userName)

        assignment.gradedIndividually = true
        submission.groupID = nil
        testee = .init(submission: submission, assignment: assignment)
        XCTAssertEqual(testee.name, TestConstants.userName)

        assignment.gradedIndividually = false
        submission.groupID = nil
        testee = .init(submission: submission, assignment: assignment)
        XCTAssertEqual(testee.name, TestConstants.userName)
    }
}

private struct UserNameProviderMock: UserNameProvider {
    var name: String = ""
    var displayName: String = ""
    var initials: String = ""
    var avatarURL: URL?
}
