//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

import CanvasCore
import Core

let router = Router(routes: HelmManager.shared.routeHandlers([
    "/accounts/:accountID/terms_of_service": { _, _, _ in
        return TermsOfServiceViewController()
    },

    "/act-as-user": { _, _, _ in
        guard let loginDelegate = AppEnvironment.shared.loginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate)
    },
    "/act-as-user/:userID": { _, params, _ in
        guard let loginDelegate = AppEnvironment.shared.loginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate, userID: params["userID"])
    },

    "/conversations": nil,
    "/conversations/compose": nil,
    "/conversations/:conversationID": nil,

    "/courses": { _, _, _ in CourseListAssembly.makeCourseListViewController() },

    "/courses/:courseID": courseDetails,
    "/courses/:courseID/tabs": courseDetails,

    "/courses/:courseID/settings": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        let viewModel = CourseSettingsViewModel(context: context)
        return CoreHostingController(CourseSettingsView(viewModel: viewModel))
    },

    "/:context/:contextID/announcements": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return AnnouncementListViewController.create(context: context)
    },

    "/:context/:contextID/announcements/new": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return CoreHostingController(DiscussionEditorView(context: context, topicID: nil, isAnnouncement: true))
    },

    "/:context/:contextID/announcements/:announcementID/edit": { url, params, _ in
        guard let context = Context(path: url.path), let topicID = params["announcementID"] else { return nil }
        return CoreHostingController(DiscussionEditorView(context: context, topicID: topicID, isAnnouncement: true))
    },

    "/:context/:contextID/announcements/:announcementID": discussionDetails,

    "/courses/:courseID/assignments": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        let viewModel = AssignmentListViewModel(context: context)
        return CoreHostingController(AssignmentListView(viewModel: viewModel))
    },

    "/courses/:courseID/assignments/syllabus": syllabus,
    "/courses/:courseID/syllabus": syllabus,
    "/courses/:courseID/syllabus/edit": { url, params, _ in
        guard let context = Context(path: url.path), let courseID = params["courseID"] else { return nil }
        return CoreHostingController(SyllabusEditorView(context: context, courseID: courseID))
    },

    "/courses/:courseID/assignments/:assignmentID": { _, params, _ in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return CoreHostingController(AssignmentDetailsView(courseID: courseID, assignmentID: assignmentID))
    },
    "/courses/:courseID/assignments/:assignmentID/edit": { _, params, _ in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return CoreHostingController(AssignmentEditorView(courseID: courseID, assignmentID: assignmentID))
    },
    "/courses/:courseID/assignments/:assignmentID/due_dates": { _, params, _ in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return AssignmentDueDatesAssembly.makeViewController(env: AppEnvironment.shared, courseID: courseID, assignmentID: assignmentID)
    },

    "/courses/:courseID/assignments/:assignmentID/post_policy": { _, params, _ in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return PostSettingsViewController.create(courseID: courseID, assignmentID: assignmentID)
    },

    "/courses/:courseID/assignments/:assignmentID/submissions": { url, params, _ in
        guard let context = Context(path: url.path), let assignmentID = params["assignmentID"] else { return nil }
        let filter = url.queryItems?.first { $0.name == "filter" }? .value?.components(separatedBy: ",").compactMap {
            GetSubmissions.Filter(rawValue: $0)
        } ?? []
        return SubmissionListViewController.create(context: context, assignmentID: assignmentID, filter: filter)
    },

    "/courses/:courseID/assignments/:assignmentID/submissions/:userID": { url, params, _ in
        guard let context = Context(path: url.path) else { return nil }
        guard let assignmentID = params["assignmentID"], let userID = params["userID"] else { return nil }
        let filter = url.queryItems?.first { $0.name == "filter" }? .value?.components(separatedBy: ",").compactMap {
            GetSubmissions.Filter(rawValue: $0)
        } ?? []
        return SpeedGraderViewController(context: context, assignmentID: assignmentID, userID: userID, filter: filter)
    },

    "/courses/:courseID/attendance/:toolID": { _, params, _ in
        guard let courseID = params["courseID"], let toolID = params["toolID"] else { return nil }
        return AttendanceViewController(context: .course(courseID), toolID: toolID)
    },

    "/:context/:contextID/discussions": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return DiscussionListViewController.create(context: context)
    },
    "/:context/:contextID/discussion_topics": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return DiscussionListViewController.create(context: context)
    },

    "/:context/:contextID/discussion_topics/new": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return CoreHostingController(DiscussionEditorView(context: context, topicID: nil, isAnnouncement: false))
    },

    "/:context/:contextID/discussions/:discussionID": discussionDetails,
    "/:context/:contextID/discussion_topics/:discussionID": discussionDetails,

    "/:context/:contextID/discussion_topics/:discussionID/edit": { url, params, _ in
        guard let context = Context(path: url.path), let topicID = params["discussionID"] else { return nil }
        return CoreHostingController(DiscussionEditorView(context: context, topicID: topicID, isAnnouncement: false))
    },

    "/:context/:contextID/discussion_topics/:discussionID/reply": { url, params, _ in
        guard let context = Context(path: url.path), let topicID = params["discussionID"] else { return nil }
        return DiscussionReplyViewController.create(context: context, topicID: topicID)
    },

    "/:context/:contextID/discussion_topics/:discussionID/entries/:entryID/replies": { url, params, _ in
        guard
            let context = Context(path: url.path),
            let topicID = params["discussionID"],
            let entryID = params["entryID"]
        else { return nil }
        return DiscussionReplyViewController.create(context: context, topicID: topicID, replyToEntryID: entryID)
    },

    "/files": fileList,
    "/:context/:contextID/files": fileList,
    "/files/folder/*subFolder": fileList,
    "/:context/:contextID/files/folder/*subFolder": fileList,
    "/folders/:folderID/edit": { _, params, _ in
        guard let folderID = params["folderID"] else { return nil }
        return CoreHostingController(FileEditorView(folderID: folderID))
    },

    "/files/:fileID": fileDetails,
    "/files/:fileID/download": fileDetails,
    "/files/:fileID/preview": fileDetails,
    "/files/:fileID/edit": fileEditor,
    "/:context/:contextID/files/:fileID": fileDetails,
    "/:context/:contextID/files/:fileID/download": fileDetails,
    "/:context/:contextID/files/:fileID/preview": fileDetails,
    "/:context/:contextID/files/:fileID/edit": fileEditor,

    "/courses/:courseID/modules": { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return ModuleListViewController.create(courseID: courseID)
    },

    "/courses/:courseID/modules/:moduleID": { _, params, _ in
        guard let courseID = params["courseID"], let moduleID = params["moduleID"] else { return nil }
        return ModuleListViewController.create(courseID: courseID, moduleID: moduleID)
    },

    "/courses/:courseID/modules/:moduleID/items/:itemID": { url, params, _ in
        guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
        return ModuleItemSequenceViewController.create(
            courseID: courseID,
            assetType: .moduleItem,
            assetID: itemID,
            url: url
        )
    },

    "/courses/:courseID/modules/items/:itemID": { url, params, _ in
        guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
        return ModuleItemSequenceViewController.create(
            courseID: courseID,
            assetType: .moduleItem,
            assetID: itemID,
            url: url
        )
    },

    "/courses/:courseID/module_item_redirect/:itemID": { url, params, _ in
        guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
        return ModuleItemSequenceViewController.create(
            courseID: courseID,
            assetType: .moduleItem,
            assetID: itemID,
            url: url
        )
    },

    "/:context/:contextID/wiki": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return AppEnvironment.shared.router.match("\(context.pathComponent)/pages/front_page")
    },
    "/:context/:contextID/pages": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return PageListViewController.create(context: context, app: .teacher)
    },

    "/:context/:contextID/pages/new": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return CoreHostingController(PageEditorView(context: context))
    },

    "/:context/:contextID/pages/:url": { url, params, _ in
        guard let context = Context(path: url.path), let pageURL = params["url"] else { return nil }
        return PageDetailsViewController.create(context: context, pageURL: pageURL, app: .teacher)
    },
    "/:context/:contextID/wiki/:url": { url, params, _ in
        guard let context = Context(path: url.path), let pageURL = params["url"] else { return nil }
        return PageDetailsViewController.create(context: context, pageURL: pageURL, app: .teacher)
    },

    "/:context/:contextID/pages/:url/edit": { url, params, _ in
        guard let context = Context(path: url.path), let slug = params["url"] else { return nil }
        return CoreHostingController(PageEditorView(context: context, url: slug))
    },
    "/:context/:contextID/wiki/:url/edit": { url, params, _ in
        guard let context = Context(path: url.path), let slug = params["url"] else { return nil }
        return CoreHostingController(PageEditorView(context: context, url: slug))
    },

    "/courses/:courseID/quizzes": { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return QuizListViewController.create(courseID: courseID)
    },

    "/courses/:courseID/quizzes/:quizID": { _, params, _ in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        let viewModel = QuizDetailsViewModel(courseID: courseID, quizID: quizID)
        return CoreHostingController(QuizDetailsView(viewModel: viewModel))
    },
    "/courses/:courseID/quizzes/:quizID/preview": { _, params, _ in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        return QuizPreviewAssembly.makeQuizPreviewViewController(courseID: courseID, quizID: quizID)
    },
    "/courses/:courseID/quizzes/:quizID/edit": { _, params, _ in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        let viewModel = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        return CoreHostingController(QuizEditorView(viewModel: viewModel))
    },
    "/courses/:courseID/quizzes/:quizID/submissions": { url, params, _ in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        let filter = QuizSubmissionListFilter(rawValue: url.queryValue(for: "filter"))
        return QuizSubmissionListAssembly.makeViewController(env: AppEnvironment.shared, courseID: courseID, quizID: quizID, filter: filter)
    },
    "/courses/:courseID/users": { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return PeopleListViewController.create(context: .course(courseID))
    },

    "/courses/:courseID/users/:userID": { _, params, userInfo in
        guard let courseID = params["courseID"], let userID = params["userID"] else { return nil }
        let isModal = isModalPresentation(userInfo)
        let viewModel = ContextCardViewModel(courseID: courseID, userID: userID, currentUserID: AppEnvironment.shared.currentSession?.userID ?? "", isModal: isModal)
        return CoreHostingController(ContextCardView(model: viewModel))
    },

    "/dev-menu": { _, _, _ in
        CoreHostingController(DeveloperMenuView())
    },

    "/dev-menu/experimental-features": { _, _, _ in
        let vc = ExperimentalFeaturesViewController()
        vc.afterToggle = {
            HelmManager.shared.reload()
        }
        return vc
    },

    "/dev-menu/pandas": { _, _, _ in
        CoreHostingController(PandaGallery())
    },

    "/dev-menu/website-preview": { _, _, _ in
        CoreHostingController(WebSitePreviewView())
    },

    "/dev-menu/snackbar": { _, _, _ in
        CoreHostingController(SnackBarTestView())
    },

    "/logs": { _, _, _ in
        return LogEventListViewController.create()
    },

    "/push-notifications": { _, _, _ in
        CoreHostingController(PushNotificationDebugView())
    },

    "/profile": { _, _, _ in
        return CoreHostingController(SideMenuView(.teacher), customization: SideMenuTransitioningDelegate.applyTransitionSettings)
    },

    "/profile/settings": { _, _, _ in
        return ProfileSettingsViewController.create()
    },

    "/support/problem": { _, _, _ in
        return ErrorReportViewController.create(type: .problem)
    },

    "/support/feature": { _, _, _ in
        return ErrorReportViewController.create(type: .feature)
    },

    "/wrong-app": { _, _, _ in
        guard let loginDelegate = AppEnvironment.shared.loginDelegate else { return nil }
        return WrongAppViewController.create(delegate: loginDelegate)
    },

    "/empty": { url, _, _ in
        let emptyViewController = EmptyViewController()

        if let contextColor = url.contextColor {
            emptyViewController.navBarStyle = .color(contextColor)
        }

        return emptyViewController
    },

    "/about": { _, _, _ in
        AboutAssembly.makeAboutViewController()
    },
]))

private func discussionDetails(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let context = Context(path: url.path) else { return nil }

    var webPageType: EmbeddedWebPageViewModelLive.EmbeddedWebPageType
    if let discussionID = params["discussionID"] {
        webPageType = .discussion(id: discussionID)
    } else if let announcementID = params["announcementID"] {
        webPageType = .announcement(id: announcementID)
    } else {
        return nil
    }

    if ExperimentalFeature.hybridDiscussionDetails.isEnabled,
       EmbeddedWebPageViewModelLive.isRedesignEnabled(in: context) {
        let viewModel = EmbeddedWebPageViewModelLive(
            context: context,
            webPageType: webPageType
        )
        return CoreHostingController(
            EmbeddedWebPageView(
                viewModel: viewModel,
                isPullToRefreshEnabled: true
            )
        )
    } else {
        return DiscussionDetailsViewController.create(context: context, topicID: webPageType.assetID)
    }
}

private func fileList(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard url.queryItems?.contains(where: { $0.name == "preview" }) != true else {
        return fileDetails(url: url, params: params, userInfo: userInfo)
    }
    return FileListViewController.create(
        context: Context(path: url.path) ?? .currentUser,
        path: params["subFolder"]
    )
}

private func fileDetails(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let fileID = url.queryItems?.first(where: { $0.name == "preview" })?.value ?? params["fileID"] else { return nil }
    return FileDetailsViewController.create(context: Context(path: url.path), fileID: fileID, originURL: url)
}

private func fileEditor(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let fileID = params["fileID"] else { return nil }
    return CoreHostingController(FileEditorView(context: Context(path: url.path), fileID: fileID))
}

private func syllabus(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let courseID = params["courseID"] else { return nil }
    return TeacherSyllabusTabViewController.create(context: Context(path: url.path), courseID: ID.expandTildeID(courseID))
}

private func courseDetails(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let context = Context(path: url.path) else { return nil }
    let viewModel = CourseDetailsViewModel(context: context)
    let viewController = CoreHostingController(CourseDetailsView(viewModel: viewModel))

    if let contextColor = url.contextColor {
        viewController.navigationBarStyle = .color(contextColor)
    }

    return viewController
}

// MARK: - Helpers

private func isModalPresentation(_ userInfo: [String: Any]?) -> Bool {
    let navigatorOptions = userInfo?["navigatorOptions"] as? [String: Any]
    return navigatorOptions?["modal"] as? Bool ?? false
}

// MARK: - HelmModules

extension ModuleListViewController: HelmModule {
    public var moduleName: String { return "/courses/:courseID/modules" }
}

extension WrongAppViewController: HelmModule {
    public var moduleName: String { return "/wrong-app" }
}
