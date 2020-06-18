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

public let router: Router = {
let routeMap: KeyValuePairs<String, RouteHandler.ViewFactory?> = [
    "/act-as-user": { _, _ in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate)
    },

    "/act-as-user/:userID": { _, params in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate, userID: params["userID"])
    },

    "/calendar": { url, _ in
        if let eventID = url.queryItems?.first(where: { $0.name == "event_id" })?.value {
           guard let session = Session.current else { return nil }
           return try? CalendarEventDetailViewController(forEventWithID: eventID, in: session, route: route)
       }
       let controller = PlannerViewController.create()
       controller.view.tintColor = Brand.shared.primary
       return controller
    },

    "/calendar_events/:eventID": { _, params in
        guard let eventID = params["eventID"] else { return nil }
        guard let session = Session.current else { return nil }
        return try? CalendarEventDetailViewController(forEventWithID: eventID, in: session, route: route)
    },

    "/conversations/compose": nil,
    "/conversations/:conversationID": nil,

    "/courses": { url, params in
        guard ExperimentalFeature.nativeDashboard.isEnabled else {
            return HelmViewController(moduleName: "/courses", props: makeProps(url, params: params))
        }
        return CourseListViewController.create()
    },

    "/courses/:courseID": nil,
    "/courses/:courseID/tabs": nil,

    "/groups/:groupID": { url, _ in
        guard let context = Context(path: url.path) else { return nil }
        return GroupNavigationViewController.create(context: context)
    },
    "/groups/:groupID/tabs": { url, _ in
        guard let context = Context(path: url.path) else { return nil }
        return GroupNavigationViewController.create(context: context)
    },

    "/:context/:contextID/activity_stream": { _, _ in
        return ActivityStreamViewController.create()
    },

    "/:context/:contextID/announcements": nil,

    "/:context/:contextID/announcements/:announcementID": { url, params in
        guard let context = Context(path: url.path), let announcementID = params["announcementID"] else { return nil }
        return DiscussionDetailsViewController.create(context: context, topicID: announcementID, isAnnouncement: true)
    },

    "/courses/:courseID/assignments": nil,

    "/courses/:courseID/assignments-fromHomeTab": { url, params in
        var props = params as [String: Any]
        props["doNotSelectFirstItem"] = true
        return HelmViewController(moduleName: "/courses/:courseID/assignments", props: makeProps(url, params: props))
    },

    "/courses/:courseID/syllabus": { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return StudentSyllabusViewController.create(courseID: ID.expandTildeID(courseID))
    },

    "/courses/:courseID/assignments/:assignmentID": { url, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        if assignmentID == "syllabus" {
            return StudentSyllabusViewController.create(courseID: ID.expandTildeID(courseID))
        }
        if ExperimentalFeature.studentModules.isEnabled, !url.originIsModuleItemDetails {
            return ModuleItemSequenceViewController.create(
                courseID: ID.expandTildeID(courseID),
                assetType: .assignment,
                assetID: ID.expandTildeID(assignmentID),
                url: url
            )
        }
        if let controller = moduleItemController(for: url, courseID: courseID) { return controller }
        return AssignmentDetailsViewController.create(
            courseID: ID.expandTildeID(courseID),
            assignmentID: ID.expandTildeID(assignmentID),
            fragment: url.fragment
        )
    },

    "/courses/:courseID/assignments/:assignmentID/submissions": { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        return SubmissionDetailsViewController.create(
            context: .course(ID.expandTildeID(courseID)),
            assignmentID: ID.expandTildeID(assignmentID),
            userID: "self"
        )
    },

    "/courses/:courseID/assignments/:assignmentID/submissions/:userID": { url, params in
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

    "/:context/:contextID/conferences": { url, _ in
        guard let context = Context(path: url.path) else { return nil }
        return ConferenceListViewController.create(context: context)
    },
    "/:context/:contextID/conferences/:conferenceID": { url, params in
        guard let context = Context(path: url.path), let id = params["conferenceID"] else { return nil }
        return ConferenceDetailsViewController.create(context: context, conferenceID: id)
    },

    "/:context/:contextID/conferences/:conferenceID/join": { url, params in
        Router.open(url: url)
        return nil
    },

    "/:context/:contextID/discussions": nil,
    "/:context/:contextID/discussion_topics": nil,

    "/:context/:contextID/discussion_topics/new": nil,
    "/:context/:contextID/discussion_topics/:discussionID/edit": nil,
    "/:context/:contextID/discussion_topics/:discussionID/reply": { url, params in
        guard
            let context = Context(path: url.path),
            let discussionID = params["discussionID"]
        else { return nil }
        return DiscussionReplyViewController.create(context: context, topicID: discussionID)
    },
    "/:context/:contextID/discussion_topics/:discussionID/entries/:entryID/replies": { url, params in
        guard
            let context = Context(path: url.path),
            let discussionID = params["discussionID"],
            let entryID = params["entryID"]
        else { return nil }
        return DiscussionReplyViewController.create(context: context, topicID: discussionID, replyToEntryID: entryID)
    },

    "/:context/:contextID/discussions/:discussionID": discussionViewController,
    "/:context/:contextID/discussion_topics/:discussionID": discussionViewController,

    "/courses/:courseID/external_tools/:toolID": { url, params in
        guard let url = url.url, let session = Session.current else { return nil }
        guard let vc = HelmManager.shared.topMostViewController() else { return nil }
        ExternalToolManager.shared.launch(url, in: session, from: vc, fallbackURL: url)
        return nil
    },

    "/files": { _, params in
        return fileListController(params: params)
    },
    // The :ignored part is usually users_{id}, but canvas ignores it, it can be anything and
    // you will still see your files, and the actual folder path doesn't start until after it.
    "/files/folder/:folderID": { _, params in
        return fileListController(params: params)
    },
    "/:context/:contextID/files": nil,

    "/files/folder/*subFolder": { url, params in
        if let preview = previewFileViewController(url: url, params: params) { return preview }
        var props = params
        props["context"] = "users"
        props["contextID"] = "self"
        return HelmViewController(moduleName: "/:context/:contextID/files/folder/*subFolder", props: makeProps(url, params: props))
    },
    "/:context/:contextID/files/folder/*subFolder": nil,
    "/:context/:contextID/files/folders/*subFolder": nil,

    "/files/:fileID": fileViewController,
    "/files/:fileID/download": fileViewController,
    "/files/:fileID/old": fileViewController,
    "/:context/:contextID/files/:fileID": fileViewController,
    "/:context/:contextID/files/:fileID/download": fileViewController,

    "/courses/:courseID/grades": { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return GradeListViewController.create(courseID: courseID)
    },

    "/courses/:courseID/modules": { _, params in
        guard let courseID = params["courseID"] else { return nil }
        guard let session = Session.current else { return nil }
        let contextID = Context.course(courseID)
        // Restrict access to Modules tab if it's hidden (unless it is the home tab)
        let modulesTab = try? Tab.modulesTab(for: contextID, in: session)
        let modulesAreHome = session.enrollmentsDataSource[contextID]?.defaultViewPath.contains("/modules") == true
        if !modulesAreHome, modulesTab?.hidden ?? false {
            let message = NSLocalizedString("That page has been disabled for this course", comment: "")
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .default))
            return alert
        }
        guard ExperimentalFeature.studentModules.isEnabled else {
            return try? ModulesTableViewController(session: session, courseID: courseID)
        }
        return ModuleListViewController.create(courseID: courseID)
    },

    "/courses/:courseID/modules/:moduleID": { _, params in
        guard let courseID = params["courseID"], let moduleID = params["moduleID"] else { return nil }
        guard ExperimentalFeature.studentModules.isEnabled else {
            guard let session = Session.current else { return nil }
            return try? ModuleDetailsViewController(session: session, courseID: courseID, moduleID: moduleID)
        }
        return ModuleListViewController.create(courseID: courseID, moduleID: moduleID)
    },

    "/courses/:courseID/modules/items/:itemID": { url, params in
        guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
        guard let session = Session.current else { return nil }
        if ExperimentalFeature.studentModules.isEnabled {
            return ModuleItemSequenceViewController.create(
                courseID: courseID,
                assetType: .moduleItem,
                assetID: itemID,
                url: url
            )
        }
        return try? ModuleItemDetailViewController(session: session, courseID: courseID, moduleItemID: itemID, route: route)
    },

    "/courses/:courseID/modules/:moduleID/items/:itemID": { url, params in
        guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
        guard let session = Session.current else { return nil }
        if ExperimentalFeature.studentModules.isEnabled {
            return ModuleItemSequenceViewController.create(
                courseID: courseID,
                assetType: .moduleItem,
                assetID: itemID,
                url: url
            )
        }
        return try? ModuleItemDetailViewController(session: session, courseID: courseID, moduleItemID: itemID, route: route)
    },

    "/courses/:courseID/module_item_redirect/:itemID": { url, params in
        guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
        if ExperimentalFeature.studentModules.isEnabled {
            return ModuleItemSequenceViewController.create(
                courseID: courseID,
                assetType: .moduleItem,
                assetID: itemID,
                url: url
            )
        }
        return nil
    },

    // No native support, fall back to web
    // "/courses/:courseID/outcomes": { url, _ in },

    "/courses/:courseID/pages": { _, params in
        guard let courseID = params["courseID"] else { return nil }
        let context = Context(.course, id: ID.expandTildeID(courseID))
        return PageListViewController.create(context: context, app: .student)
    },

    "/groups/:groupID/pages": { _, params in
        guard let groupID = params["groupID"] else { return nil }
        let context = Context(.group, id: ID.expandTildeID(groupID))
        return PageListViewController.create(context: context, app: .student)
    },

    "/:context/:contextID/wiki": { url, _ in
        var url = url
        url.path = url.path.replacingOccurrences(of: "wiki", with: "pages/front_page")
        return AppEnvironment.shared.router.match(url)
    },
    "/:context/:contextID/front_page": { url, _ in
        var url = url
        url.path = url.path.replacingOccurrences(of: "front_page", with: "pages/front_page")
        return AppEnvironment.shared.router.match(url)
    },

    "/:context/:contextID/pages/new": nil,
    "/:context/:contextID/wiki/new": nil,
    "/:context/:contextID/pages/:url": pageViewController,
    "/:context/:contextID/wiki/:url": pageViewController,
    "/:context/:contextID/pages/:url/edit": nil,
    "/:context/:contextID/wiki/:url/edit": nil,

    "/courses/:courseID/quizzes": { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return QuizListViewController.create(courseID: ID.expandTildeID(courseID))
    },

    "/courses/:courseID/quizzes/:quizID": { url, params in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        guard let session = Session.current else { return nil }
        if ExperimentalFeature.studentModules.isEnabled, !url.originIsModuleItemDetails {
            return ModuleItemSequenceViewController.create(
                courseID: courseID,
                assetType: .quiz,
                assetID: quizID,
                url: url
            )
        }
        if let controller = moduleItemController(for: url, courseID: courseID) { return controller }
        return QuizIntroViewController(session: session, courseID: courseID, quizID: quizID)
    },

    "/courses/:courseID/quizzes/:quizID/take": { _, params in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        return QuizIntroViewController.takeController(contextID: .course(courseID), quizID: quizID)
    },

    // No native support, fall back to web
    // "/courses/:courseID/settings": { url, _ in },

    "/courses/:courseID/users": { url, params in
        guard let courseID = params["courseID"] else { return nil }
        return PeopleListViewController.create(context: .course(courseID))
    },

    "/groups/:groupID/users": { url, params in
        guard let groupID = params["groupID"] else { return nil }
        return PeopleListViewController.create(context: .group(groupID))
    },

    "/courses/:courseID/users/:userID": nil,
    "/groups/:groupID/users/:userID": nil,

    "/courses/:courseID/user_preferences": nil,

    "/dev-menu": nil,

    "/dev-menu/experimental-features": { _, _ in
        let vc = ExperimentalFeaturesViewController()
        vc.afterToggle = {
            HelmManager.shared.reload()
        }
        return vc
    },

    "/accounts/:accountID/terms_of_service": nil,

    "/logs": { _, _ in
        return LogEventListViewController.create()
    },

    "/profile": { _, _ in
        return ProfileViewController.create(enrollment: .student)
    },

    "/profile/settings": { _, _ in
        return ProfileSettingsViewController.create()
    },

    "/support/problem": { _, _ in
        return ErrorReportViewController.create(type: .problem)
    },

    "/support/feature": { _, _ in
        return ErrorReportViewController.create(type: .feature)
    },
]

var routes: [RouteHandler] = []
for (template, handler) in routeMap {
    if let factory = handler {
        let route = RouteHandler(template, factory: factory)
        HelmManager.shared.registerNativeViewController(for: template, factory: { props in
            guard
                let location = props["location"] as? [String: Any],
                let url = (location["href"] as? String).flatMap(URLComponents.parse),
                let params = route.match(url)
            else { return nil }
            return route.factory(url, params)
        })
        routes.append(route)
    } else {
        routes.append(RouteHandler(template) { url, params in
            return HelmViewController(moduleName: template, props: makeProps(url, params: params))
        })
    }
}

let nativeFactory: ([String: Any]) -> UIViewController? = { props in
    guard let route = props["route"] as? String else { return nil }
    let controller = AppEnvironment.shared.router.match(route)

    // Work around all these controllers not setting the nav color
    DispatchQueue.main.async {
        guard let color = RCTConvert.uiColor(props["color"]) else { return }
        controller?.navigationController?.navigationBar.useContextColor(color)
    }

    return controller
}
HelmManager.shared.registerNativeViewController(for: "/native-route/*route", factory: nativeFactory)
HelmManager.shared.registerNativeViewController(for: "/native-route-master/*route", factory: nativeFactory)

return Router(routes: routes) { url, _, _ in
    Router.open(url: url)
}
}()

private func route(_ view: UIViewController, url: URL) {
    router.route(to: url, from: view)
}

private func fileListController(params: [String: String]) -> UIViewController {
    var props = params
    props["context"] = props["context"] ?? "users"
    props["contextID"] = props["contextID"] ?? "self"
    if params["context"] == "users" {
        props["customPageViewPath"] = "/files"
    }
    return HelmViewController(moduleName: "/:context/:contextID/files", props: props)
}

private func previewFileViewController(url: URLComponents, params: [String: String]) -> UIViewController? {
    guard url.queryItems?.first(where: { $0.name == "preview" })?.value != nil else { return nil }
    return fileViewController(url: url, params: params)
}

private func fileViewController(url: URLComponents, params: [String: String]) -> UIViewController? {
    guard let fileID = url.queryItems?.first(where: { $0.name == "preview" })?.value ?? params["fileID"] else { return nil }
    var context = Context(path: url.path)
    if let courseID = url.queryItems?.first(where: { $0.name == "courseID" })?.value {
        context = Context(.course, id: courseID)
    }
    let assignmentID = url.queryItems?.first(where: { $0.name == "assignmentID" })?.value
    if ExperimentalFeature.studentModules.isEnabled, !url.originIsModuleItemDetails, context?.contextType == .course {
        return ModuleItemSequenceViewController.create(
            courseID: context!.id,
            assetType: .file,
            assetID: fileID,
            url: url
        )
    }
    if context?.contextType == .course,
        let courseID = context?.id,
        let controller = moduleItemController(for: url, courseID: courseID) {
        return controller
    }
    return FileDetailsViewController.create(context: context, fileID: fileID, assignmentID: assignmentID)
}

private func pageViewController(url: URLComponents, params: [String: String]) -> UIViewController? {
    guard let context = Context(path: url.path), let pageURL = params["url"] else { return nil }
    if ExperimentalFeature.studentModules.isEnabled, !url.originIsModuleItemDetails, context.contextType == .course {
        return ModuleItemSequenceViewController.create(
            courseID: context.id,
            assetType: .page,
            assetID: pageURL,
            url: url
        )
    }
    if context.contextType == .course, let controller = moduleItemController(for: url, courseID: context.id) {
        return controller
    }
    return PageDetailsViewController.create(context: context, pageURL: pageURL, app: .student)
}

private func discussionViewController(url: URLComponents, params: [String: String]) -> UIViewController? {
    guard let context = Context(path: url.path), let discussionID = params["discussionID"] else { return nil }
    if ExperimentalFeature.studentModules.isEnabled, context.contextType == .course, !url.originIsModuleItemDetails {
        return ModuleItemSequenceViewController.create(
            courseID: context.id,
            assetType: .discussion,
            assetID: discussionID,
            url: url
        )
    }
    return DiscussionDetailsViewController.create(context: context, topicID: discussionID)
}

private func moduleItemController(for url: URLComponents, courseID: String) -> UIViewController? {
    guard let itemID = url.queryItems?.first(where: { $0.name == "module_item_id" })?.value else { return nil }
    guard let session = Session.current else { return nil }
    return try? ModuleItemDetailViewController(session: session, courseID: courseID, moduleItemID: itemID, route: route)
}

private func makeProps(_ url: URLComponents, params: Props) -> Props {
    var props = params
    let location: [String: Any?] = [
        "hash": url.fragment.flatMap { "#\($0)" },
        "host": url.host.flatMap { host in
            url.port.flatMap { "\(host):\($0)" } ?? host
        },
        "hostname": url.host,
        "href": url.string,
        "pathname": url.path,
        "port": url.port.flatMap { String($0) },
        "protocol": url.scheme.flatMap { "\($0):" },
        "query": url.queryItems?.reduce(into: [String: String?]()) { query, item in
            props[item.name] = item.value
            query[item.name] = item.value
        },
        "search": url.query.flatMap { "?\($0)" },
    ]
    props["location"] = location
    return props
}
