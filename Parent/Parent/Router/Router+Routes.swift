//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import UIKit

import Result


import ReactiveSwift
import ReactiveCocoa
import CanvasCore

import CanvasCore
import Marshal

let LoggedInNotificationContentsSession = "LoggedInNotificationContentsSession"

extension NSNotification.Name {
    static let loggedIn = NSNotification.Name(rawValue: "LoggedInNotificationName")
    static let loggedOut = NSNotification.Name(rawValue: "LoggedOutNotificationName")
}

class RouteTemplates {
    static let dashboardRouteTemplate = "dashboard"
    static let settingsRouteTemplate = "settings"
    static let studentThresholdRouteTemplate = "students/:studentID/thresholds"
    static let assignmentDetailsTemplate = "students/:studentID/courses/:courseID/assignments/:assignmentID"
    static let standaloneAssignmentDetailsTemplate = "students/:studentID/courses/:courseID/assignments/:assignmentID/standalone"
    static let courseTemplate = "students/:studentID/courses/:courseID"
    static let courseCalendarEventsTemplate = "students/:studentID/courses/:courseID/calendar_events"
    static let calendarEventDetailsTemplate = "students/:studentID/courses/:courseID/calendar_events/:calendarEventID"
    static let standaloneCalendarEventDetailsTemplate = "students/:studentID/courses/:courseID/calendar_events/:calendarEventID/standalone"
    static let courseSyllabusTemplate = "students/:studentID/courses/:courseID/syllabus"
    static let courseAnnouncementTemplate = "students/:studentID/courses/:courseID/discussion_topics/:announcementID"
    static let accountNotificationTemplate = "students/:studentID/account_notifications/:announcementID"
}

extension Router {
    func dashboardRoute() -> URL {
        return URL(string: RouteTemplates.dashboardRouteTemplate)!
    }

    func settingsRoute() -> URL {
        return URL(string: RouteTemplates.settingsRouteTemplate)!
    }

    func thresholdSettingsRoute(studentID: String) -> URL {
        return URL(string: "students/\(studentID)/thresholds")!
    }

    func assignmentDetailsRoute(studentID: String, courseID: String, assignmentID: String) -> URL {
        return URL(string: "students/\(studentID)/courses/\(courseID)/assignments/\(assignmentID)")!
    }

    func standaloneAssignmentDetailsRoute(studentID: String, courseID: String, assignmentID: String) -> URL {
        return URL(string: "students/\(studentID)/courses/\(courseID)/assignments/\(assignmentID)/standalone")!
    }

    func calendarEventDetailsRoute(studentID: String, courseID: String, calendarEventID: String) -> URL {
        return URL(string: "students/\(studentID)/courses/\(courseID)/calendar_events/\(calendarEventID)")!
    }

    func standaloneCalendarEventDetailsRoute(studentID: String, courseID: String, calendarEventID: String) -> URL {
        return URL(string: "students/\(studentID)/courses/\(courseID)/calendar_events/\(calendarEventID)/standalone")!
    }

    func courseCalendarEventsRoute(studentID: String, courseID: String) -> URL {
        return URL(string: "students/\(studentID)/courses/\(courseID)/calendar_events")!
    }

    func courseSyllabusRoute(studentID: String, courseID: String) -> URL {
        return URL(string: "students/\(studentID)/courses/\(courseID)/syllabus")!
    }

    func courseAnnouncementRoute(studentID: String, courseID: String, announcementID: String) -> URL {
        return URL(string: "students/\(studentID)/courses/\(courseID)/discussion_topics/\(announcementID)")!
    }

    func alertRoute(studentID: String, alertAssetPath: String) -> URL? {
        let components = URLComponents(string: alertAssetPath)
        guard let path = components?.path else { return nil }
        return URL(string: "students/\(studentID)")!.appendingPathComponent(path)
    }

    func accountNotificationRoute(studentID: String, announcementID: String) -> URL {
        return URL(string: "students/\(studentID)/account_notifications/\(announcementID)")!
    }
}

extension Router {

    func addRoutes() {
        let routeDictionary = [
            RouteTemplates.dashboardRouteTemplate: parentDashboardHandler(),
            RouteTemplates.settingsRouteTemplate: settingsPageHandler(),
            RouteTemplates.studentThresholdRouteTemplate: adjustThresholdsHandler(),
            RouteTemplates.assignmentDetailsTemplate: assignmentDetailsHandler(),
            RouteTemplates.standaloneAssignmentDetailsTemplate: standaloneAssignmentDetailsHandler(),
            RouteTemplates.calendarEventDetailsTemplate: calendarEventDetailsHandler(),
            RouteTemplates.standaloneCalendarEventDetailsTemplate: standaloneCalendarEventDetailsHandler(),
            RouteTemplates.courseTemplate: courseCalendarEventsHandler(),
            RouteTemplates.courseCalendarEventsTemplate: courseCalendarEventsHandler(),
            RouteTemplates.courseSyllabusTemplate: courseSyllabusHandler(),
            RouteTemplates.courseAnnouncementTemplate: courseAnnouncementHandler(),
            RouteTemplates.accountNotificationTemplate: accountNotificationHandler()
        ]

        let handler = defaultErrorHandler()
        ErrorReporter.setErrorHandler({ error, presentingViewController in
            if let presenter = presentingViewController {
                handler(presenter, error)
            }
        })
        addRoutesWithDictionary(routeDictionary)
    }
    
    func parentDashboardHandler() -> RouteHandler {
        return { params in
            guard let session = self.session else {
                return nil
            }
            
            let dashboardVC = DashboardViewController.new(session: session)
            dashboardVC.selectCalendarEventAction = { [weak dashboardVC] session, studentID, calendarEvent in
                guard let dashboardVC = dashboardVC else { return }
                guard let courseID = ContextID(canvasContext: calendarEvent.contextCode)?.id else {
                    return
                }

                switch calendarEvent.type {
                case .assignment, .quiz:
                    guard let assignmentID = calendarEvent.assignmentID else { fallthrough }
                    self.route(dashboardVC, toURL: self.assignmentDetailsRoute(studentID: studentID, courseID: courseID, assignmentID: assignmentID), modal: true)
                default:
                    self.route(dashboardVC, toURL: self.calendarEventDetailsRoute(studentID: studentID, courseID: courseID, calendarEventID: calendarEvent.id), modal: true)
                }


            }
            dashboardVC.selectCourseAction = { [weak dashboardVC] session, studentID, course in
                guard let dashboardVC = dashboardVC else { return }
                self.route(dashboardVC, toURL: self.courseCalendarEventsRoute(studentID: studentID, courseID: course.id), modal: true)
            }
            dashboardVC.logoutAction = {
                CanvasKeymaster.the().logout()
            }
            
            
            let navController = UINavigationController.parentNavigationController(withRootViewController: dashboardVC)
            navController.navigationBar.accessibilityIdentifier = "navigation_bar"
            return navController
        }
    }
    
    func settingsPageHandler() -> RouteHandler {
        return { params in
            guard let session = self.session else {
                return nil
            }

            let settingsVC = SettingsViewController.new(session: session)
            
            settingsVC.closeAction = { [weak settingsVC] session in
                settingsVC?.dismiss(animated: true, completion: nil)
            }
            
            settingsVC.observeeSelectedAction = { [weak settingsVC] session, observee in
                guard let settingsVC = settingsVC else { return }
                self.route(settingsVC, toURL: self.thresholdSettingsRoute(studentID: String(observee.id)))
            }

            return settingsVC
        }
    }

    func adjustThresholdsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID: String = try? parameters.stringID("studentID") else {
                return nil
            }

            return StudentSettingsViewController.new(session, studentID: studentID)
        }
    }

    func courseCalendarEventsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID: String = try? parameters.stringID("studentID"), let courseID: String = try? parameters.stringID("courseID") else {
                return nil
            }

            let calendarWeekPageVC = CalendarEventWeekPageViewController.new(session: session, studentID: studentID, contextCodes: [ContextID(id: courseID, context: .course).canvasContextID])
            calendarWeekPageVC.selectCalendarEventAction = { session, studentID, calendarEvent in
                switch calendarEvent.type {
                case .assignment, .quiz:
                    guard let assignmentID = calendarEvent.assignmentID else { fallthrough }
                    self.route(calendarWeekPageVC, toURL: self.standaloneAssignmentDetailsRoute(studentID: studentID, courseID: courseID, assignmentID: assignmentID), modal: false)
                default:
                    self.route(calendarWeekPageVC, toURL: self.standaloneCalendarEventDetailsRoute(studentID: studentID, courseID: courseID, calendarEventID: calendarEvent.id), modal: false)
                }
            }

            calendarWeekPageVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: calendarWeekPageVC, action: #selector(CalendarEventWeekPageViewController.close(_:)))
            calendarWeekPageVC.navigationItem.leftBarButtonItem?.tintColor = .white
            calendarWeekPageVC.navigationItem.leftBarButtonItem?.accessibilityLabel = NSLocalizedString("Close", comment: "Close Button Title")
            calendarWeekPageVC.navigationItem.leftBarButtonItem?.accessibilityIdentifier = "close_button"

            // Only add syllabus if the course has a syllabus
            session.enrollmentsDataSource(withScope: studentID).producer(ContextID(id: courseID, context: .course)).observe(on: UIScheduler()).startWithValues { next in
                guard let course = next as? Course else { return }

                calendarWeekPageVC.title = course.name

                guard let _ = course.syllabusBody else { return }

                let image = UIImage(named: "icon_document_fill")?.imageScaledByPercentage(0.75)
                let syllabusButton = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
                syllabusButton.accessibilityLabel = NSLocalizedString("Syllabus", comment: "Syllabus Button Title")
                syllabusButton.accessibilityIdentifier = "syllabus_button"
                let close = Action<(), (), NoError>() { _ in
                    self.route(calendarWeekPageVC, toURL: self.courseSyllabusRoute(studentID: studentID, courseID: courseID))
                    return .empty
                }
                syllabusButton.reactive.pressed = CocoaAction(close)
                syllabusButton.tintColor = .white
                calendarWeekPageVC.navigationItem.rightBarButtonItem = syllabusButton
            }

            let navController = UINavigationController.parentNavigationController(withRootViewController: calendarWeekPageVC, forObservee: studentID)
            navController.navigationBar.accessibilityIdentifier = "navigation_bar"
            return navController
        }
    }

    func assignmentDetailsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? NSNumber, let courseID = parameters["courseID"] as? NSNumber, let assignmentID = parameters["assignmentID"] as? NSNumber else {
                return nil
            }

            let assignmentDetailsVC = try! AssignmentDetailsViewController(session: session, studentID: studentID.stringValue, courseID: courseID.stringValue, assignmentID: assignmentID.stringValue)

            let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
            closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Close Button Title")
            closeButton.accessibilityIdentifier = "close_button"
            let close = Action<(), (), NoError>() { _ in
                assignmentDetailsVC.dismiss(animated: true, completion: nil)
                return .empty
            }
            closeButton.reactive.pressed = CocoaAction(close)
            assignmentDetailsVC.navigationItem.leftBarButtonItem = closeButton
            assignmentDetailsVC.navigationItem.leftBarButtonItem?.tintColor = .white

            return UINavigationController.parentNavigationController(withRootViewController: assignmentDetailsVC, forObservee: studentID.stringValue)
        }
    }

    func standaloneAssignmentDetailsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? NSNumber, let courseID = parameters["courseID"] as? NSNumber, let assignmentID = parameters["assignmentID"] as? NSNumber else {
                return nil
            }

            let assignmentDetailsVC = try! AssignmentDetailsViewController(session: session, studentID: studentID.stringValue, courseID: courseID.stringValue, assignmentID: assignmentID.stringValue)
            return assignmentDetailsVC
        }
    }

    func calendarEventDetailsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? NSNumber, let calendarEventID = parameters["calendarEventID"] as? NSNumber, let courseID = parameters["courseID"] as? NSNumber else {
                return nil
            }

            let calendarEventDetailsVC = try! CalendarEventDetailsViewController(session: session, studentID: studentID.stringValue, courseID: courseID.stringValue, calendarEventID: calendarEventID.stringValue)

            let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
            closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Close Button Title")
            closeButton.accessibilityIdentifier = "close_button"
            let close = Action<(), (), NoError>() {
                calendarEventDetailsVC.dismiss(animated: true, completion: nil)
                return .empty
            }
            closeButton.reactive.pressed = CocoaAction(close)
            calendarEventDetailsVC.navigationItem.leftBarButtonItem = closeButton
            calendarEventDetailsVC.navigationItem.leftBarButtonItem?.tintColor = .white

            return UINavigationController.parentNavigationController(withRootViewController: calendarEventDetailsVC, forObservee: studentID.stringValue)
        }
    }

    func standaloneCalendarEventDetailsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? NSNumber, let calendarEventID = parameters["calendarEventID"] as? NSNumber, let courseID = parameters["courseID"] as? NSNumber else {
                return nil
            }

            let calendarEventDetailsVC = try! CalendarEventDetailsViewController(session: session, studentID: studentID.stringValue, courseID: courseID.stringValue, calendarEventID: calendarEventID.stringValue)
            calendarEventDetailsVC.navigationItem.leftBarButtonItem?.tintColor = .white

            return calendarEventDetailsVC
        }
    }

    func courseSyllabusHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? NSNumber, let courseID = parameters["courseID"] as? NSNumber else {
                return nil
            }

            let syllabusVC = CourseSyllabusViewController(courseID: courseID.stringValue, studentID: studentID.stringValue, session: session)
            syllabusVC.navigationItem.title = NSLocalizedString("Syllabus", comment: "")
            return syllabusVC
        }
    }

    func courseAnnouncementHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? NSNumber, let courseID = parameters["courseID"] as? NSNumber, let announcementID = parameters["announcementID"] as? NSNumber else {
                return nil
            }

            let announcementVC = try! AnnouncementDetailsViewController(session: session, studentID: studentID.stringValue, courseID: courseID.stringValue, announcementID: announcementID.stringValue)
            let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
            closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Close Button Title")
            closeButton.accessibilityIdentifier = "close_button"
            let close = Action<(),(), NoError>() { _ in
                announcementVC.dismiss(animated: true, completion: nil)
                return .empty
            }
            closeButton.reactive.pressed = CocoaAction(close)
            announcementVC.navigationItem.leftBarButtonItem = closeButton
            announcementVC.navigationItem.leftBarButtonItem?.tintColor = .white

            return UINavigationController.parentNavigationController(withRootViewController: announcementVC, forObservee: studentID.stringValue)
        }
    }

    func accountNotificationHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID: String = try? parameters.stringID("studentID"), let announcementID: String = try? parameters.stringID("announcementID") else {
                return nil
            }
            let announcementVC = try! AccountNotificationViewController(session: session, announcementID: announcementID)
            let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
            closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Close Button Title")
            closeButton.accessibilityIdentifier = "close_button"
            let close = Action<(),(), NoError>() { _ in
                announcementVC.dismiss(animated: true, completion: nil)
                return .empty
            }
            closeButton.reactive.pressed = CocoaAction(close)
            announcementVC.navigationItem.leftBarButtonItem = closeButton
            announcementVC.navigationItem.leftBarButtonItem?.tintColor = .white
            return UINavigationController.parentNavigationController(withRootViewController: announcementVC, forObservee: studentID)
        }
    }
}

extension Router {
    func applicationWindow() -> UIWindow? {
        return appDelegate().window
    }

    func appDelegate() -> ParentAppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? ParentAppDelegate else {
            fatalError("How is the App Delegate wrong?")
        }

        return appDelegate
    }
}
