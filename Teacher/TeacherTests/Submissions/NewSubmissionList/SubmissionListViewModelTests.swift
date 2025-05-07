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

import XCTest
import Combine
import CombineSchedulers
import CoreData
import TestsFoundation
@testable import Core
@testable import Teacher

final class SubmissionListViewModelTests: TeacherTestCase {

    enum TestConstants {
        static let assignmentID = "12345"
        static let courseID = "67890"

        static var context: Context {
            return .course(courseID)
        }
    }

    private var scheduler: AnySchedulerOf<DispatchQueue>!
    private var viewModel: SubmissionListViewModel!
    private var interactor: MockSubmissionListInteractor!
    private var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        scheduler = .immediate
        interactor = MockSubmissionListInteractor(
            context: TestConstants.context,
            assignmentID: TestConstants.assignmentID
        )
        viewModel = SubmissionListViewModel(interactor: interactor, filterMode: .all, env: environment, scheduler: scheduler)
    }

    override func tearDown() {
        scheduler = nil
        viewModel = nil
        interactor = nil
        subscriptions.removeAll()
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.state, .loading)
        XCTAssertTrue(viewModel.sections.isEmpty)
    }

    func testAssignmentAndCourseFetch() {
        // Given
        let assignment = TestConstants.assignment(in: databaseClient)
        let course = TestConstants.course(in: databaseClient)

        // When
        interactor.assignmentSubject.send(assignment)
        interactor.courseSubject.send(course)

        // Then
        XCTAssertEqual(viewModel.assignment, assignment)
        XCTAssertEqual(viewModel.course, course)
    }

    func testFetchSubmissionsEmpty() {
        // When
        interactor.submissionsSubject.send([])
        // Then
        XCTAssertEqual(viewModel.sections.count, 0)
        XCTAssertEqual(viewModel.state, .empty)
    }

    func testFetchSubmissionsSuccess() {
        // Given
        let mocks = TestConstants.createSubmissions(
            in: databaseClient,
            count: 3,
            customizer: { (submission, index, client) in
                switch index {
                case 0:
                    submission.userID = "u0"
                    submission.user = User.save(.make(id: "u0", name: "John"), in: client)
                    submission.workflowState = .submitted
                    submission.score = nil
                    submission.submittedAt = Date()
                case 1:
                    submission.userID = "u1"
                    submission.user = User.save(.make(id: "u1", name: "Jane"), in: client)
                    submission.workflowState = .unsubmitted
                    submission.score = nil
                default:
                    submission.userID = "u2"
                    submission.user = User.save(.make(id: "u2", name: "Smith"), in: client)
                    submission.workflowState = .graded
                    submission.score = 0.5
                    submission.submittedAt = Date()
                }
            }
        )

        // When
        interactor.submissionsSubject.send(mocks)

        // Then
        XCTAssertEqual(viewModel.sections.count, 3)
        XCTAssertEqual(viewModel.state, .data)
    }

    func testSearchTextFiltering() {
        // Given
        let mocks = TestConstants.createSubmissions(
            in: databaseClient,
            count: 3,
            customizer: { (submission, index, client) in
                switch index {
                case 0:
                    submission.userID = "u0"
                    submission.user = User.save(.make(id: "u0", name: "John Doe"), in: client)
                    submission.workflowState = .submitted
                    submission.score = nil
                    submission.submittedAt = Date()
                default:
                    submission.userID = "u1"
                    submission.user = User.save(.make(id: "u1", name: "Jane Smith"), in: client)
                    submission.workflowState = .unsubmitted
                    submission.score = nil
                }
            }
        )

        // When
        interactor.submissionsSubject.send(mocks)
        viewModel.searchText = "Jane"

        // Then
        XCTAssertEqual(viewModel.sections.count, 1)
        XCTAssertEqual(viewModel.sections.first?.kind, .unsubmitted)
    }

    func testFilterModeChange() {
        viewModel.filterMode = .graded
        XCTAssertEqual(interactor.appliedFilters, [.graded])
    }

    func testRefresh() async {
        await viewModel.refresh()
        await viewModel.refresh()
        await viewModel.refresh()
        XCTAssertEqual(interactor.refreshCalls, 3)
    }

    func testMessageUsers() throws {
        // Given
        let course = TestConstants.course(in: databaseClient)
        let assignment = TestConstants.assignment(in: databaseClient)
        let mocks = TestConstants.createSubmissions(
            in: databaseClient,
            count: 2,
            customizer: { (submission, index, client) in
                switch index {
                case 0:
                    submission.userID = "u0"
                    submission.user = User.save(.make(id: "u0", name: "John Doe"), in: client)
                    submission.workflowState = .submitted
                    submission.score = nil
                    submission.submittedAt = Date()
                default:
                    submission.userID = "u1"
                    submission.user = User.save(.make(id: "u1", name: "Jane Smith"), in: client)
                    submission.workflowState = .unsubmitted
                    submission.score = nil
                }
            }
        )

        // When
        interactor.courseSubject.send(course)
        interactor.assignmentSubject.send(assignment)
        interactor.submissionsSubject.send(mocks)

        viewModel.messageUsers(from: WeakViewController())

        // Then
        let routedURL: URLComponents = try XCTUnwrap(router.calls.last?.0)
        let recipientNames = routedURL
            .queryValue(for: ComposeMessageOptions.QueryParameterKey.recipientNamesContent.rawValue)?
            .components(separatedBy: ",")

        XCTAssertEqual(routedURL.path, "/conversations/compose")
        XCTAssertEqual(recipientNames, ["John Doe", "Jane Smith"].compactMap { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) })
    }

    func testOpenPostPolicy() throws {
        // When
        viewModel.openPostPolicy(from: WeakViewController())

        // Then
        let routedURL: URLComponents = try XCTUnwrap(router.calls.last?.0)
        let expectedPath = [
            "",
            TestConstants.context.pathComponent,
            "assignments",
            TestConstants.assignmentID,
            "post_policy"
        ].joined(separator: "/")

        XCTAssertEqual(routedURL.path, expectedPath)
    }

    func testDidTapSubmissionRow() throws {
        // Given
        let assignment = TestConstants.assignment(in: databaseClient)
        let mockSubmission = try XCTUnwrap(
            TestConstants
                .createSubmissions(in: databaseClient, count: 1, customizer: { submission, _, client in
                    submission.userID = "u0"
                    submission.user = User.save(.make(id: "u0", name: "John Doe"), in: client)
                    submission.workflowState = .submitted
                    submission.score = nil
                    submission.submittedAt = Date()
                })
                .first
        )

        let mockItem = SubmissionListItem(submission: mockSubmission, assignment: assignment, order: 1)

        // When
        interactor.assignmentSubject.send(assignment)
        viewModel.didTapSubmissionRow(mockItem, from: WeakViewController())

        // Then
        var routedURL: URLComponents = try XCTUnwrap(router.calls.last?.0)
        let expectedPath = [
            "",
            TestConstants.context.pathComponent,
            "assignments",
            TestConstants.assignmentID,
            "submissions",
            mockItem.originalUserID
        ].joined(separator: "/")

        XCTAssertEqual(routedURL.path, expectedPath)
        XCTAssertNil(routedURL.query)

        // When
        viewModel.filterMode = .needsGrading
        viewModel.didTapSubmissionRow(mockItem, from: WeakViewController())

        // Then
        routedURL = try XCTUnwrap(router.calls.last?.0)

        let expectedFilters = SubmissionFilterMode
            .needsGrading
            .filters
            .map { $0.rawValue }
            .joined(separator: ",")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        XCTAssertEqual(routedURL.query, "filter=\(expectedFilters)")
    }
}

// MARK: - Mocking

extension SubmissionListViewModelTests.TestConstants {

    static func assignment(in client: NSManagedObjectContext) -> Assignment {
        let assignment = client.bring(\Assignment.id, equals: assignmentID)
        assignment.id = assignmentID
        assignment.courseID = courseID
        assignment.name = "Test Assignment"
        return assignment
    }

    static func course(in client: NSManagedObjectContext) -> Course {
        let course = client.bring(\Course.id, equals: courseID)
        course.id = courseID
        course.name = "Test Course"
        return course
    }

    static func createSubmissions(in client: NSManagedObjectContext, count: Int, customizer: (Submission, Int, NSManagedObjectContext) -> Void) -> [Submission] {

        var submissions = [Submission]()
        for i in 0 ..< count {
            let submission = Submission(context: client)
            submission.assignmentID = assignmentID
            submission.assignment = assignment(in: client)
            customizer(submission, i, client)
            submissions.append(submission)
        }
        return submissions
    }
}
