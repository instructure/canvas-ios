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
@testable import Student
@testable import TestsFoundation
import XCTest

final class ConferenceCardViewModelTests: StudentTestCase {

    private static let testData = (
        id: "conf1",
        title: "some title",
        contextName: "some contextName",
        courseId: "course1",
        groupId: "group1",
        externalURL: URL(string: "https://example.com/conference")!
    )
    private lazy var testData = Self.testData

    private var testee: ConferenceCardViewModel!
    private var environment: AppEnvironment!
    private var snackBarViewModel: SnackBarViewModel!
    private var dismissCalled: Bool!
    private var dismissedConferenceId: String?

    override func setUp() {
        super.setUp()
        environment = AppEnvironment.shared
        snackBarViewModel = SnackBarViewModel()
        dismissCalled = false
        dismissedConferenceId = nil
    }

    override func tearDown() {
        testee = nil
        environment = nil
        snackBarViewModel = nil
        dismissCalled = nil
        dismissedConferenceId = nil
        super.tearDown()
    }

    // MARK: - Basic properties

    func test_basicProperties() {
        testee = makeViewModel(
            id: testData.id,
            title: testData.title,
            contextName: testData.contextName,
            context: Context(.course, id: testData.courseId),
            joinURL: testData.externalURL
        )

        XCTAssertEqual(testee.id, testData.id)
        XCTAssertEqual(testee.title, testData.title)
        XCTAssertEqual(testee.contextName, testData.contextName)
        XCTAssertEqual(testee.context.id, testData.courseId)
        XCTAssertEqual(testee.joinURL, testData.externalURL)
    }

    // MARK: - Join route

    func test_joinRoute_shouldReturnCorrectPath() {
        // WHEN course context
        var testee = makeViewModel(
            id: testData.id,
            context: Context(.course, id: testData.courseId)
        )
        // THEN
        XCTAssertEqual(testee.joinRoute, "courses/\(testData.courseId)/conferences/\(testData.id)/join")

        // WHEN group context
        testee = makeViewModel(
            id: testData.id,
            context: Context(.group, id: testData.groupId)
        )
        // THEN
        XCTAssertEqual(testee.joinRoute, "groups/\(testData.groupId)/conferences/\(testData.id)/join")
    }

    // MARK: - Join

    func test_join_withExternalURL_shouldOpenExternalURL() {
        let mockLoginDelegate = MockLoginDelegate()
        environment.loginDelegate = mockLoginDelegate
        testee = makeViewModel(joinURL: testData.externalURL)

        testee.join()

        XCTAssertEqual(mockLoginDelegate.openedURL, testData.externalURL)
    }

    func test_join_withNoExternalURL_shouldDoNothing() {
        let mockLoginDelegate = MockLoginDelegate()
        environment.loginDelegate = mockLoginDelegate
        testee = makeViewModel(joinURL: nil)

        testee.join()

        XCTAssertEqual(mockLoginDelegate.openedURL, nil)
    }

    // MARK: - Dismiss

    func test_dismiss_shouldCallOnDismissWithConferenceId() {
        testee = makeViewModel(id: testData.id)

        testee.dismiss()

        XCTAssertEqual(dismissCalled, true)
        XCTAssertEqual(dismissedConferenceId, testData.id)
    }

    func test_dismiss_shouldShowSnackbar() {
        testee = makeViewModel(
            id: testData.id,
            title: testData.title
        )

        testee.dismiss()

        XCTAssertEqual(snackBarViewModel.visibleSnack, "Dismissed \(testData.title)")
    }

    // MARK: - Equality

    func test_equality() {
        let testee1 = makeViewModel(
            id: testData.id,
            title: testData.title,
            contextName: testData.contextName,
            joinURL: testData.externalURL
        )
        let testee2 = makeViewModel(
            id: testData.id,
            title: testData.title,
            contextName: testData.contextName,
            joinURL: testData.externalURL
        )

        XCTAssertEqual(testee1, testee2)
    }

    func test_equality_whenDifferentId_shouldNotBeEqual() {
        let testee1 = makeViewModel(id: "id1")
        let testee2 = makeViewModel(id: "id2")

        XCTAssertNotEqual(testee1, testee2)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        id: String = "conf1",
        title: String = "some title",
        contextName: String = "some contextName",
        context: Context = Context(.course, id: "course1"),
        joinURL: URL? = nil
    ) -> ConferenceCardViewModel {
        ConferenceCardViewModel(
            id: id,
            title: title,
            contextName: contextName,
            context: context,
            joinURL: joinURL,
            environment: environment,
            snackBarViewModel: snackBarViewModel,
            onDismiss: { [weak self] conferenceId in
                self?.dismissCalled = true
                self?.dismissedConferenceId = conferenceId
            }
        )
    }
}

private class MockLoginDelegate: LoginDelegate {
    var openedURL: URL?

    func openExternalURL(_ url: URL) {
        openedURL = url
    }

    func userDidLogin(session: LoginSession) {}
    func userDidLogout(session: LoginSession) {}
    func changeUser() {}
    func stopActing() {}
    func openSFAuthenticationSession(
        url: URL,
        callbackURLScheme: String?,
        completionHandler: @escaping (URL?, (any Error)?) -> Void
    ) {}
}
