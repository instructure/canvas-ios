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

    "/calendar": { url, _, _ in
        if let eventID = url.queryItems?.first(where: { $0.name == "event_id" })?.value {
           return CalendarEventDetailsViewController.create(eventID: eventID)
       }
       let controller = PlannerViewController.create()
       controller.view.tintColor = Brand.shared.primary
       return controller
    },

    "/calendar_events/:eventID": { _, params, _ in
        guard let eventID = params["eventID"] else { return nil }
        return CalendarEventDetailsViewController.create(eventID: eventID)
    },

    "/:context/:contextID/calendar_events/:eventID": { _, params, _ in
        guard let eventID = params["eventID"] else { return nil }
        return CalendarEventDetailsViewController.create(eventID: eventID)
    },

    "/conversations": nil,
    "/conversations/compose": nil,
    "/conversations/:conversationID": { url, params, userInfo in
        if ExperimentalFeature.nativeStudentInbox.isEnabled {
            guard let conversationID = params["conversationID"] else { return nil }
            return MessageDetailsAssembly.makeViewController(env: AppEnvironment.shared, conversationID: conversationID)
        } else {
            return HelmViewController(moduleName: "/conversations/:conversationID", url: url, params: params, userInfo: userInfo)
        }
    },

    "/courses": { _, _, _ in CourseListAssembly.makeCourseListViewController() },

    "/courses/:courseID": courseDetails,
    "/courses/:courseID/tabs": courseDetails,

    "/groups/:groupID": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return GroupNavigationViewController.create(context: context)
    },
    "/groups/:groupID/tabs": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return GroupNavigationViewController.create(context: context)
    },

    "/:context/:contextID/activity_stream": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return ActivityStreamViewController.create(context: context)
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

    "/:context/:contextID/announcements/:announcementID": discussionViewController,

    "/courses/:courseID/assignments": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        let viewModel = AssignmentListViewModel(context: context)
        return CoreHostingController(AssignmentListView(viewModel: viewModel))
    },

    "/courses/:courseID/syllabus": { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return SyllabusTabViewController.create(courseID: ID.expandTildeID(courseID))
    },

    "/courses/:courseID/assignments/:assignmentID": { url, params, _ in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        if assignmentID == "syllabus" {
            return SyllabusTabViewController.create(courseID: ID.expandTildeID(courseID))
        }
        if !url.originIsModuleItemDetails {
            return ModuleItemSequenceViewController.create(
                courseID: ID.expandTildeID(courseID),
                assetType: .assignment,
                assetID: ID.expandTildeID(assignmentID),
                url: url
            )
        }
        return AssignmentDetailsViewController.create(
            courseID: ID.expandTildeID(courseID),
            assignmentID: ID.expandTildeID(assignmentID),
            fragment: url.fragment
        )
    },

    "/courses/:courseID/assignments/:assignmentID/submissions": { _, params, _ in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return SubmissionDetailsViewController.create(
            context: .course(ID.expandTildeID(courseID)),
            assignmentID: ID.expandTildeID(assignmentID),
            userID: "self"
        )
    },

    "/courses/:courseID/assignments/:assignmentID/submissions/:userID": { url, params, _ in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = params["userID"] else { return nil }
        if url.originIsCalendar || url.originIsNotification {
            return AssignmentDetailsViewController.create(
                courseID: ID.expandTildeID(courseID),
                assignmentID: ID.expandTildeID(assignmentID),
                fragment: url.fragment
            )
        } else {
            return SubmissionDetailsViewController.create(
                context: .course(ID.expandTildeID(courseID)),
                assignmentID: ID.expandTildeID(assignmentID),
                userID: ID.expandTildeID(userID)
            )
        }
    },

    // No native support, fall back to web
    // "/:context/:contextID/collaborations": { url, _ in },

    "/:context/:contextID/conferences": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return ConferenceListViewController.create(context: context)
    },
    "/:context/:contextID/conferences/:conferenceID": { url, params, _ in
        guard let context = Context(path: url.path), let id = params["conferenceID"] else { return nil }
        return ConferenceDetailsViewController.create(context: context, conferenceID: id)
    },

    "/:context/:contextID/conferences/:conferenceID/join": { url, _, _ in
        Router.open(url: url)
        return nil
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
            let discussionID = params["discussionID"],
            let entryID = params["entryID"]
        else { return nil }
        return DiscussionReplyViewController.create(context: context, topicID: discussionID, replyToEntryID: entryID)
    },

    "/:context/:contextID/discussions/:discussionID": discussionViewController,
    "/:context/:contextID/discussion_topics/:discussionID": discussionViewController,

    "/courses/:courseID/external_tools/:toolID": { _, params, _ in
        guard let courseID = params["courseID"], let toolID = params["toolID"] else { return nil }
        guard let vc = HelmManager.shared.topMostViewController() else { return nil }
        let tools = LTITools(context: .course(courseID), id: toolID)
        tools.presentTool(from: vc, animated: true)
        return nil
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

    "/courses/:courseID/grades": { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return GradeListViewController.create(courseID: courseID)
    },

    "/courses/:courseID/modules": { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return ModuleListViewController.create(courseID: courseID)
    },

    "/courses/:courseID/modules/:moduleID": { _, params, _ in
        guard let courseID = params["courseID"], let moduleID = params["moduleID"] else { return nil }
        return ModuleListViewController.create(courseID: courseID, moduleID: moduleID)
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

    "/courses/:courseID/modules/:moduleID/items/:itemID": { url, params, _ in
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

    // No native support, fall back to web
    // "/courses/:courseID/outcomes": { url, _ in },

    "/:context/:contextID/pages": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return PageListViewController.create(context: context, app: .student)
    },

    "/:context/:contextID/wiki": { url, _, _ in
        var url = url
        url.path = url.path.replacingOccurrences(of: "wiki", with: "pages/front_page")
        return AppEnvironment.shared.router.match(url)
    },
    "/:context/:contextID/front_page": { url, _, _ in
        var url = url
        url.path = url.path.replacingOccurrences(of: "front_page", with: "pages/front_page")
        return AppEnvironment.shared.router.match(url)
    },

    "/:context/:contextID/pages/new": { url, _, _ in
        guard let context = Context(path: url.path) else { return nil }
        return CoreHostingController(PageEditorView(context: context))
    },
    "/:context/:contextID/pages/:url": pageViewController,
    "/:context/:contextID/wiki/:url": pageViewController,
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
        return QuizListViewController.create(courseID: ID.expandTildeID(courseID))
    },

    "/courses/:courseID/quizzes/:quizID": { url, params, _ in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        if !url.originIsModuleItemDetails {
            return ModuleItemSequenceViewController.create(
                courseID: courseID,
                assetType: .quiz,
                assetID: quizID,
                url: url
            )
        }
        return QuizDetailsViewController.create(courseID: courseID, quizID: quizID)
    },

    // No native support, fall back to web
    // "/courses/:courseID/settings": { url, _ in },

    "/courses/:courseID/users": { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        return PeopleListViewController.create(context: .course(courseID))
    },

    "/groups/:groupID/users": { _, params, _ in
        guard let groupID = params["groupID"] else { return nil }
        return PeopleListViewController.create(context: .group(groupID))
    },

    "/courses/:courseID/users/:userID": contextCard,
    "/groups/:groupID/users/:userID": groupContextCard,

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

    "/offline/sync_picker": { _, _, _ in
        CourseSyncSelectorAssembly.makeViewController(env: .shared)
    },
    "/offline/sync_picker/:courseID": { _, params, _ in
        CourseSyncSelectorAssembly.makeViewController(env: .shared, courseID: params["courseID"])
    },
    "/offline/progress": { _, _, _ in
        CourseSyncProgressAssembly.makeViewController(env: .shared)
    },
    "/offline/settings": { _, _, _ in
        guard let sessionDefaults = AppEnvironment.shared.userDefaults else {
            return nil
        }
        return CourseSyncSettingsAssembly.makeViewController(sessionDefaults: sessionDefaults)
    },

    "/push-notifications": { _, _, _ in
        CoreHostingController(PushNotificationDebugView())
    },

    "/profile": { _, _, _ in
        return CoreHostingController(SideMenuView(.student), customization: SideMenuTransitioningDelegate.applyTransitionSettings)
    },

    "/profile/settings": { _, _, _ in
        return ProfileSettingsViewController.create(onElementaryViewToggleChanged: {
            HelmManager.shared.reload()
        })
    },

    "/support/problem": { _, _, _ in
        return ErrorReportViewController.create(type: .problem)
    },

    "/support/feature": { _, _, _ in
        return ErrorReportViewController.create(type: .feature)
    },

    "/empty": { url, _, _ in
        let emptyViewController = EmptyViewController()

        if let contextColor = url.contextColor {
            emptyViewController.navBarStyle = .color(contextColor)
        }

        return emptyViewController
    },

    "/native-route/*route": nativeFactory,
    "/native-route-master/*route": nativeFactory,

    "/about": { _, _, _ in
        AboutAssembly.makeAboutViewController()
    },
]))

private func nativeFactory(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let route = params["route"] else { return nil }
    return AppEnvironment.shared.router.match(route, userInfo: userInfo)
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
    var context = Context(path: url.path)
    if let courseID = url.queryItems?.first(where: { $0.name == "courseID" })?.value {
        context = Context(.course, id: courseID)
    }
    let assignmentID = url.queryItems?.first(where: { $0.name == "assignmentID" })?.value
    if !url.originIsModuleItemDetails, !url.skipModuleItemSequence, let context = context, context.contextType == .course {
        return ModuleItemSequenceViewController.create(
            courseID: context.id,
            assetType: .file,
            assetID: fileID,
            url: url
        )
    }
    return FileDetailsViewController.create(context: context, fileID: fileID, originURL: url, assignmentID: assignmentID)
}

private func fileEditor(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let fileID = params["fileID"] else { return nil }
    return CoreHostingController(FileEditorView(context: Context(path: url.path), fileID: fileID))
}

private func pageViewController(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let context = Context(path: url.path), let pageURL = params["url"] else { return nil }
    if !url.originIsModuleItemDetails, context.contextType == .course {
        return ModuleItemSequenceViewController.create(
            courseID: context.id,
            assetType: .page,
            assetID: pageURL,
            url: url
        )
    }
    return PageDetailsViewController.create(context: context, pageURL: pageURL, app: .student)
}

private func discussionViewController(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let context = Context(path: url.path) else { return nil }

    var webPageType: EmbeddedWebPageViewModelLive.EmbeddedWebPageType
    if let discussionID = params["discussionID"] {
        webPageType = .discussion(id: discussionID)
    } else if let announcementID = params["announcementID"] {
        webPageType = .announcement(id: announcementID)
    } else {
        return nil
    }

    if context.contextType == .course, !url.originIsModuleItemDetails {
        return ModuleItemSequenceViewController.create(
            courseID: context.id,
            assetType: .discussion,
            assetID: webPageType.assetID,
            url: url
        )
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

private func contextCard(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let courseID = params["courseID"], let userID = params["userID"] else { return nil }
    let currentUserID = AppEnvironment.shared.currentSession?.userID ?? ""
    let showSubmissions = (currentUserID == userID)
    let viewModel = ContextCardViewModel(courseID: courseID, userID: userID, currentUserID: currentUserID, isSubmissionRowsVisible: showSubmissions, isLastActivityVisible: false)
    return CoreHostingController(ContextCardView(model: viewModel))
}

private func groupContextCard(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let groupID = params["groupID"], let userID = params["userID"] else { return nil }
    let currentUserID = AppEnvironment.shared.currentSession?.userID ?? ""
    let viewModel = GroupContextCardViewModel(groupID: groupID, userID: userID, currentUserID: currentUserID)
    return CoreHostingController(GroupContextCardView(model: viewModel))
}

private func courseDetails(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let context = Context(path: url.path) else { return nil }

    let regularCourseDetails: () -> UIViewController = {
        let viewModel = CourseDetailsViewModel(context: context)
        let viewController = CoreHostingController(CourseDetailsView(viewModel: viewModel))

        if let contextColor = url.contextColor {
            viewController.navigationBarStyle = .color(contextColor)
        }

        return viewController
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
