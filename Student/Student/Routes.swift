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
import CanvasKit
import Core
import TechDebt

public let router: Router = {
let routeMap: [String: RouteHandler.ViewFactory?] = [
    "/act-as-user": { _, _ in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate)
    },

    "/act-as-user/:userID": { _, params in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate, userID: params["userID"])
    },

    "/calendar_events/:eventID": { _, params in
        guard let eventID = params["eventID"] else { return nil }
        guard let session = Session.current else { return nil }
        return try? CalendarEventDetailViewController(forEventWithID: eventID, in: session, route: route)
    },

    "/conversations/compose": nil,
    "/conversations/:conversationID": nil,

    "/courses": nil,

    "/courses/:courseID": nil,
    "/courses/:courseID/tabs": nil,

    "/groups/:groupID": { url, _ in
        guard let context = ContextID(path: url.path) else { return nil }
        guard let session = Session.current else { return nil }
        return try? TabsTableViewController(session: session, contextID: context, route: route)
    },
    "/groups/:groupID/tabs": { url, _ in
        guard let context = ContextID(path: url.path) else { return nil }
        guard let session = Session.current else { return nil }
        return try? TabsTableViewController(session: session, contextID: context, route: route)
    },

    "/:context/:contextID/activity_stream": { url, _ in
        guard let context = ContextID(path: url.path) else { return nil }
        guard let session = Session.current else { return nil }
        return try? ActivityStreamTableViewController(session: session, context: context)
    },

    "/:context/:contextID/announcements": nil,

    "/:context/:contextID/announcements/:announcementID": nil,

    "/courses/:courseID/assignments": ExperimentalFeature.assignmentListGraphQL.isEnabled ? { url, params in
        guard let courseID = params["courseID"] else { return nil }
        return AssignmentListViewController.create(courseID: courseID)
        } : nil,

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
            context: ContextModel(.course, id: ID.expandTildeID(courseID)),
            assignmentID: ID.expandTildeID(assignmentID),
            userID: "self"
        )
    },

    "/courses/:courseID/assignments/:assignmentID/submissions/:userID": { url, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let userID = params["userID"] else { return nil }
        if url.originIsNotification {
            return AssignmentDetailsViewController.create(
                courseID: ID.expandTildeID(courseID),
                assignmentID: ID.expandTildeID(assignmentID),
                fragment: url.fragment
            )
        } else {
            return SubmissionDetailsViewController.create(
                context: ContextModel(.course, id: ID.expandTildeID(courseID)),
                assignmentID: ID.expandTildeID(assignmentID),
                userID: ID.expandTildeID(userID)
            )
        }
    },

    // No native support, fall back to web
    // "/:context/:contextID/collaborations": { url, _ in },

    "/:context/:contextID/discussions": nil,
    "/:context/:contextID/discussion_topics": nil,

    "/:context/:contextID/discussions/:discussionID": nil,
    "/:context/:contextID/discussion_topics/:discussionID": nil,

    "/courses/:courseID/external_tools/:toolID": { url, _ in
        guard let url = url.url, let vc = HelmManager.shared.topMostViewController() else { return nil }
        guard let session = Session.current else { return nil }
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
    "/:context/:contextID/files/:fileID": { url, params in
        if params["context"] == "courses", let courseID = params["contextID"],
            let controller = moduleItemController(for: url, courseID: courseID) {
            return controller
        }
        return fileViewController(url: url, params: params)
    },
    "/:context/:contextID/files/:fileID/download": fileViewController,

    "/courses/:courseID/grades": nil,

    "/courses/:courseID/modules": { _, params in
        guard let courseID = params["courseID"] else { return nil }
        guard let session = Session.current else { return nil }
        let contextID = ContextID.course(withID: courseID)
        // Restrict access to Modules tab if it's hidden (unless it is the home tab)
        let modulesTab = try? Tab.modulesTab(for: contextID, in: session)
        let homeTab = try? Tab.homeTab(for: contextID, in: session)
        let modulesAreHome = homeTab != nil && homeTab!.routingURL(session).flatMap { $0.path.contains("/modules") } ?? false
        if !modulesAreHome, modulesTab?.hidden ?? false {
            let message = NSLocalizedString("That page has been disabled for this course", comment: "")
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .default))
            return alert
        }
        return try? ModulesTableViewController(session: session, courseID: courseID)
    },

    "/courses/:courseID/modules/:moduleID": { _, params in
        guard let courseID = params["courseID"], let moduleID = params["moduleID"] else { return nil }
        guard let session = Session.current else { return nil }
        return try? ModuleDetailsViewController(session: session, courseID: courseID, moduleID: moduleID)
    },

    "/courses/:courseID/modules/items/:itemID": { _, params in
        guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
        guard let session = Session.current else { return nil }
        return try? ModuleItemDetailViewController(session: session, courseID: courseID, moduleItemID: itemID, route: route)
    },

    "/courses/:courseID/modules/:moduleID/items/:itemID": { _, params in
        guard let courseID = params["courseID"], let itemID = params["itemID"] else { return nil }
        guard let session = Session.current else { return nil }
        return try? ModuleItemDetailViewController(session: session, courseID: courseID, moduleItemID: itemID, route: route)
    },

    // No native support, fall back to web
    // "/courses/:courseID/outcomes": { url, _ in },

    "/courses/:courseID/pages": { _, params in
        guard let courseID = params["courseID"] else { return nil }
        let context = ContextModel(.course, id: ID.expandTildeID(courseID))
        return PageListViewController.create(context: context, appTraitCollection: UIApplication.shared.keyWindow?.traitCollection)
    },

    "/groups/:groupID/pages": { _, params in
        guard let groupID = params["groupID"] else { return nil }
        let context = ContextModel(.group, id: ID.expandTildeID(groupID))
        return PageListViewController.create(context: context, appTraitCollection: UIApplication.shared.keyWindow?.traitCollection)
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

    "/courses/:courseID/pages/:url": { url, params in
        guard let courseID = params["courseID"] else { return nil }
        if let controller = moduleItemController(for: url, courseID: courseID) { return controller }
        return HelmViewController(moduleName: "/courses/:courseID/pages/:url/rn", props: makeProps(url, params: params))
    },
    "/courses/:courseID/wiki/:url": { url, params in
        guard let courseID = params["courseID"] else { return nil }
        if let controller = moduleItemController(for: url, courseID: courseID) { return controller }
        return HelmViewController(moduleName: "/courses/:courseID/wiki/:url/rn", props: makeProps(url, params: params))
    },
    "/courses/:courseID/pages/:url/rn": nil,
    "/courses/:courseID/wiki/:url/rn": nil,

    "/groups/:groupID/pages/:url": { url, params in
        guard let groupID = params["groupID"], let purl = params["url"] else { return nil }
        // FIXME: confusing groupIDs for courseIDs (carried over from previoud route handler)
        if let controller = moduleItemController(for: url, courseID: groupID) { return controller }
        guard let session = Session.current else { return nil }
        return try? Page.DetailViewController(session: session, contextID: ContextID(id: groupID, context: .group), url: purl, route: route)
    },
    "/groups/:groupID/wiki/:url": { url, params in
        guard let groupID = params["groupID"], let purl = params["url"] else { return nil }
        // FIXME: confusing groupIDs for courseIDs (carried over from previoud route handler)
        if let controller = moduleItemController(for: url, courseID: groupID) { return controller }
        guard let session = Session.current else { return nil }
        return try? Page.DetailViewController(session: session, contextID: ContextID(id: groupID, context: .group), url: purl, route: route)
    },

    "/courses/:courseID/quizzes": { _, params in
        guard let courseID = params["courseID"] else { return nil }
        return QuizListViewController.create(courseID: ID.expandTildeID(courseID))
    },

    "/courses/:courseID/quizzes/:quizID": { url, params in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        guard let session = Session.current else { return nil }
        if let controller = moduleItemController(for: url, courseID: courseID) { return controller }
        return QuizIntroViewController(session: session, courseID: courseID, quizID: quizID)
    },

    "/courses/:courseID/quizzes/:quizID/take": { _, params in
        guard let courseID = params["courseID"], let quizID = params["quizID"] else { return nil }
        return QuizIntroViewController.takeController(contextID: ContextID(id: courseID, context: .course), quizID: quizID)
    },

    // No native support, fall back to web
    // "/courses/:courseID/settings": { url, _ in },

    "/courses/:courseID/users": { url, params in
        guard let courseID = params["courseID"] else { return nil }
        return PeopleListViewController.create(context: ContextModel(.course, id: courseID))
    },

    "/groups/:groupID/users": { url, params in
        guard let groupID = params["groupID"] else { return nil }
        return PeopleListViewController.create(context: ContextModel(.group, id: groupID))
    },

    "/courses/:courseID/users/:userID": nil,

    "/groups/:groupID/users/:userID": { _, params in
        guard let groupID = params["groupID"], let userID = params["userID"] else { return nil }
        let context = CKIGroup(id: groupID)
        let user = CKIUser(id: userID, context: context)
        let viewModel = CBIPeopleViewModel(for: user)
        viewModel?.tintColor = Session.current?.colorForGroup(groupID)
        let detailViewController = CBIPeopleDetailViewController()
        detailViewController.viewModel = viewModel
        return detailViewController
    },

    "/dev-menu": nil,

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

    "/support/:type": { _, params in
        let type = params["type"].flatMap { ErrorReportType(rawValue: $0) } ?? .problem
        return ErrorReportViewController.create(type: type)
    },
]

var routes: [RouteHandler] = []
for (template, handler) in routeMap.sorted(by: { $0.key > $1.key }) {
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
    let controller = AppEnvironment.shared.router.match(.parse(route))

    // Work around all these controllers not setting the nav color
    DispatchQueue.main.async {
        guard let color = RCTConvert.uiColor(props["color"]) else { return }
        controller?.navigationController?.navigationBar.useContextColor(color)
    }

    return controller
}
HelmManager.shared.registerNativeViewController(for: "/native-route/*route", factory: nativeFactory)
HelmManager.shared.registerNativeViewController(for: "/native-route-master/*route", factory: nativeFactory)
CBIConversationStarter.setConversationStarter { recipients, context in
    guard
        let contextID = ContextID(canvasContext: context),
        let currentSession = Session.current,
        let enrollment = currentSession.enrollmentsDataSource[contextID] else {
            return
    }
    HelmManager.shared.present(
        "/conversations/compose",
        withProps: [
            "recipients": recipients.map { recipient in
                return [
                    "name": recipient.name,
                    "avatar_url": recipient.avatarURL,
                    "id": recipient.id,
                ]
            },
            "contextCode": context,
            "contextName": enrollment.name,
        ],
        options: [
            "modal": true,
            "embedInNavigationController": true,
        ]
    )
}

Routing.routeToURL = { url, view in route(view, url: url) }

return Router(routes: routes) { url, _, _ in
    var components = url
    if components.scheme?.hasPrefix("http") == false {
        components.scheme = "https"
    }
    guard let url = components.url(relativeTo: AppEnvironment.shared.currentSession?.baseURL) else { return }
    let request = GetWebSessionRequest(to: url)
    AppEnvironment.shared.api.makeRequest(request) { response, _, _ in
        DispatchQueue.main.async {
            AppEnvironment.shared.loginDelegate?.openExternalURL(response?.session_url ?? url)
        }
    }
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
    guard let fileID = url.queryItems?.first(where: { $0.name == "preview" })?.value ?? params["fileID"], let fileIdent = UInt64(fileID) else { return nil }

    if ExperimentalFeature.fileDetails.isEnabled {
        var context = ContextModel(path: url.path) ?? ContextModel.currentUser
        if let courseID = url.queryItems?.first(where: { $0.name == "courseID" })?.value {
            context = ContextModel(.course, id: courseID)
        }
        let assignmentID = url.queryItems?.first(where: { $0.name == "assignmentID" })?.value
        return FileDetailsViewController.create(context: context, fileID: fileID, assignmentID: assignmentID)
    }

    let controller = FileViewController()
    controller.canvasAPI = CKCanvasAPI.current()
    controller.fileIdent = fileIdent

    if let courseID = url.queryItems?.first(where: { $0.name == "courseID" })?.value {
        controller.courseID = courseID
    } else if params["context"] == "courses" {
        controller.courseID = params["contextID"]
    } else {
        controller.courseID = params["courseID"]
    }

    controller.assignmentID = url.queryItems?.first(where: { $0.name == "assignmentID" })?.value
    controller.showingOldVersion = url.path.hasSuffix("/old")
    controller.fetchFile()
    return controller
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
