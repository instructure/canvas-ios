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

    RouteHandler(.accountNotification(":id")) { _, params in
        guard let session = legacySession, let id = params["id"] else { return nil }
        return try? AccountNotificationViewController(session: session, announcementID: id)
    },

    RouteHandler(.conversations) { _, _ in
        guard ExperimentalFeature.parentInbox.isEnabled else { return nil }
        return ConversationListViewController.create()
    },

    RouteHandler(.compose()) { url, _ in
        guard ExperimentalFeature.parentInbox.isEnabled else { return nil }
        return ComposeViewController.create(
            body: url.queryItems?.first { $0.name == "body" }?.value,
            context: url.queryItems?.first { $0.name == "context" }?.value
                .flatMap { ContextModel(canvasContextID: $0) },
            observeeID: url.queryItems?.first { $0.name == "observeeID" }?.value,
            recipientIDs: url.queryItems?.first { $0.name == "recipientIDs" }?.value?
                .split(separator: ",").map { String($0) } ?? [],
            subject: url.queryItems?.first { $0.name == "subject" }?.value
        )
    },

    RouteHandler(.conversation(":conversationID")) { _, params in
        guard ExperimentalFeature.parentInbox.isEnabled else { return nil }
        guard let conversationID = params["conversationID"] else { return nil }
        return ConversationDetailViewController.create(conversationID: conversationID)
    },

    RouteHandler(.courses) { _, _ in
        guard let session = legacySession else { return nil }
        return DashboardViewController.create(session: session)
    },

    RouteHandler(.course(":courseID", assignment: ":assignmentID")) { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        guard let session = legacySession, let studentID = currentStudentID else { return nil }
        if assignmentID == "syllabus" {
            return CourseSyllabusViewController(courseID: courseID, studentID: studentID, session: session)
        }
        return try? AssignmentDetailsViewController(session: session, studentID: studentID, courseID: courseID, assignmentID: assignmentID)
    },

    RouteHandler(.courseGrades(":courseID")) { _, params in
        guard let courseID = params["courseID"] else { return nil }
        guard let studentID = currentStudentID else { return nil }
        return CourseDetailsViewController.create(courseID: courseID, studentID: studentID)
    },

    RouteHandler(.courseCalendar(courseID: ":courseID")) { _, params in
        guard let courseID = params["courseID"] else { return nil }
        guard let session = legacySession, let studentID = currentStudentID else { return nil }
        return CalendarEventWeekPageViewController.create(session: session, studentID: studentID, courseID: courseID)
    },

    RouteHandler(.courseCalendarEvent(courseID: ":courseID", eventID: ":eventID")) { _, params in
        guard let courseID = params["courseID"], let eventID = params["eventID"] else { return nil }
        guard let session = legacySession, let studentID = currentStudentID else { return nil }
        return try? CalendarEventDetailsViewController(session: session, studentID: studentID, courseID: courseID, calendarEventID: eventID)
    },

    RouteHandler(.courseDiscussion(courseID: ":courseID", topicID: ":topicID")) { _, params in
        guard let courseID = params["courseID"], let topicID = params["topicID"] else { return nil }
        guard let session = legacySession, let studentID = currentStudentID else { return nil }
        return try? AnnouncementDetailsViewController(session: session, studentID: studentID, courseID: courseID, announcementID: topicID)
    },

    RouteHandler(.actionableItemCalendarEvent(eventID: ":eventID")) { _, params in
        guard  let eventID = params["eventID"] else { return nil }
        guard let session = legacySession, let studentID = currentStudentID else { return nil }
        return try? CalendarEventDetailsViewController(session: session, studentID: studentID, calendarEventID: eventID)
    },

    RouteHandler(.profile) { _, _ in
        return ProfileViewController.create(enrollment: .observer)
    },

    RouteHandler(.profileObservees) { _, _ in
        guard let session = legacySession else { return nil }
        return SettingsViewController.create(session: session)
    },

    RouteHandler(.observeeThresholds(":userID")) { _, params in
        guard let session = legacySession, let userID = params["userID"] else { return nil }
        return StudentSettingsViewController.create(session, studentID: userID)
    },

    RouteHandler(.errorReport(for: ":type")) { _, params in
        guard let type = params["type"] else { return nil }
        return ErrorReportViewController.create(type: ErrorReportType(rawValue: type) ?? .problem)
    },

    RouteHandler(.termsOfService(forAccount: ":accountID")) { _, params in
        guard let accountID = params["accountID"] else { return nil }
        return TermsOfServiceViewController()
    },

    RouteHandler(.actAsUser) { _, _ in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return ActAsUserViewController.create(loginDelegate: loginDelegate)
    },

    RouteHandler(.developerMenu) { _, _ in
        return DeveloperMenuViewController.create()
    },

    RouteHandler(.experimentalFeatures) { _, _ in
        return ExperimentalFeaturesViewController()
    },

    RouteHandler(.wrongApp) { _, _ in
        guard let loginDelegate = UIApplication.shared.delegate as? LoginDelegate else { return nil }
        return WrongAppViewController.create(delegate: loginDelegate)
    },

]) { url, _, _ in
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
