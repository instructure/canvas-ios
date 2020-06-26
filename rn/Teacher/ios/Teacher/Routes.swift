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

import Foundation
import CanvasCore
import Core

extension AppDelegate {
    @objc func registerNativeRoutes() {
        for (template, factory) in nativeRoutes {
            guard let factory = factory else { continue }
            HelmManager.shared.registerNativeViewController(for: template, factory: factory)
        }
    }
}

class TeacherRouter: Router {
    override func match(_ url: URLComponents, userInfo: [String: Any]? = nil) -> UIViewController? {
        for template in HelmManager.shared.registeredRoutes {
            let route = RouteHandler(template) { url, params, userInfo in
                let props = makeProps(url, params: params, userInfo: userInfo)
                if let factory = HelmManager.shared.nativeViewControllerFactories[template] {
                    return factory.builder(props)
                }
                return HelmViewController(moduleName: template, props: props)
            }
            if let params = route.match(url), let match = route.factory(url, params, userInfo) {
                return match
            }
        }
        return nil
    }

    override func route(to url: URLComponents, userInfo: [String: Any]? = nil, from: UIViewController, options: RouteOptions = .push) {
        guard let url = url.url else { return }
        let name = NSNotification.Name("route")
        let notificationInfo: [AnyHashable: Any] = [
            "url": url.absoluteString,
            "modal": options.isModal,
            "detail": options.isDetail,
            "props": userInfo ?? [:],
        ]
        NotificationCenter.default.post(name: name, object: nil, userInfo: notificationInfo)
    }
}

let router = TeacherRouter(routes: []) { _, _, _, _ in }

private let nativeRoutes: KeyValuePairs<String, HelmViewControllerFactory.Builder?> = [
    "/courses/:courseID/attendance/:toolID": { props in
        guard let courseID = props["courseID"] as? String else { return nil }
        guard let toolID = props["toolID"] as? String else { return nil }
        return AttendanceViewController(context: .course(courseID), toolID: toolID)
    },

    "/courses": ExperimentalFeature.nativeDashboard.isEnabled == false ? nil : { _ in
        return CourseListViewController.create()
    },

    "/courses/:courseID/modules": { props in
        guard let courseID = props["courseID"] as? String else { return nil }
        return ModuleListViewController.create(courseID: courseID)
    },

    "/courses/:courseID/modules/:moduleID": { props in
        guard let courseID = props["courseID"] as? String else { return nil }
        guard let moduleID = props["moduleID"] as? String else { return nil }
        return ModuleListViewController.create(courseID: courseID, moduleID: moduleID)
    },

    "/:context/:contextID/pages": { props in
        guard let context = props.context else { return nil }
        return PageListViewController.create(context: context, app: .teacher)
    },

    "/courses/:courseID/users": { props in
        guard let courseID = props["courseID"] as? String else { return nil }
        return PeopleListViewController.create(context: .course(courseID))
    },

    "/:context/:contextID/pages/:url": { props in
        guard let context = props.context else { return nil }
        guard let pageURL = props["url"] as? String else { return nil }
        return PageDetailsViewController.create(context: context, pageURL: pageURL, app: .teacher)
    },

    "/:context/:contextID/wiki/:url": { props in
        guard let context = props.context else { return nil }
        guard let pageURL = props["url"] as? String else { return nil }
        return PageDetailsViewController.create(context: context, pageURL: pageURL, app: .teacher)
    },

    "/courses/:courseID/modules/:moduleID/items/:itemID": { props in
        guard
            let courseID = props["courseID"] as? String,
            let itemID = props["itemID"] as? String,
            let location = props["location"] as? [String: Any],
            let url = (location["href"] as? String).flatMap(URLComponents.parse)
        else {
            return nil
        }
        return ModuleItemSequenceViewController.create(courseID: courseID, assetType: .moduleItem, assetID: itemID, url: url)
    },

    "/courses/:courseID/modules/items/:itemID": { props in
        guard
            let courseID = props["courseID"] as? String,
            let itemID = props["itemID"] as? String,
            let location = props["location"] as? [String: Any],
            let url = (location["href"] as? String).flatMap(URLComponents.parse)
        else {
            return nil
        }
        return ModuleItemSequenceViewController.create(courseID: courseID, assetType: .moduleItem, assetID: itemID, url: url)
    },

    "/courses/:courseID/module_item_redirect/:itemID": { props in
        guard
            let courseID = props["courseID"] as? String,
            let itemID = props["itemID"] as? String,
            let location = props["location"] as? [String: Any],
            let url = (location["href"] as? String).flatMap(URLComponents.parse)
        else {
            return nil
        }
        return ModuleItemSequenceViewController.create(courseID: courseID, assetType: .moduleItem, assetID: itemID, url: url)
    },

    "/:context/:contextID/announcements/:announcementID": { (props: Props) -> UIViewController? in
        guard let context = props.context else { return nil }
        guard let topicID = props["announcementID"] as? String else { return nil }
        return DiscussionDetailsViewController.create(context: context, topicID: topicID, isAnnouncement: true)
    },

    "/:context/:contextID/discussions/:discussionID": discussionDetails,
    "/:context/:contextID/discussion_topics/:discussionID": discussionDetails,

    "/:context/:contextID/discussion_topics/:discussionID/reply": { props in
        guard let context = props.context else { return nil }
        guard let topicID = props["discussionID"] as? String else { return nil }
        return DiscussionReplyViewController.create(context: context, topicID: topicID)
    },

    "/:context/:contextID/discussion_topics/:discussionID/entries/:entryID/replies": { props in
        guard let context = props.context else { return nil }
        guard let topicID = props["discussionID"] as? String else { return nil }
        guard let entryID = props["entryID"] as? String else { return nil }
        return DiscussionReplyViewController.create(context: context, topicID: topicID, replyToEntryID: entryID)
    },

    "/files": fileList,
    "/:context/:contextID/files": fileList,
    "/files/folder/*subFolder": fileList,
    "/:context/:contextID/files/folder/*subFolder": fileList,

    "/files/:fileID": fileDetails,
    "/files/:fileID/download": fileDetails,
    "/:context/:contextID/files/:fileID": fileDetails,
    "/:context/:contextID/files/:fileID/download": fileDetails,

    "/act-as-user": { _ in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate)
    },

    "/act-as-user/:userID": { props in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate, userID: props["userID"] as? String)
    },

    "/wrong-app": { _ in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return WrongAppViewController.create(delegate: loginDelegate)
    },

    "/courses/:courseID/assignments/:assignmentID/post_policy": { props in
        guard let courseID = props["courseID"] as? String, let assignmentID = props["assignmentID"] as? String else { return nil }
        return PostSettingsViewController.create(courseID: courseID, assignmentID: assignmentID)
    },

    "/profile": { _ in
        return ProfileViewController.create(enrollment: .teacher)
    },

    "/profile/settings": { _ in
        return ProfileSettingsViewController.create()
    },

    "/dev-menu/experimental-features": { _ in
        let vc = ExperimentalFeaturesViewController()
        vc.afterToggle = {
            HelmManager.shared.reload()
        }
        return vc
    },

    "/support/problem": { props in
        return ErrorReportViewController.create(type: .problem)
    },

    "/support/feature": { props in
        return ErrorReportViewController.create(type: .feature)
    },
]

private func discussionDetails(props: Props) -> UIViewController? {
    guard let context = props.context else { return nil }
    guard let topicID = props["discussionID"] as? String else { return nil }
    return DiscussionDetailsViewController.create(context: context, topicID: topicID)
}

private func fileList(props: Props) -> UIViewController? {
    if let preview = fileDetails(props: props) {
        return preview
    }
    var props = props
    props["context"] = props["context"] ?? "users"
    props["contextID"] = props["contextID"] ?? "self"
    if props.context == .currentUser, props["subFolder"] == nil {
        props["customPageViewPath"] = "/files"
    }
    let moduleName = props["subFolder"] == nil
        ? "/:context/:contextID/files"
        : "/:context/:contextID/files/folder/*subFolder"
    return HelmViewController(moduleName: moduleName, props: props)
}

private func fileDetails(props: Props) -> UIViewController? {
    guard let fileID = props["preview"] as? String ?? props["fileID"] as? String else { return nil }
    let context = props.context ?? .currentUser
    return FileDetailsViewController.create(context: context, fileID: fileID)
}

private extension Props {
    var context: Context? {
        if let contextType = self["context"] as? String, let contextID = self["contextID"] as? String {
            return Context(path: "\(contextType)/\(contextID)")
        } else if let courseID = self["courseID"] as? String {
            return Context(.course, id: courseID)
        } else if let groupID = self["groupID"] as? String {
            return Context(.group, id: groupID)
        } else {
            return nil
        }
    }
}

// MARK: - HelmModules

extension ModuleListViewController: HelmModule {
    public var moduleName: String { return "/courses/:courseID/modules" }
}

extension WrongAppViewController: HelmModule {
    public var moduleName: String { return "/wrong-app" }
}
