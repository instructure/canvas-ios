//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
@testable import Core
@testable import Student
import TestsFoundation

class RoutesTests: XCTestCase {
    lazy var login = TestLogin()
    class TestLogin: LoginDelegate {
        func userDidLogin(session: LoginSession) {}
        func userDidLogout(session: LoginSession) {}

        var opened: URL?
        func openExternalURL(_ url: URL) {
            opened = url
        }
    }

    var api: API { AppEnvironment.shared.api }
    override func setUp() {
        super.setUp()
        API.resetMocks()
        AppEnvironment.shared.currentSession = LoginSession.make()
        AppEnvironment.shared.loginDelegate = login
        AppEnvironment.shared.router = router
    }

    override func tearDown() {
        let flags: [FeatureFlag] = AppEnvironment.shared.database.viewContext.fetch()
        AppEnvironment.shared.database.viewContext.delete(flags)
        super.tearDown()
    }

    func testRoutes() {
        XCTAssert(router.match("/act-as-user") is ActAsUserViewController)
        XCTAssertEqual((router.match("/act-as-user/3") as? ActAsUserViewController)?.initialUserID, "3")

        XCTAssert(router.match("/calendar") is PlannerViewController)
        XCTAssert(router.match("/calendar?event_id=7") is CoreHostingController<CalendarEventDetailsScreen>)
        XCTAssert(router.match("/calendar_events/7") is CoreHostingController<CalendarEventDetailsScreen>)

        XCTAssert(router.match("/conversations/1") is CoreHostingController<MessageDetailsView>)
        XCTAssert(router.match("/conversations/compose") is CoreHostingController<ComposeMessageView>)

        XCTAssert(router.match("/courses") is CoreHostingController<AllCoursesView>)

        XCTAssert(router.match("/courses/2/announcements") is AnnouncementListViewController)
        XCTAssert(router.match("/courses/2/announcements/new") is CoreHostingController<EmbeddedWebPageContainerScreen>)
        XCTAssert(router.match("/courses/2/announcements/3/edit") is CoreHostingController<EmbeddedWebPageContainerScreen>)

        XCTAssert(router.match("/courses/2/discussions") is DiscussionListViewController)
        XCTAssert(router.match("/courses/2/discussion_topics") is DiscussionListViewController)
        XCTAssert(router.match("/courses/2/discussion_topics/new") is CoreHostingController<EmbeddedWebPageContainerScreen>)
        XCTAssert(router.match("/courses/2/discussion_topics/5/edit") is CoreHostingController<EmbeddedWebPageContainerScreen>)

        XCTAssert(router.match("/courses/1/assignments") is CoreHostingController<AssignmentListScreen>)
        XCTAssert(router.match("/courses/2/assignments/3") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/assignments/1/submissions/2") is SubmissionDetailsViewController)

        XCTAssert(router.match("/courses/3/quizzes") is QuizListViewController)

        XCTAssert(router.match("/groups/7") is GroupNavigationViewController)

        XCTAssert(router.match("/logs") is LogEventListViewController)

        XCTAssert(router.match("/courses/1/users") is PeopleListViewController)
        XCTAssert(router.match("/courses/1/users/1") is CoreHostingController<ContextCardView>)
        XCTAssert(router.match("/groups/1/users") is PeopleListViewController)
        XCTAssert(router.match("/groups/1/users/1") is CoreHostingController<GroupContextCardView>)

        XCTAssert(router.match("/courses/1/modules") is ModuleListViewController)
        XCTAssert(router.match("/courses/1/modules/1") is ModuleListViewController)

        XCTAssert(router.match("/users/1/files/2") is FileDetailsViewController)
        XCTAssert(router.match("/users/1/files/2?origin=globalAnnouncement") is FileDetailsViewController)
    }

    func testNativeDiscussionDetailsRoute() {
        let mockInteractor = OfflineModeInteractorMock(mockIsInOfflineMode: true)
        OfflineModeAssembly.mock(mockInteractor)

        XCTAssert(router.match("/courses/2/discussions/3?origin=module_item_details") is DiscussionDetailsViewController)
        XCTAssert(router.match("/courses/2/discussion_topics/3?origin=module_item_details") is DiscussionDetailsViewController)
    }

    func testHybridDiscussionDetailsRouteWhenDeviceIsOnline() {
        let mockInteractor = OfflineModeInteractorMock(mockIsInOfflineMode: false)
        OfflineModeAssembly.mock(mockInteractor)

        XCTAssert(router.match("/courses/2/discussions/3?origin=module_item_details") is CoreHostingController<EmbeddedWebPageContainerScreen>)
        XCTAssert(router.match("/courses/2/discussion_topics/3?origin=module_item_details") is CoreHostingController<EmbeddedWebPageContainerScreen>)
    }

    func testNativeGroupDiscussionDetailsRouteWhenDeviceIsOffline() {
        let mockInteractor = OfflineModeInteractorMock(mockIsInOfflineMode: true)
        OfflineModeAssembly.mock(mockInteractor)

        XCTAssert(router.match("/groups/2/discussions/3?origin=module_item_details") is DiscussionDetailsViewController)
        XCTAssert(router.match("/groups/2/discussion_topics/3?origin=module_item_details") is DiscussionDetailsViewController)
    }

    func testHybridGroupDiscussionDetailsRouteWhenDeviceIsOnline() {
        let mockInteractor = OfflineModeInteractorMock(mockIsInOfflineMode: false)
        OfflineModeAssembly.mock(mockInteractor)

        XCTAssert(router.match("/groups/2/discussions/3?origin=module_item_details") is CoreHostingController<EmbeddedWebPageContainerScreen>)
        XCTAssert(router.match("/groups/2/discussion_topics/3?origin=module_item_details") is CoreHostingController<EmbeddedWebPageContainerScreen>)
    }

    func testNativeAnnouncementDiscussionDetailsRoute() {
        let mockInteractor = OfflineModeInteractorMock(mockIsInOfflineMode: true)
        OfflineModeAssembly.mock(mockInteractor)

        XCTAssert(router.match("/courses/2/announcements/3?origin=module_item_details") is DiscussionDetailsViewController)
    }

    func testHybridAnnouncementDiscussionDetailsRouteWhenDeviceIsOnline() {
        let mockInteractor = OfflineModeInteractorMock(mockIsInOfflineMode: false)
        OfflineModeAssembly.mock(mockInteractor)

        XCTAssert(router.match("/courses/2/announcements/3?origin=module_item_details") is CoreHostingController<EmbeddedWebPageContainerScreen>)
    }

    func testNativeGroupAnnouncementDiscussionDetailsRouteWhenDeviceIsOffline() {
        let mockInteractor = OfflineModeInteractorMock(mockIsInOfflineMode: true)
        OfflineModeAssembly.mock(mockInteractor)

        XCTAssert(router.match("/groups/2/announcements/3") is DiscussionDetailsViewController)
    }

    func testHybridGroupAnnouncementDiscussionDetailsRouteWhenDeviceIsOnline() {
        let mockInteractor = OfflineModeInteractorMock(mockIsInOfflineMode: false)
        OfflineModeAssembly.mock(mockInteractor)

        XCTAssert(router.match("/groups/2/announcements/3?origin=module_item_details") is CoreHostingController<EmbeddedWebPageContainerScreen>)
    }

    func testOfflineScreenRoutes() {
        XCTAssert(router.match("/offline/sync_picker/132") is CoreHostingController<CourseSyncSelectorView>)
        XCTAssert(router.match("/offline/sync_picker") is CoreHostingController<CourseSyncSelectorView>)
        XCTAssert(router.match("/offline/settings") is CoreHostingController<CourseSyncSettingsView>)
    }

    // MARK: - K5 / non-K5 course detail route logic tests

    func testK5SubjectViewRoute() {
        // User and accounts are in K5 mode
        ExperimentalFeature.K5Dashboard.isEnabled = true

        let env = AppEnvironment.shared
        guard let session = env.currentSession else { XCTFail(); return }
        env.userDidLogin(session: session)
        env.k5.userDidLogin(isK5Account: true)
        env.userDefaults?.isElementaryViewEnabled = true

        // Opened course is a K5 one
        DashboardCard.save(.make(isK5Subject: true), position: 0, in: env.database.viewContext)

        XCTAssert(router.match("/courses/1") is CoreHostingController<K5SubjectView>)

        // Non-K5 account login
        env.k5.userDidLogin(isK5Account: false)
        XCTAssert(router.match("/courses/1") is CoreSearchController)
    }

    func testRegularCourseDetailsInK5Mode() {
        // User and accounts are in K5 mode
        ExperimentalFeature.K5Dashboard.isEnabled = true

        let env = AppEnvironment.shared
        guard let session = env.currentSession else { XCTFail(); return }
        env.userDidLogin(session: session)
        env.k5.userDidLogin(isK5Account: true)
        env.userDefaults?.isElementaryViewEnabled = true

        // Opened course is a non-K5 one
        DashboardCard.save(.make(isK5Subject: false), position: 0, in: env.database.viewContext)

        XCTAssert(router.match("/courses/1") is CoreSearchController)
    }

    func testMissingDashboardCardInfoWhenOpeningK5SubjectRoute() {
        // User and accounts are in K5 mode
        ExperimentalFeature.K5Dashboard.isEnabled = true
        let env = AppEnvironment.shared
        guard let session = env.currentSession else { XCTFail(); return }
        env.userDidLogin(session: session)
        env.k5.userDidLogin(isK5Account: true)
        env.userDefaults?.isElementaryViewEnabled = true

        // No cached data in CoreData
        XCTAssertTrue(env.database.viewContext.registeredObjects.isEmpty)

        XCTAssert(router.match("/courses/1") is CoreHostingController<K5SubjectView>)
    }

    // MARK: -

    func testModuleItems() {
        XCTAssert(router.match("/courses/1/assignments/syllabus") is SyllabusTabViewController)
        XCTAssert(router.match("/courses/1/assignments/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/assignments/2?origin=module_item_details") is AssignmentDetailsViewController)
        XCTAssert(router.match("/courses/1/discussions/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/discussions/2") is CoreHostingController<EmbeddedWebPageContainerScreen>)
        XCTAssert(router.match("/courses/1/discussion_topics/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/discussion_topics/2") is CoreHostingController<EmbeddedWebPageContainerScreen>)
        XCTAssert(router.match("/courses/1/discussion_topics/2?origin=module_item_details") is CoreHostingController<EmbeddedWebPageContainerScreen>)
        XCTAssert(router.match("/files/1") is FileDetailsViewController)
        XCTAssert(router.match("/files/1/download") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/files/2?skipModuleItemSequence=true") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/2/download") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/files/2/download") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/2?module_item_id=2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/files/2/download?module_item_id=2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/files/2?origin=module_item_details") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/2/preview") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/files/2/preview?module_item_id=2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/quizzes/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/module_item_redirect/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/modules/2/items/3") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/modules/items/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/1/pages/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/pages/2") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/wiki/2") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/groups/1/wiki/2") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/pages/2?origin=module_item_details") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/wiki/2?origin=module_item_details") is PageDetailsViewController)
        XCTAssert(router.match("/courses/1/quizzes/2?origin=module_item_details") is StudentQuizDetailsViewController)
    }

    func testFallbackNonHTTP() {
        let expected = URL(string: "https://canvas.instructure.com/not-a-native-route")!
        api.mock(GetWebSessionRequest(to: expected), value: .init(session_url: expected, requires_terms_acceptance: false))
        router.route(to: "canvas-courses://canvas.instructure.com/not-a-native-route", from: UIViewController())
        XCTAssertEqual(login.opened, expected)
    }

    func testFallbackRelative() {
        let expected = URL(string: "https://canvas.instructure.com/not-a-native-route")!
        api.mock(GetWebSessionRequest(to: expected), value: .init(session_url: expected, requires_terms_acceptance: false))
        AppEnvironment.shared.currentSession = LoginSession.make(baseURL: URL(string: "https://canvas.instructure.com")!)
        router.route(to: "not-a-native-route", from: UIViewController())
        XCTAssertEqual(login.opened?.absoluteURL, expected)
    }

    func testFallbackAbsoluteHTTPs() {
        AppEnvironment.shared.currentSession = LoginSession(baseURL: URL(string: "https://canvas.com")!,
                                                            userID: "",
                                                            userName: "")
        let expected = URL(string: "https://instructure.com")!
        api.mock(GetWebSessionRequest(to: URL(string: "https://canvas.com")!), value: .init(session_url: expected, requires_terms_acceptance: false))
        router.route(to: "https://canvas.com", from: UIViewController())
        XCTAssertEqual(login.opened, expected)
    }

    func testFallbackOpensAuthenticatedSession() {
        let expected = URL(string: "https://canvas.instructure.com/not-a-native-route?token=abcdefg")!
        api.mock(
            GetWebSessionRequest(to: URL(string: "https://canvas.instructure.com/not-a-native-route")),
            value: .init(session_url: expected, requires_terms_acceptance: false)
        )
        router.route(to: "canvas-courses://canvas.instructure.com/not-a-native-route", from: UIViewController())
        XCTAssertEqual(login.opened, expected)
    }

    func testFallbackAuthenticatedError() {
        AppEnvironment.shared.currentSession = LoginSession(baseURL: URL(string: "https://canvas.com")!,
                                                            userID: "",
                                                            userName: "")
        let expected = URL(string: "https://canvas.com")!
        api.mock(GetWebSessionRequest(to: expected), error: NSError.internalError())
        router.route(to: "https://canvas.com", from: UIViewController())
        XCTAssertEqual(login.opened, expected)
    }
}
