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

import Foundation
import SafariServices
import Core

let router = Router(routes: [

    RouteHandler("/accounts/self/account_notifications/:id") { _, params, _ in
        guard let id = params["id"] else { return nil }
        return AccountNotificationDetailsViewController.create(studentID: currentStudentID, notificationID: id)
    },

    RouteHandler("/calendar") { url, _, _ in
        guard let studentID = currentStudentID else { return nil }
        if let eventID = url.queryItems?.first(where: { $0.name == "event_id" })?.value {
            return CalendarEventDetailsViewController.create(studentID: studentID, eventID: eventID)
        }
        let controller = PlannerViewController.create(studentID: studentID)
        controller.view.tintColor = ColorScheme.observee(studentID).color
        return controller
    },

    RouteHandler("/conversations") { _, _, _ in
        return ParentConversationListViewController.create()
    },

    RouteHandler("/conversations/:conversationID") { _, params, _ in
        guard let conversationID = params["conversationID"] else { return nil }
        return ConversationDetailViewController.create(conversationID: conversationID)
    },

    RouteHandler("/courses") { _, _, _ in
        return DashboardViewController.create()
    },

    RouteHandler("/courses/:courseID/assignments/:assignmentID") { _, params, _ in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        guard let studentID = currentStudentID else { return nil }
        if assignmentID == "syllabus" {
            return SyllabusViewController.create(courseID: courseID)
        }
        return AssignmentDetailsViewController.create(studentID: studentID, courseID: courseID, assignmentID: assignmentID)
    },

    RouteHandler("/courses/:courseID/assignments/:assignmentID/submissions/:userID") { _, params, _ in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let studentID = params["userID"] else { return nil }
        return AssignmentDetailsViewController.create(studentID: studentID, courseID: courseID, assignmentID: assignmentID)
    },

    RouteHandler("/courses/:courseID/grades") { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        guard let studentID = currentStudentID else { return nil }
        return CourseDetailsViewController.create(courseID: courseID, studentID: studentID)
    },

    RouteHandler("/courses/:courseID/grades/:userID") { _, params, _ in
        guard let courseID = params["courseID"] else { return nil }
        guard let studentID = params["userID"] else { return nil }
        return CourseDetailsViewController.create(courseID: courseID, studentID: studentID)
    },

    RouteHandler("/:context/:contextID/calendar_events/:eventID") { _, params, _ in
        guard let eventID = params["eventID"], let studentID = currentStudentID else { return nil }
        return CalendarEventDetailsViewController.create(studentID: studentID, eventID: eventID)
    },

    RouteHandler("/calendar_events/:eventID") { _, params, _ in
        guard let eventID = params["eventID"], let studentID = currentStudentID else { return nil }
        return CalendarEventDetailsViewController.create(studentID: studentID, eventID: eventID)
    },

    RouteHandler("/courses/:courseID/discussion_topics/:topicID") { _, params, _ in
        guard let courseID = params["courseID"], let topicID = params["topicID"] else { return nil }
        guard let studentID = currentStudentID else { return nil }
        return DiscussionDetailsViewController.create(studentID: studentID, courseID: courseID, topicID: topicID)
    },

    RouteHandler("/profile") { _, _, _ in
        return CoreHostingController(SideMenuView(.observer), customization: SideMenuTransitioningDelegate.applyTransitionSettings)
    },

    RouteHandler("/profile/observees") { _, _, _ in
        return StudentListViewController.create()
    },

    RouteHandler("/profile/observees/:userID/thresholds") { _, params, _ in
        guard let userID = params["userID"] else { return nil }
        return StudentDetailsViewController.create(studentID: userID)
    },

    RouteHandler("/support/:type") { _, params, _ in
        guard let type = params["type"] else { return nil }
        return ErrorReportViewController.create(type: ErrorReportType(rawValue: type) ?? .problem)
    },

    RouteHandler("/accounts/:accountID/terms_of_service") { _, params, _ in
        guard let accountID = params["accountID"] else { return nil }
        return TermsOfServiceViewController()
    },

    RouteHandler("/act-as-user") { _, _, _ in
        guard let loginDelegate = AppEnvironment.shared.loginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate)
    },

    RouteHandler("/files", factory: fileList),
    RouteHandler("/:context/:contextID/files", factory: fileList),
    RouteHandler("/files/folder/*subFolder", factory: fileList),
    RouteHandler("/:context/:contextID/files/folder/*subFolder", factory: fileList),

    RouteHandler("/files/:fileID", factory: fileDetails),
    RouteHandler("/files/:fileID/download", factory: fileDetails),
    RouteHandler("/:context/:contextID/files/:fileID", factory: fileDetails),
    RouteHandler("/:context/:contextID/files/:fileID/download", factory: fileDetails),
    RouteHandler("/:context/:contextID/files/:fileID/preview", factory: fileDetails),

    RouteHandler("/dev-menu") { _, _, _ in
        return DeveloperMenuViewController.create()
    },

    RouteHandler("/dev-menu/experimental-features") { _, _, _ in
        return ExperimentalFeaturesViewController()
    },

    RouteHandler("/wrong-app") { _, _, _ in
        guard let loginDelegate = AppEnvironment.shared.loginDelegate else { return nil }
        return WrongAppViewController.create(delegate: loginDelegate)
    },

    RouteHandler("/about") { _, _, _ in
        AboutAssembly.makeAboutViewController()
    },
])

private func fileList(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard url.queryItems?.contains(where: { $0.name == "preview" }) != true else {
        return fileDetails(url: url, params: params, userInfo: userInfo)
    }
    Router.open(url: url)
    return nil
}

private func fileDetails(url: URLComponents, params: [String: String], userInfo: [String: Any]?) -> UIViewController? {
    guard let fileID = params["fileID"] else { return nil }
    let context = Context(path: url.path) ?? .currentUser
    return FileDetailsViewController.create(context: context, fileID: fileID)
}
