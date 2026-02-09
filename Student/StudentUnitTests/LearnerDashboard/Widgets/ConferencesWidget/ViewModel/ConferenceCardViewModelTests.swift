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
        url: URL(string: "https://example.com/conference")!,
        route: "some/example/route"
    )
    private lazy var testData = Self.testData

    private var testee: ConferenceCardViewModel!
    private var snackBarViewModel: SnackBarViewModel!
    private var loginDelegate: TestLoginDelegate!

    override func setUp() {
        super.setUp()
        snackBarViewModel = .init()
        loginDelegate = .init()
        env.loginDelegate = loginDelegate
    }

    override func tearDown() {
        testee = nil
        snackBarViewModel = nil
        loginDelegate = nil
        super.tearDown()
    }

    // MARK: - Basic properties

    func test_basicProperties() {
        testee = makeViewModel(model: .make(
            id: testData.id,
            title: testData.title,
            contextName: testData.contextName
        ))

        XCTAssertEqual(testee.id, testData.id)
        XCTAssertEqual(testee.title, testData.title)
        XCTAssertEqual(testee.contextName, testData.contextName)
    }

    // MARK: - Join

    func test_didTapJoin_whenThereIsJoinUrl_shouldOpenExternalURL() {
        testee = makeViewModel(model: .make(
            joinRoute: testData.route,
            joinUrl: testData.url
        ))

        testee.didTapJoin(controller: .init())

        XCTAssertEqual(loginDelegate.externalURL, testData.url)
    }

    func test_didTapJoin_whenThereIsNoJoinUrl_shouldRouteToRoute() {
        testee = makeViewModel(model: .make(
            joinRoute: testData.route,
            joinUrl: nil
        ))
        let vc = UIViewController()

        testee.didTapJoin(controller: .init(vc))

        XCTAssertEqual(router.lastRoutedPath, testData.route)
        XCTAssertEqual(router.lastRoutedFromVC, vc)
        XCTAssertEqual(router.lastRoutedOptions?.isModal, true)
    }

    // MARK: - Dismiss

    func test_dismiss_shouldCallOnDismissWithConferenceId() {
        var dismissCalled = false
        var dismissedConferenceId: String?

        testee = makeViewModel(model: .make(id: testData.id)) { conferenceId in
            dismissCalled = true
            dismissedConferenceId = conferenceId
        }

        testee.didTapDismiss()

        XCTAssertEqual(dismissCalled, true)
        XCTAssertEqual(dismissedConferenceId, testData.id)
    }

    func test_dismiss_shouldShowSnackbar() {
        testee = makeViewModel(model: .make(
            id: testData.id,
            title: testData.title
        ))

        testee.didTapDismiss()

        XCTAssertEqual(snackBarViewModel.visibleSnack, "Dismissed \(testData.title)")
    }

    // MARK: - Equality

    func test_equality() {
        let testee1 = makeViewModel(model: .make(
            id: testData.id,
            title: testData.title,
            contextName: testData.contextName
        ))
        let testee2 = makeViewModel(model: .make(
            id: testData.id,
            title: testData.title,
            contextName: testData.contextName
        ))

        XCTAssertEqual(testee1, testee2)
    }

    func test_equality_whenDifferentId_shouldNotBeEqual() {
        let testee1 = makeViewModel(model: .make(id: "id1"))
        let testee2 = makeViewModel(model: .make(id: "id2"))

        XCTAssertNotEqual(testee1, testee2)
    }

    func test_equality_whenDifferentTitle_shouldNotBeEqual() {
        let testee1 = makeViewModel(model: .make(
            id: testData.id,
            title: "title1",
            contextName: testData.contextName
        ))
        let testee2 = makeViewModel(model: .make(
            id: testData.id,
            title: "title2",
            contextName: testData.contextName
        ))

        XCTAssertNotEqual(testee1, testee2)
    }

    func test_equality_whenDifferentContextName_shouldNotBeEqual() {
        let testee1 = makeViewModel(model: .make(
            id: testData.id,
            title: testData.title,
            contextName: "context1"
        ))
        let testee2 = makeViewModel(model: .make(
            id: testData.id,
            title: testData.title,
            contextName: "context2"
        ))

        XCTAssertNotEqual(testee1, testee2)
    }

    // MARK: - Private helpers

    private func makeViewModel(
        model: ConferencesWidgetItem = .make(),
        onDismiss: @escaping (String) -> Void = { _ in }
    ) -> ConferenceCardViewModel {
        ConferenceCardViewModel(
            model: model,
            snackBarViewModel: snackBarViewModel,
            environment: env,
            onDismiss: onDismiss
        )
    }
}
