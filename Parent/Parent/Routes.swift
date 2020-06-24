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
import CanvasCore
import Core

let router = Router(routes: [

    RouteHandler("/accounts/self/users/self/account_notifications/:id") { _, params in
        guard let session = Session.current, let id = params["id"] else { return nil }
        return try? AccountNotificationViewController(session: session, announcementID: id)
    },

    RouteHandler("/calendar") { url, _ in
        if let eventID = url.queryItems?.first(where: { $0.name == "event_id" })?.value {
            guard let session = Session.current, let studentID = currentStudentID else { return nil }
            return try? CalendarEventDetailsViewController(session: session, studentID: studentID, calendarEventID: eventID)
        }
        guard let studentID = currentStudentID else { return nil }
        let controller = PlannerViewController.create(studentID: studentID)
        controller.view.tintColor = ColorScheme.observee(studentID).color
        return controller
    },

    RouteHandler("/conversations") { _, _ in
        return ParentConversationListViewController.create()
    },

    RouteHandler("/conversations/:conversationID") { _, params in
        guard let conversationID = params["conversationID"] else { return nil }
        return ConversationDetailViewController.create(conversationID: conversationID)
    },

    RouteHandler("/courses") { _, _ in
        return DashboardViewController.create()
    },

    RouteHandler("/courses/:courseID/assignments/:assignmentID") { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        guard let session = Session.current, let studentID = currentStudentID else { return nil }
        if assignmentID == "syllabus" {
            return SyllabusViewController.create(courseID: courseID)
        }
        return try? AssignmentDetailsViewController(session: session, studentID: studentID, courseID: courseID, assignmentID: assignmentID)
    },

    RouteHandler("/courses/:courseID/assignments/:assignmentID/submissions/:userID") { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let studentID = params["userID"] else { return nil }
        guard let session = Session.current else { return nil }
        return try? AssignmentDetailsViewController(session: session, studentID: studentID, courseID: courseID, assignmentID: assignmentID)
    },

    RouteHandler("/courses/:courseID/grades") { _, params in
        guard let courseID = params["courseID"] else { return nil }
        guard let studentID = currentStudentID else { return nil }
        return CourseDetailsViewController.create(courseID: courseID, studentID: studentID)
    },

    RouteHandler("/courses/:courseID/calendar_events/:eventID") { _, params in
        guard let courseID = params["courseID"], let eventID = params["eventID"] else { return nil }
        guard let session = Session.current, let studentID = currentStudentID else { return nil }
        return try? CalendarEventDetailsViewController(session: session, studentID: studentID, courseID: courseID, calendarEventID: eventID)
    },

    RouteHandler("/courses/:courseID/discussion_topics/:topicID") { _, params in
        guard let courseID = params["courseID"], let topicID = params["topicID"] else { return nil }
        guard let session = Session.current, let studentID = currentStudentID else { return nil }
        return try? AnnouncementDetailsViewController(session: session, studentID: studentID, courseID: courseID, announcementID: topicID)
    },

    RouteHandler("/calendar_events/:eventID") { _, params in
        guard let eventID = params["eventID"] else { return nil }
        guard let session = Session.current, let studentID = currentStudentID else { return nil }
        return try? CalendarEventDetailsViewController(session: session, studentID: studentID, calendarEventID: eventID)
    },

    RouteHandler("/profile") { _, _ in
        return ProfileViewController.create(enrollment: .observer)
    },

    RouteHandler("/profile/observees") { url, _ in
        let showPromptValue = url.queryItems?.first { $0.name == "showPrompt" }?.value
        let showPrompt = Bool(showPromptValue ?? "") ?? false
        return StudentListViewController.create(showAddStudentPrompt: showPrompt)
    },

    RouteHandler("/profile/observees/:userID/thresholds") { _, params in
        guard let userID = params["userID"] else { return nil }
        return StudentDetailsViewController.create(studentID: userID)
    },

    RouteHandler("/support/:type") { _, params in
        guard let type = params["type"] else { return nil }
        return ErrorReportViewController.create(type: ErrorReportType(rawValue: type) ?? .problem)
    },

    RouteHandler("/accounts/:accountID/terms_of_service") { _, params in
        guard let accountID = params["accountID"] else { return nil }
        return TermsOfServiceViewController()
    },

    RouteHandler("/act-as-user") { _, _ in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate)
    },

    RouteHandler("/files/:fileID", factory: fileViewController),
    RouteHandler("/files/:fileID/download", factory: fileViewController),
    RouteHandler("/:context/:contextID/files/:fileID", factory: fileViewController),
    RouteHandler("/:context/:contextID/files/:fileID/download", factory: fileViewController),

    RouteHandler("/dev-menu") { _, _ in
        return DeveloperMenuViewController.create()
    },

    RouteHandler("/dev-menu/experimental-features") { _, _ in
        return ExperimentalFeaturesViewController()
    },

    RouteHandler("/wrong-app") { _, _ in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return WrongAppViewController.create(delegate: loginDelegate)
    },

    RouteHandler("/create-account/:accountID/:pairingCode") { url, params in
        guard ExperimentalFeature.parentQRCodePairing.isEnabled else { return nil }
        guard
            let queryItem = url.queryItems?.first,
            queryItem.name == "baseURL",
            let host = queryItem.value,
            let accountID = params["accountID"],
            let code = params["pairingCode"],
            let baseURL = URL(string: "https://\(host)")
         else { return nil }
        return CreateAccountViewController.create(baseURL: baseURL, accountID: accountID, pairingCode: code)
    },

]) { url, _, _ in
    Router.open(url: url)
}

private func fileViewController(url: URLComponents, params: [String: String]) -> UIViewController? {
    guard let fileID = params["fileID"] else { return nil }
    let context = Context(path: url.path) ?? .currentUser
    return FileDetailsViewController.create(context: context, fileID: fileID)
}
