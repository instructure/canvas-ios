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

    RouteHandler(.accountNotification(":id")) { _, params in
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

    RouteHandler(.conversations) { _, _ in
        return ConversationListViewController.create()
    },

    RouteHandler(.conversation(":conversationID")) { _, params in
        guard let conversationID = params["conversationID"] else { return nil }
        return ConversationDetailViewController.create(conversationID: conversationID)
    },

    RouteHandler(.courses) { _, _ in
        return DashboardViewController.create()
    },

    RouteHandler(.course(":courseID", assignment: ":assignmentID")) { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"] else { return nil }
        guard let session = Session.current, let studentID = currentStudentID else { return nil }
        if assignmentID == "syllabus" {
            return CourseSyllabusViewController(courseID: courseID, studentID: studentID, session: session)
        }
        return try? AssignmentDetailsViewController(session: session, studentID: studentID, courseID: courseID, assignmentID: assignmentID)
    },

    RouteHandler(.submission(forCourse: ":courseID", assignment: ":assignmentID", user: ":userID")) { _, params in
        guard let courseID = params["courseID"], let assignmentID = params["assignmentID"], let studentID = params["userID"] else { return nil }
        guard let session = Session.current else { return nil }
        return try? AssignmentDetailsViewController(session: session, studentID: studentID, courseID: courseID, assignmentID: assignmentID)
    },

    RouteHandler(.courseGrades(":courseID")) { _, params in
        guard let courseID = params["courseID"] else { return nil }
        guard let studentID = currentStudentID else { return nil }
        return CourseDetailsViewController.create(courseID: courseID, studentID: studentID)
    },

    RouteHandler(.courseCalendarEvent(courseID: ":courseID", eventID: ":eventID")) { _, params in
        guard let courseID = params["courseID"], let eventID = params["eventID"] else { return nil }
        guard let session = Session.current, let studentID = currentStudentID else { return nil }
        return try? CalendarEventDetailsViewController(session: session, studentID: studentID, courseID: courseID, calendarEventID: eventID)
    },

    RouteHandler(.courseDiscussion(courseID: ":courseID", topicID: ":topicID")) { _, params in
        guard let courseID = params["courseID"], let topicID = params["topicID"] else { return nil }
        guard let session = Session.current, let studentID = currentStudentID else { return nil }
        return try? AnnouncementDetailsViewController(session: session, studentID: studentID, courseID: courseID, announcementID: topicID)
    },

    RouteHandler(.actionableItemCalendarEvent(eventID: ":eventID")) { _, params in
        guard let eventID = params["eventID"] else { return nil }
        guard let session = Session.current, let studentID = currentStudentID else { return nil }
        return try? CalendarEventDetailsViewController(session: session, studentID: studentID, calendarEventID: eventID)
    },

    RouteHandler(.profile) { _, _ in
        return ProfileViewController.create(enrollment: .observer)
    },

    RouteHandler(.profileObservees()) { url, _ in
        let showPromptValue = url.queryItems?.first { $0.name == "showPrompt" }?.value
        let showPrompt = Bool(showPromptValue ?? "") ?? false

        guard let session = Session.current else { return nil }
        return SettingsViewController.create(session: session, showAddStudentPrompt: showPrompt)
    },

    RouteHandler(.observeeThresholds(":userID")) { _, params in
        guard let session = Session.current, let userID = params["userID"] else { return nil }
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

    RouteHandler(.showFile(fileID: ":fileID")) { _, params in
        guard let fileID = params["fileID"] else { return nil }
        let vc = FileDetailsViewController.create(context: ContextModel.currentUser, fileID: fileID)
        return vc
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
        performUIUpdate {
            AppEnvironment.shared.loginDelegate?.openExternalURL(response?.session_url ?? url)
        }
    }
}
