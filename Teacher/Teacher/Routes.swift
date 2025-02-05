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

import Core

let router = Router(routes: [
    RouteHandler("/accounts/:accountID/terms_of_service") { _, _, _ in
        return TermsOfServiceViewController()
    },

    RouteHandler("/act-as-user") { _, _, _ in
        guard let loginDelegate = AppEnvironment.shared.loginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate)
    },
    RouteHandler("/act-as-user/:userID") { _, params, _ in
        guard let loginDelegate = AppEnvironment.shared.loginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate, userID: params["userID"])
    },

    RouteHandler("/calendar") { url, _, _ in
        if let eventID = url.queryItems?.first(where: { $0.name == "event_id" })?.value {
            return PlannerAssembly.makeEventDetailsViewController(eventId: eventID)
       }
       let controller = PlannerViewController.create()
       controller.view.tintColor = Brand.shared.primary
       return controller
    },

    RouteHandler("/calendar_events/:eventID") { _, params, _ in
        guard let eventID = params["eventID"] else { return nil }
        return PlannerAssembly.makeEventDetailsViewController(eventId: eventID)
    },

    RouteHandler("/:context/:contextID/calendar_events/:eventID") { _, params, _ in
        guard let eventID = params["eventID"] else { return nil }
        return PlannerAssembly.makeEventDetailsViewController(eventId: eventID)
    },

    RouteHandler("/conversations"),
    RouteHandler("/conversations/compose") { url, _, _ in
        if let queryItems = url.queryItems {
            return ComposeMessageAssembly.makeComposeMessageViewController(queryItems: queryItems)
        } else {
            return ComposeMessageAssembly.makeComposeMessageViewController()
        }
    },

    RouteHandler("/conversations/:conversationID") { _, params, userInfo in
        guard let conversationID = params["conversationID"] else { return nil }
        let allowArchive: Bool = {
            if let userInfo, let allowArchiveParam = userInfo["allowArchive"] as? Bool {
                return allowArchiveParam
            } else {
                return true
            }
        }()
        return MessageDetailsAssembly.makeViewController(
            env: AppEnvironment.shared,
            conversationID: conversationID,
            allowArchive: allowArchive
        )
    },

    RouteHandler("/courses") { _, _, _ in AllCoursesAssembly.makeCourseListViewController(env: .shared) },

    RouteHandler("/courses/:courseID", factory: courseDetails),
    RouteHandler("/courses/:courseID/tabs", factory: courseDetails),

    RouteHandler("/courses/:courseID/settings") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        let viewModel = CourseSettingsViewModel(context: context)
        return CoreHostingController(CourseSettingsView(viewModel: viewModel))
    },

    RouteHandler("/:context/:contextID/announcements") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return AnnouncementListViewController.create(context: context)
    },

    RouteHandler("/:context/:contextID/announcements/new") { url, _, userInfo in
        guard let context = Context(path: url.path) else { return nil }
        return DiscussionsAssembly.makeDiscussionCreateViewController(
            context: context,
            isAnnouncement: true,
            routeUserInfo: userInfo
        )
    },

    RouteHandler("/:context/:contextID/announcements/:announcementID/edit") { url, params, _ in
        guard let context = Context(path: url.path), let topicID = params["announcementID"] else { return nil }
        return DiscussionsAssembly.makeDiscussionEditViewController(
            context: context,
            topicID: topicID,
            isAnnouncement: true
        )
    },

    RouteHandler("/:context/:contextID/announcements/:announcementID", factory: discussionDetails),

    RouteHandler("/courses/:courseID/assignments") { url, _, _, env in
        guard let context = Context(path: url.path) else { return nil }
        let viewModel = AssignmentListViewModel(env: env, context: context)
        return CoreHostingController(AssignmentListScreen(viewModel: viewModel), env: env)
    },

    RouteHandler("/courses/:courseID/assignments/syllabus", factory: syllabus),
    RouteHandler("/courses/:courseID/syllabus", factory: syllabus),
    RouteHandler("/courses/:courseID/syllabus/edit") { url, params, _ in
        guard let context = Context(path: url.path), let courseID = params["courseID"] else { return nil }
        return CoreHostingController(SyllabusEditorView(context: context, courseID: courseID))
    },

    RouteHandler("/courses/:courseID/assignments/:assignmentID") { _, params, _, env in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return CoreHostingController(
            AssignmentDetailsView(env: env, courseID: courseID, assignmentID: assignmentID),
            env: env
        )
    },
    RouteHandler("/courses/:courseID/assignments/:assignmentID/edit") { _, params, _, env in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return CoreHostingController(
            AssignmentEditorView(courseID: courseID, assignmentID: assignmentID),
            env: env
        )
    },
    RouteHandler("/courses/:courseID/assignments/:assignmentID/due_dates") { _, params, _, env in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return AssignmentDueDatesAssembly
            .makeViewController(env: env, courseID: courseID, assignmentID: assignmentID)
    },

    RouteHandler("/courses/:courseID/assignments/:assignmentID/post_policy") { _, params, _ in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return PostSettingsViewController.create(courseID: courseID, assignmentID: assignmentID)
    },

    RouteHandler("/courses/:courseID/assignments/:assignmentID/submissions") { url, params, _, env in
        guard let context = Context(path: url.path), let assignmentID = params["assignmentID"] else { return nil }
        let filter = url.queryItems?.first { $0.name == "filter" }? .value?.components(separatedBy: ",").compactMap {
            GetSubmissions.Filter(rawValue: $0)
        } ?? []

        return SubmissionListViewController
            .create(
                env: env,
                context: context,
                assignmentID: assignmentID,
                filter: filter
            )
    },

    RouteHandler("/courses/:courseID/assignments/:assignmentID/submissions/:userID") { url, params, _, env in
        guard let context = Context(path: url.path) else { return nil }
        guard let assignmentID = params["assignmentID"], let userID = params["userID"] else { return nil }
        let filter = url.queryItems?.first { $0.name == "filter" }? .value?.components(separatedBy: ",").compactMap {
            GetSubmissions.Filter(rawValue: $0)
        } ?? []
        return SpeedGraderViewController(
            env: env,
            context: context,
            assignmentID: assignmentID,
            userID: userID,
            filter: filter
        )
    },

    RouteHandler("/courses/:courseID/attendance/:toolID") { _, params, _ in
        guard let courseID = params["courseID"], let toolID = params["toolID"] else { return nil }
        return AttendanceViewController(context: .course(courseID), toolID: toolID)
    },

    RouteHandler("/:context/:contextID/discussions") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return DiscussionListViewController.create(context: context)
    },
    RouteHandler("/:context/:contextID/discussion_topics") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return DiscussionListViewController.create(context: context)
    },

    RouteHandler("/:context/:contextID/discussion_topics/new") { url, _, userInfo in
        guard let context = Context(path: url.path) else { return nil }
        return DiscussionsAssembly.makeDiscussionCreateViewController(
            context: context,
            isAnnouncement: false,
            routeUserInfo: userInfo
        )
    },

    RouteHandler("/:context/:contextID/discussions/:discussionID", factory: discussionDetails),
    RouteHandler("/:context/:contextID/discussion_topics/:discussionID", factory: discussionDetails),

    RouteHandler("/:context/:contextID/discussion_topics/:discussionID/edit") { url, params, _ in
        guard let context = Context(path: url.path), let topicID = params["discussionID"] else { return nil }
        return DiscussionsAssembly.makeDiscussionEditViewController(
            context: context,
            topicID: topicID,
            isAnnouncement: false
        )
    },

    RouteHandler("/:context/:contextID/discussion_topics/:discussionID/reply") { url, params, _ in
        guard let context = Context(path: url.path), let topicID = params["discussionID"] else { return nil }
        return DiscussionReplyViewController.create(env: .shared, context: context, topicID: topicID)
    },

    RouteHandler("/:context/:contextID/discussion_topics/:discussionID/entries/:entryID/replies") { url, params, _ in
        guard
            let context = Context(path: url.path),
            let topicID = params["discussionID"],
            let entryID = params["entryID"]
        else { return nil }
        return DiscussionReplyViewController
            .create(env: .shared, context: context, topicID: topicID, replyToEntryID: entryID)
    },

    RouteHandler("/files", factory: fileList),
    RouteHandler("/:context/:contextID/files", factory: fileList),
    RouteHandler("/files/folder/*subFolder", factory: fileList),
    RouteHandler("/:context/:contextID/files/folder/*subFolder", factory: fileList),
    RouteHandler("/folders/:folderID/edit") { _, params, _ in
        guard let folderID = params["folderID"] else { return nil }
        return CoreHostingController(FileEditorView(folderID: folderID))
    },

    RouteHandler("/files/:fileID", factory: fileDetails),
    RouteHandler("/files/:fileID/download", factory: fileDetails),
    RouteHandler("/files/:fileID/preview", factory: fileDetails),
    RouteHandler("/files/:fileID/edit", factory: fileEditor),
    RouteHandler("/:context/:contextID/files/:fileID", factory: fileDetails),
    RouteHandler("/:context/:contextID/files/:fileID/download", factory: fileDetails),
    RouteHandler("/:context/:contextID/files/:fileID/preview", factory: fileDetails),
    RouteHandler("/:context/:contextID/files/:fileID/edit", factory: fileEditor),

    RouteHandler("/courses/:courseID/modules") { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return ModuleListViewController.create(courseID: courseID)
    },

    RouteHandler("/courses/:courseID/modules/:moduleID") { _, params, _ in
        guard let courseID = params["courseID"], let moduleID = params["moduleID"] else { return nil }
        return ModuleListViewController.create(courseID: courseID, moduleID: moduleID)
    },

    RouteHandler("/courses/:courseID/modules/:moduleID/items/:itemID") { url, params, _ in
        guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
        return ModuleItemSequenceViewController.create(
            env: .shared,
            courseID: courseID,
            assetType: .moduleItem,
            assetID: itemID,
            url: url
        )
    },

    RouteHandler("/courses/:courseID/modules/items/:itemID") { url, params, _ in
        guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
        return ModuleItemSequenceViewController.create(
            env: .shared,
            courseID: courseID,
            assetType: .moduleItem,
            assetID: itemID,
            url: url
        )
    },

    RouteHandler("/courses/:courseID/module_item_redirect/:itemID") { url, params, _ in
        guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
        return ModuleItemSequenceViewController.create(
            env: .shared,
            courseID: courseID,
            assetType: .moduleItem,
            assetID: itemID,
            url: url
        )
    },

    RouteHandler("/:context/:contextID/wiki") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return AppEnvironment.shared.router.match("\(context.pathComponent)/pages/front_page")
    },
    RouteHandler("/:context/:contextID/pages") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return PageListViewController.create(context: context, app: .teacher)
    },

    RouteHandler("/:context/:contextID/pages/new") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return CoreHostingController(PageEditorView(context: context))
    },

    RouteHandler("/:context/:contextID/pages/:url") { url, params, _ in
        guard let context = Context(path: url.path), let pageURL = params["url"] else { return nil }
        return PageDetailsViewController.create(context: context, pageURL: pageURL, app: .teacher)
    },
    RouteHandler("/:context/:contextID/wiki/:url") { url, params, _ in
        guard let context = Context(path: url.path), let pageURL = params["url"] else { return nil }
        return PageDetailsViewController.create(context: context, pageURL: pageURL, app: .teacher)
    },

    RouteHandler("/:context/:contextID/pages/:url/edit") { url, params, _ in
        guard let context = Context(path: url.path), let slug = params["url"] else { return nil }
        return CoreHostingController(PageEditorView(context: context, url: slug))
    },
    RouteHandler("/:context/:contextID/wiki/:url/edit") { url, params, _ in
        guard let context = Context(path: url.path), let slug = params["url"] else { return nil }
        return CoreHostingController(PageEditorView(context: context, url: slug))
    },

    RouteHandler("/courses/:courseID/quizzes") { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return QuizListViewController.create(courseID: courseID)
    },

    RouteHandler("/courses/:courseID/quizzes/:quizID") { _, params, _ in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        let viewModel = TeacherQuizDetailsViewModelLive(courseID: courseID, quizID: quizID)
        return CoreHostingController(TeacherQuizDetailsView(viewModel: viewModel))
    },
    RouteHandler("/courses/:courseID/quizzes/:quizID/preview") { _, params, _ in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        return QuizPreviewAssembly.makeQuizPreviewViewController(courseID: courseID, quizID: quizID)
    },
    RouteHandler("/courses/:courseID/quizzes/:quizID/edit") { _, params, _ in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        let viewModel = TeacherQuizEditorViewModelLive(courseID: courseID, quizID: quizID)
        return CoreHostingController(TeacherQuizEditorView(viewModel: viewModel))
    },
    RouteHandler("/courses/:courseID/quizzes/:quizID/submissions") { url, params, _ in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        let filter = QuizSubmissionListFilter(rawValue: url.queryValue(for: "filter"))
        return QuizSubmissionListAssembly.makeViewController(env: AppEnvironment.shared, courseID: courseID, quizID: quizID, filter: filter)
    },
    RouteHandler("/courses/:courseID/users") { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return PeopleListViewController.create(context: .course(courseID))
    },

    RouteHandler("/courses/:courseID/users/:userID") { _, params, userInfo in
        guard let courseID = params["courseID"], let userID = params["userID"] else { return nil }
        let isModal = isModalPresentation(userInfo)
        let viewModel = ContextCardViewModel(courseID: courseID, userID: userID, currentUserID: AppEnvironment.shared.currentSession?.userID ?? "", isModal: isModal)
        return CoreHostingController(ContextCardView(model: viewModel))
    },

    RouteHandler("/dev-menu") { _, _, _ in
        CoreHostingController(DeveloperMenuView())
    },

    RouteHandler("/dev-menu/experimental-features") { _, _, _ in
        ExperimentalFeaturesViewController()
    },

    RouteHandler("/dev-menu/pandas") { _, _, _ in
        CoreHostingController(PandaGallery())
    },

    RouteHandler("/dev-menu/website-preview") { _, _, _ in
        CoreHostingController(WebSitePreviewView())
    },

    RouteHandler("/dev-menu/snackbar") { _, _, _ in
        CoreHostingController(SnackBarTestView())
    },

    RouteHandler("/logs") { _, _, _ in
        return LogEventListViewController.create()
    },

    RouteHandler("/push-notifications") { _, _, _ in
        CoreHostingController(PushNotificationDebugView())
    },

    RouteHandler("/profile") { _, _, _ in
        return CoreHostingController(SideMenuView(.teacher), customization: SideMenuTransitioningDelegate.applyTransitionSettings)
    },

    RouteHandler("/profile/settings") { _, _, _ in
        return ProfileSettingsViewController.create()
    },

    RouteHandler("/support/problem") { _, _, _ in
        return ErrorReportViewController.create(type: .problem)
    },

    RouteHandler("/support/feature") { _, _, _ in
        return ErrorReportViewController.create(type: .feature)
    },

    RouteHandler("/wrong-app") { _, _, _ in
        guard let loginDelegate = AppEnvironment.shared.loginDelegate else { return nil }
        return WrongAppViewController.create(delegate: loginDelegate)
    },

    RouteHandler("/empty") { url, _, _ in
        let emptyViewController = EmptyViewController()

        if let contextColor = url.contextColor {
            emptyViewController.navBarStyle = .color(contextColor)
        }

        return emptyViewController
    },

    RouteHandler("/about") { _, _, _ in
        AboutAssembly.makeAboutViewController()
    }
])

private func discussionDetails(
    url: URLComponents,
    params: [String: String],
    userInfo: [String: Any]?
) -> UIViewController? {
    guard
        let context = Context(path: url.path),
        let discussionId = params["discussionID"] ?? params["announcementID"]
    else { return nil }

    if OfflineModeAssembly.make().isOfflineModeEnabled() {
        return DiscussionDetailsViewController.create(context: context, topicID: discussionId)
    } else {
        let isAnnouncement = (params["announcementID"] != nil)
        let webPageModel = DiscussionDetailsWebViewModel(
            discussionId: discussionId,
            isAnnouncement: isAnnouncement
        )
        let viewModel = EmbeddedWebPageContainerViewModel(
            context: context,
            webPageModel: webPageModel
        )
        return CoreHostingController(
            EmbeddedWebPageContainerScreen(
                viewModel: viewModel,
                isPullToRefreshEnabled: true
            )
        )
    }
}

private func fileList(url: URLComponents, params: [String: String], userInfo: [String: Any]?, environment: AppEnvironment) -> UIViewController? {
    guard url.queryItems?.contains(where: { $0.name == "preview" }) != true else {
        return fileDetails(url: url, params: params, userInfo: userInfo)
    }
    return FileListViewController.create(
        env: environment,
        context: Context(path: url.path) ?? .currentUser,
        path: params["subFolder"]
    )
}

private func fileDetails(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let fileID = url.queryItems?.first(where: { $0.name == "preview" })?.value ?? params["fileID"] else { return nil }
    let canEdit = url.queryItems?.first(where: { $0.name == "canEdit" })?.value?.boolValue ?? true
    return FileDetailsViewController.create(context: Context(path: url.path), fileID: fileID, originURL: url, canEdit: canEdit)
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
    let viewModel = CourseDetailsViewModel(context: context,
                                           offlineModeInteractor: OfflineModeAssembly.make())
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
