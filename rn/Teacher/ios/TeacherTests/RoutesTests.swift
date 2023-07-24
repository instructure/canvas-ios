//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import CanvasCore
@testable import Core
@testable import Teacher
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

    func testRoutes() {
        XCTAssert(router.match("/courses/2/attendance/5") is AttendanceViewController)
        XCTAssert(router.match("/courses") is CoreHostingController<CourseListView>)
        XCTAssert(router.match("/courses/2/modules") is ModuleListViewController)
        XCTAssert(router.match("/courses/2/modules/2") is ModuleListViewController)
        XCTAssert(router.match("/courses/3/pages") is PageListViewController)
        XCTAssert(router.match("/courses/8/users") is PeopleListViewController)
        XCTAssert(router.match("/courses/3/wiki") is PageDetailsViewController)
        XCTAssert(router.match("/groups/3/pages/page2") is PageDetailsViewController)
        XCTAssert(router.match("/groups/3/wiki/page2") is PageDetailsViewController)
        XCTAssert(router.match("/courses/7/modules/5/items/6") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/7/modules/items/6") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/9/module_item_redirect/8") is ModuleItemSequenceViewController)
        XCTAssert(router.match("/courses/2/announcements") is AnnouncementListViewController)
        XCTAssert(router.match("/courses/2/announcements/new") is CoreHostingController<DiscussionEditorView>)
        XCTAssert(router.match("/courses/2/announcements/3") is DiscussionDetailsViewController)
        XCTAssert(router.match("/courses/2/announcements/3/edit") is CoreHostingController<DiscussionEditorView>)
        XCTAssert(router.match("/courses/2/discussions") is DiscussionListViewController)
        XCTAssert(router.match("/courses/2/discussion_topics") is DiscussionListViewController)
        XCTAssert(router.match("/courses/2/discussion_topics/new") is CoreHostingController<DiscussionEditorView>)
        XCTAssert(router.match("/courses/2/discussion_topics/5/edit") is CoreHostingController<DiscussionEditorView>)
        XCTAssert(router.match("/courses/2/discussion_topics/3/reply") is DiscussionReplyViewController)
        XCTAssert(router.match("/courses/2/discussion_topics/3/entries/4/replies") is DiscussionReplyViewController)
        XCTAssert(router.match("/courses/1/assignments/1/submissions") is SubmissionListViewController)
        XCTAssert(router.match("/courses/1/assignments/1/submissions/1") is SpeedGraderViewController)
        XCTAssert(router.match("/courses/1/quizzes") is QuizListViewController)
        XCTAssert(router.match("/courses/1/quizzes/2") is CoreHostingController<QuizDetailsView<QuizDetailsViewModel>>)
        XCTAssert(router.match("/courses/1/quizzes/2/preview") is CoreHostingController<QuizPreviewView>)
        XCTAssert(router.match("/courses/1/quizzes/2/edit") is CoreHostingController<QuizEditorView<QuizEditorViewModel>>)
        XCTAssert(router.match("/courses/1/quizzes/2/submissions") is CoreHostingController<QuizSubmissionListView>)
        XCTAssert(router.match("/files") is FileListViewController)
        XCTAssert(router.match("/users/self/files") is FileListViewController)
        XCTAssert(router.match("/files/folder/f1") is FileListViewController)
        XCTAssert(router.match("/groups/2/files/folder/f1") is FileListViewController)
        XCTAssert(router.match("/folders/2/edit") is CoreHostingController<FileEditorView>)
        XCTAssert(router.match("/files/1/edit") is CoreHostingController<FileEditorView>)
        XCTAssert(router.match("/courses/1/files/1/edit") is CoreHostingController<FileEditorView>)
        XCTAssert(router.match("/files?preview=7") is FileDetailsViewController)
        XCTAssert(router.match("/files/1") is FileDetailsViewController)
        XCTAssert(router.match("/files/1/download") is FileDetailsViewController)
        XCTAssert(router.match("/files/1/preview") is FileDetailsViewController)
        XCTAssert(router.match("/users/1/files/1/download") is FileDetailsViewController)
        XCTAssert(router.match("/users/1/files/1/download?origin=globalAnnouncement") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/1") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/1/download") is FileDetailsViewController)
        XCTAssert(router.match("/courses/1/files/1/preview") is FileDetailsViewController)
        XCTAssert(router.match("/act-as-user") is ActAsUserViewController)
        XCTAssert(router.match("/act-as-user/1") is ActAsUserViewController)
        XCTAssert(router.match("/wrong-app") is WrongAppViewController)
        XCTAssert(router.match("/courses/1/assignments/2/post_policy") is PostSettingsViewController)
        XCTAssert(router.match("/profile") is CoreHostingController<SideMenuView>)
        XCTAssert(router.match("/profile/settings") is ProfileSettingsViewController)
        XCTAssert(router.match("/dev-menu/experimental-features") is ExperimentalFeaturesViewController)
        XCTAssert(router.match("/support/problem") is ErrorReportViewController)
        XCTAssert(router.match("/support/feature") is ErrorReportViewController)
        XCTAssert(router.match( "/courses/1/assignments/syllabus") is SyllabusTabViewController)
        XCTAssert(router.match( "/courses/1/syllabus") is SyllabusTabViewController)
        XCTAssert(router.match( "/courses/1/syllabus/edit") is CoreHostingController<SyllabusEditorView>)
    }

    func testNativeDiscussionDetailsRoute() {
        ExperimentalFeature.hybridDiscussionDetails.isEnabled = false
        XCTAssert(router.match("/courses/2/discussions/3") is DiscussionDetailsViewController)
        XCTAssert(router.match("/courses/2/discussion_topics/3") is DiscussionDetailsViewController)
    }

    func testHybridDiscussionDetailsRoute() {
        ExperimentalFeature.hybridDiscussionDetails.isEnabled = true
        let flag = FeatureFlag(context: AppEnvironment.shared.database.viewContext)
        flag.name = "react_discussions_post"
        flag.enabled = true
        flag.context = .course("2")

        XCTAssert(router.match("/courses/2/discussions/3") is CoreHostingController<EmbeddedWebPageView<EmbeddedWebPageViewModelLive>>)
        XCTAssert(router.match("/courses/2/discussion_topics/3") is CoreHostingController<EmbeddedWebPageView<EmbeddedWebPageViewModelLive>>)
    }

    func testNativeAnnouncementDiscussionDetailsRoute() {
        ExperimentalFeature.hybridDiscussionDetails.isEnabled = false
        XCTAssert(router.match("/courses/2/announcements/3") is DiscussionDetailsViewController)
    }

    func testHybridAnnouncementDiscussionDetailsRoute() {
        ExperimentalFeature.hybridDiscussionDetails.isEnabled = true
        let flag = FeatureFlag(context: AppEnvironment.shared.database.viewContext)
        flag.name = "react_discussions_post"
        flag.enabled = true
        flag.context = .course("2")

        XCTAssert(router.match("/courses/2/announcements/3") is CoreHostingController<EmbeddedWebPageView<EmbeddedWebPageViewModelLive>>)
    }
}
