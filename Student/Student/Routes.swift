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

import Core

let router = Router(routes: [
    RouteHandler("/accounts/:accountID/terms_of_service") { _, _, _ in
        TermsOfServiceViewController()
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

    // Special Inbox Compose route to handle 'New Message' action. This action has different implementation in the Parent app
    RouteHandler("/conversations/new_message") { url, _, _ in
        return ComposeMessageAssembly.makeComposeMessageViewController(url: url)

    },

    RouteHandler("/conversations/compose") { url, _, _ in
        return ComposeMessageAssembly.makeComposeMessageViewController(url: url)
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

    RouteHandler("/groups/:groupID") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return GroupNavigationViewController.create(context: context)
    },
    RouteHandler("/groups/:groupID/tabs") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return GroupNavigationViewController.create(context: context)
    },

    RouteHandler("/:context/:contextID/activity_stream") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return ActivityStreamViewController.create(context: context)
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

    RouteHandler("/:context/:contextID/announcements/:announcementID", factory: discussionViewController),

    RouteHandler("/courses/:courseID/assignments", factory: { url, _, _, env in
        guard let context = Context(path: url.path) else { return nil }
        let viewModel = AssignmentListViewModel(env: env, context: context)
        return CoreHostingController(AssignmentListScreen(viewModel: viewModel), env: env)
    }),

    RouteHandler("/courses/:courseID/syllabus") { url, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return SyllabusTabViewController.create(context: Context(path: url.path), courseID: ID.expandTildeID(courseID))
    },

    RouteHandler("/courses/:courseID/assignments/:assignmentID") { url, params, _, env in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        if assignmentID == "syllabus" {
            return SyllabusTabViewController.create(context: Context(path: url.path), courseID: ID.expandTildeID(courseID))
        }
        if !url.originIsModuleItemDetails {
            return ModuleItemSequenceViewController.create(
                env: env,
                courseID: ID.expandTildeID(courseID),
                assetType: .assignment,
                assetID: ID.expandTildeID(assignmentID),
                url: url
            )
        }
        return AssignmentDetailsViewController.create(
            env: env,
            courseID: ID.expandTildeID(courseID),
            assignmentID: ID.expandTildeID(assignmentID),
            fragment: url.fragment
        )
    },

    RouteHandler("/courses/:courseID/assignments/:assignmentID/submissions") { url, params, _, env in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        let selectedAttempt = Int(url.queryValue(for: "selectedAttempt") ?? "")
        return SubmissionDetailsViewController.create(
            env: env,
            context: .course(ID.expandTildeID(courseID)),
            assignmentID: ID.expandTildeID(assignmentID),
            userID: "self",
            selectedAttempt: selectedAttempt
        )
    },

    RouteHandler("/courses/:courseID/assignments/:assignmentID/submissions/:userID") { url, params, _, env in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = params["userID"] else { return nil }
        if url.originIsCalendar || url.originIsNotification {
            return AssignmentDetailsViewController.create(
                env: env,
                courseID: ID.expandTildeID(courseID),
                assignmentID: ID.expandTildeID(assignmentID),
                fragment: url.fragment
            )
        } else {
            let selectedAttempt = Int(url.queryValue(for: "selectedAttempt") ?? "")
            return SubmissionDetailsViewController.create(
                env: env,
                context: .course(ID.expandTildeID(courseID)),
                assignmentID: ID.expandTildeID(assignmentID),
                userID: ID.expandTildeID(userID),
                selectedAttempt: selectedAttempt
            )
        }
    },

    // No native support, fall back to web
    // "/:context/:contextID/collaborations": { url, _ in },

    RouteHandler("/:context/:contextID/conferences") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return ConferenceListViewController.create(context: context)
    },
    RouteHandler("/:context/:contextID/conferences/:conferenceID") { url, params, _ in
        guard let context = Context(path: url.path), let id = params["conferenceID"] else { return nil }
        return ConferenceDetailsViewController.create(context: context, conferenceID: id)
    },

    RouteHandler("/:context/:contextID/conferences/:conferenceID/join") { url, _, _ in
        Router.open(url: url)
        return nil
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
    RouteHandler("/:context/:contextID/discussion_topics/:discussionID/edit") { url, params, _ in
        guard let context = Context(path: url.path), let topicID = params["discussionID"] else { return nil }
        return DiscussionsAssembly.makeDiscussionEditViewController(
            context: context,
            topicID: topicID,
            isAnnouncement: false
        )
    },

    RouteHandler("/:context/:contextID/discussion_topics/:discussionID/reply") { url, params, _, env in
        guard let context = Context(path: url.path), let topicID = params["discussionID"] else { return nil }
        return DiscussionReplyViewController.create(env: env, context: context, topicID: topicID)
    },
    RouteHandler("/:context/:contextID/discussion_topics/:discussionID/entries/:entryID/replies") { url, params, _, env in
        guard
            let context = Context(path: url.path),
            let discussionID = params["discussionID"],
            let entryID = params["entryID"]
        else { return nil }
        return DiscussionReplyViewController.create(env: env, context: context, topicID: discussionID, replyToEntryID: entryID)
    },

    RouteHandler("/:context/:contextID/discussions/:discussionID", factory: discussionViewController),
    RouteHandler("/:context/:contextID/discussion_topics/:discussionID", factory: discussionViewController),

    RouteHandler("/courses/:courseID/external_tools/:toolID") { _, params, _ in
        guard let courseID = params["courseID"], let toolID = params["toolID"] else { return nil }
        guard let vc = AppEnvironment.shared.window?.rootViewController?.topMostViewController() else { return nil }
        let tools = LTITools(context: .course(courseID), id: toolID, isQuizLTI: nil)
        tools.presentTool(from: vc, animated: true)
        return nil
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
    RouteHandler("/courses/:courseID/files/:section/:resourceID/:fileID/offline", factory: offlineFileDetails),

    RouteHandler("/courses/:courseID/grades") { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return GradListAssembly.makeGradeListViewController(
            env: AppEnvironment.shared,
            courseID: courseID,
            userID: AppEnvironment.shared.currentSession?.userID
        )
    },

    RouteHandler("/courses/:courseID/modules") { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return ModuleListViewController.create(courseID: courseID)
    },

    RouteHandler("/courses/:courseID/modules/:moduleID") { _, params, _ in
        guard let courseID = params["courseID"], let moduleID = params["moduleID"] else { return nil }
        return ModuleListViewController.create(courseID: courseID, moduleID: moduleID)
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

    // No native support, fall back to web
    // "/courses/:courseID/outcomes": { url, _ in },

    RouteHandler("/:context/:contextID/pages") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return PageListViewController.create(context: context, app: .student)
    },

    RouteHandler("/:context/:contextID/wiki") { url, _, _ in
        var url = url
        url.path = url.path.replacingOccurrences(of: "wiki", with: "pages/front_page")
        return AppEnvironment.shared.router.match(url)
    },
    RouteHandler("/:context/:contextID/front_page") { url, _, _ in
        var url = url
        url.path = url.path.replacingOccurrences(of: "front_page", with: "pages/front_page")
        return AppEnvironment.shared.router.match(url)
    },

    RouteHandler("/:context/:contextID/pages/new") { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return CoreHostingController(PageEditorView(context: context))
    },
    RouteHandler("/:context/:contextID/pages/:url", factory: pageViewController),
    RouteHandler("/:context/:contextID/wiki/:url", factory: pageViewController),
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
        return QuizListViewController.create(courseID: ID.expandTildeID(courseID))
    },

    RouteHandler("/courses/:courseID/quizzes/:quizID") { url, params, _ in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        if !url.originIsModuleItemDetails {
            return ModuleItemSequenceViewController.create(
                env: .shared,
                courseID: courseID,
                assetType: .quiz,
                assetID: quizID,
                url: url
            )
        }
        return StudentQuizDetailsViewController.create(courseID: courseID, quizID: quizID)
    },

    // No native support, fall back to web
    // "/courses/:courseID/settings": { url, _ in },

    RouteHandler("/courses/:courseID/users") { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return PeopleListViewController.create(context: .course(courseID))
    },

    RouteHandler("/groups/:groupID/users") { _, params, _ in
        guard let groupID = params["groupID"] else { return nil }
        return PeopleListViewController.create(context: .group(groupID))
    },

    RouteHandler("/courses/:courseID/users/:userID", factory: contextCard),
    RouteHandler("/groups/:groupID/users/:userID", factory: groupContextCard),

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
        LogEventListViewController.create()
    },

    RouteHandler("/offline/sync_picker") { _, _, _ in
        CourseSyncSelectorAssembly.makeViewController(env: .shared)
    },
    RouteHandler("/offline/sync_picker/:courseID") { _, params, _ in
        CourseSyncSelectorAssembly.makeViewController(env: .shared, courseID: params["courseID"])
    },
    RouteHandler("/offline/progress") { _, _, _ in
        CourseSyncProgressAssembly.makeViewController(env: .shared)
    },
    RouteHandler("/offline/settings") { _, _, _ in
        guard let sessionDefaults = AppEnvironment.shared.userDefaults else {
            return nil
        }
        return CourseSyncSettingsAssembly.makeViewController(sessionDefaults: sessionDefaults)
    },

    RouteHandler("/push-notifications") { _, _, _ in
        CoreHostingController(PushNotificationDebugView())
    },

    RouteHandler("/profile") { _, _, _ in
        CoreHostingController(SideMenuView(.student), customization: SideMenuTransitioningDelegate.applyTransitionSettings)
    },

    RouteHandler("/profile/settings") { _, _, _ in
        ProfileSettingsViewController.create(onElementaryViewToggleChanged: { () })
    },

    RouteHandler("/support/problem") { _, _, _ in
        ErrorReportViewController.create(type: .problem)
    },

    RouteHandler("/support/feature") { _, _, _ in
        ErrorReportViewController.create(type: .feature)
    },

    RouteHandler("/empty") { url, _, _ in
        let emptyViewController = EmptyViewController()

        if let contextColor = url.contextColor {
            emptyViewController.navBarStyle = .color(contextColor)
        }

        return emptyViewController
    },

    RouteHandler("/native-route/*route", factory: nativeFactory),
    RouteHandler("/native-route-master/*route", factory: nativeFactory),

    RouteHandler("/about") { _, _, _ in
        AboutAssembly.makeAboutViewController()
    }
], courseTabUrlInteractor: .init())

private func nativeFactory(url _: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let route = params["route"] else { return nil }
    return AppEnvironment.shared.router.match(route, userInfo: userInfo)
}

private func fileList(url: URLComponents, params: [String: String], userInfo: [String: Any]?, environment: AppEnvironment) -> UIViewController? {
    guard url.queryItems?.contains(where: { $0.name == "preview" }) != true else {
        return fileDetails(url: url, params: params, userInfo: userInfo, environment: environment)
    }
    return FileListViewController.create(
        env: environment,
        context: Context(path: url.path) ?? .currentUser,
        path: params["subFolder"]
    )
}

private func fileDetails(url: URLComponents, params: [String: String], userInfo _: [String: Any]?, environment: AppEnvironment) -> UIViewController? {
    guard let fileID = url.queryItems?.first(where: { $0.name == "preview" })?.value ?? params["fileID"] else { return nil }
    var context = Context(path: url.path)
    if let courseID = url.queryItems?.first(where: { $0.name == "courseID" })?.value {
        context = Context(.course, id: courseID)
    }
    let assignmentID = url.queryItems?.first(where: { $0.name == "assignmentID" })?.value
    if !url.originIsModuleItemDetails, !url.skipModuleItemSequence, let context = context, context.contextType == .course {
        return ModuleItemSequenceViewController.create(
            env: environment,
            courseID: context.id,
            assetType: .file,
            assetID: fileID,
            url: url
        )
    }
    return FileDetailsViewController.create(context: context, fileID: fileID, originURL: url, assignmentID: assignmentID)
}

private func offlineFileDetails(url _: URLComponents, params: [String: String], userInfo _: [String: Any]?) -> UIViewController? {
    guard let courseID = params["courseID"],
          let section = params["section"],
          let resourceID = params["resourceID"],
          let fileID = params["fileID"],
          let sessionID = AppEnvironment.shared.currentSession?.uniqueID
    else {
        return nil
    }
    let context = Context(.course, id: courseID)

    let fileSource = OfflineFileSource.privateFile(sessionID: sessionID, courseID: courseID, sectionName: section, resourceID: resourceID, fileID: fileID)
    return FileDetailsViewController.create(context: context, fileID: fileID, offlineFileSource: fileSource)
}

private func fileEditor(url: URLComponents, params: [String: String], userInfo _: [String: Any]?) -> UIViewController? {
    guard let fileID = params["fileID"] else { return nil }
    return CoreHostingController(FileEditorView(context: Context(path: url.path), fileID: fileID))
}

private func pageViewController(url: URLComponents, params: [String: String], userInfo _: [String: Any]?, env: AppEnvironment) -> UIViewController? {
    guard let context = Context(path: url.path), let pageURL = params["url"] else { return nil }
    if !url.originIsModuleItemDetails, context.contextType == .course {
        return ModuleItemSequenceViewController.create(
            env: env,
            courseID: context.id,
            assetType: .page,
            assetID: pageURL,
            url: url
        )
    }
    return PageDetailsViewController
        .create(context: context, pageURL: pageURL, app: .student, env: env)
}

private func discussionViewController(
    url: URLComponents,
    params: [String: String],
    userInfo _: [String: Any]?,
    environment: AppEnvironment
) -> UIViewController? {
    guard
        let context = Context(path: url.path),
        let discussionId = params["discussionID"] ?? params["announcementID"]
    else { return nil }

    if context.contextType == .course, !url.originIsModuleItemDetails {
        return ModuleItemSequenceViewController.create(
            env: environment,
            courseID: context.id,
            assetType: .discussion,
            assetID: discussionId,
            url: url
        )
    }

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

private func contextCard(url _: URLComponents, params: [String: String], userInfo _: [String: Any]?) -> UIViewController? {
    guard let courseID = params["courseID"], let userID = params["userID"] else { return nil }
    let currentUserID = AppEnvironment.shared.currentSession?.userID ?? ""
    let showSubmissions = (currentUserID == userID)
    let viewModel = ContextCardViewModel(courseID: courseID, userID: userID, currentUserID: currentUserID, isSubmissionRowsVisible: showSubmissions, isLastActivityVisible: false)
    return CoreHostingController(ContextCardView(model: viewModel))
}

private func groupContextCard(url _: URLComponents, params: [String: String], userInfo _: [String: Any]?) -> UIViewController? {
    guard let groupID = params["groupID"], let userID = params["userID"] else { return nil }
    let currentUserID = AppEnvironment.shared.currentSession?.userID ?? ""
    let viewModel = GroupContextCardViewModel(groupID: groupID, userID: userID, currentUserID: currentUserID)
    return CoreHostingController(GroupContextCardView(model: viewModel))
}

private func courseDetails(url: URLComponents, params: [String: String], userInfo _: [String: Any]?) -> UIViewController? {
    guard let context = Context(path: url.path),
          let courseID = context.courseId else { return nil }

    let regularCourseDetails: () -> UIViewController = {
        let viewModel = CourseDetailsViewModel(context: .course(courseID), offlineModeInteractor: OfflineModeAssembly.make())
        let client = AppEnvironment.shared.database.viewContext

        return CourseSmartSearchAssembly.makeHostController(
            courseID: courseID,
            color: context.color(in: client) ?? url.contextColor,
            containing: CourseDetailsView(viewModel: viewModel)
        )
    }
    let k5SubjectView = {
        CoreHostingController(K5SubjectView(context: context, selectedTabId: url.fragment))
    }

    guard AppEnvironment.shared.k5.isK5Enabled == true else {
        return regularCourseDetails()
    }

    guard let courseID = params["courseID"],
          let card = AppEnvironment.shared.subscribe(GetDashboardCards(showOnlyTeacherEnrollment: false)).all.first(where: { $0.id == courseID })
    else {
        return k5SubjectView()
    }

    return card.isK5Subject ? k5SubjectView() : regularCourseDetails()
}
