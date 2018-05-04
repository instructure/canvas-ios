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
    static let loginRouteTemplate = "login"
    static let resetPasswordTemplate = "forgot_password"
    static let dashboardRouteTemplate = "dashboard"
    static let settingsRouteTemplate = "settings"
    static let addStudentRouteTemplate = "settings/add_student"
    static let viewGuidesRouteTemplate = "settings/view_guides"
    static let reportProblemRouteTemplate = "settings/report_problem"
    static let requestFeatureRouteTemplate = "settings/request_feature"
    static let studentThresholdRouteTemplate = "students/:studentID/thresholds"
    static let assignmentDetailsTemplate = "students/:studentID/courses/:courseID/assignments/:assignmentID"
    static let standaloneAssignmentDetailsTemplate = "students/:studentID/courses/:courseID/assignments/:assignmentID/standalone"
    static let courseCalendarEventsTemplate = "students/:studentID/courses/:courseID/calendar_events"
    static let calendarEventDetailsTemplate = "students/:studentID/courses/:courseID/calendar_events/:calendarEventID"
    static let standaloneCalendarEventDetailsTemplate = "students/:studentID/courses/:courseID/calendar_events/:calendarEventID/standalone"
    static let courseSyllabusTemplate = "students/:studentID/courses/:courseID/syllabus"
    static let courseAnnouncementTemplate = "students/:studentID/courses/:courseID/discussion_topics/:announcementID"
}

extension Router {
    func loginRoute(_ baseURL: URL) -> URL {
        return URL(string: RouteTemplates.loginRouteTemplate)!
    }

    func dashboardRoute() -> URL {
        return URL(string: RouteTemplates.dashboardRouteTemplate)!
    }

    func settingsRoute() -> URL {
        return URL(string: RouteTemplates.settingsRouteTemplate)!
    }

    func addStudentRoute() -> URL {
        return URL(string: RouteTemplates.addStudentRouteTemplate)!
    }

    func viewGuidesRoute() -> URL {
        return URL(string: RouteTemplates.viewGuidesRouteTemplate)!
    }

    func requestFeatureRoute() -> URL {
        return URL(string: RouteTemplates.requestFeatureRouteTemplate)!
    }

    func reportProblemRoute() -> URL {
        return URL(string: RouteTemplates.reportProblemRouteTemplate)!
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
}

extension Router {

    func addRoutes() {
        let routeDictionary = [
            RouteTemplates.loginRouteTemplate: loginRouteHandler(),
            RouteTemplates.resetPasswordTemplate: resetPasswordRouteHandler(),
            RouteTemplates.dashboardRouteTemplate: parentDashboardHandler(),
            RouteTemplates.settingsRouteTemplate: settingsPageHandler(),
            RouteTemplates.addStudentRouteTemplate: addStudentHandler(),
            RouteTemplates.viewGuidesRouteTemplate: viewGuidesHandler(),
            RouteTemplates.reportProblemRouteTemplate: reportProblemHandler(),
            RouteTemplates.requestFeatureRouteTemplate: requestFeatureHandler(),
            RouteTemplates.studentThresholdRouteTemplate: adjustThresholdsHandler(),
            RouteTemplates.assignmentDetailsTemplate: assignmentDetailsHandler(),
            RouteTemplates.standaloneAssignmentDetailsTemplate: standaloneAssignmentDetailsHandler(),
            RouteTemplates.calendarEventDetailsTemplate: calendarEventDetailsHandler(),
            RouteTemplates.standaloneCalendarEventDetailsTemplate: standaloneCalendarEventDetailsHandler(),
            RouteTemplates.courseCalendarEventsTemplate: courseCalendarEventsHandler(),
            RouteTemplates.courseSyllabusTemplate: courseSyllabusHandler(),
            RouteTemplates.courseAnnouncementTemplate: courseAnnouncementHandler()
        ]

        let handler = defaultErrorHandler()
        ErrorReporter.setErrorHandler({ error, presentingViewController in
            if let presenter = presentingViewController {
                handler(presenter, error)
            }
        })
        addRoutesWithDictionary(routeDictionary)
    }
    
    func routeToLoggedInViewController(animated: Bool = false) {
        guard let window = applicationWindow() else {
            fatalError("We don't have a window?  We're doomed!")
        }

        if let session = session {
            NotificationCenter.default.post(name: .loggedIn, object: self, userInfo: [LoggedInNotificationContentsSession: session])
        }

        let dashboardHandler = Router.sharedInstance.parentDashboardHandler()
        let dashboardVC = dashboardHandler(nil)
        Router.sharedInstance.route(window, toRootViewController: dashboardVC, animated: animated)
    }
    
    func routeToLoggedOutViewController(animated: Bool = false) {
        guard let window = applicationWindow() else {
            fatalError("We don't have a window?  We're doomed!")
        }

        NotificationCenter.default.post(name: .loggedOut, object: self)

        let initialHandler = Router.sharedInstance.loginRouteHandler()
        let initialViewController = initialHandler(nil)
        Router.sharedInstance.route(window, toRootViewController: initialViewController, animated: animated)
    }
    
    func loginRouteHandler() -> RouteHandler {
        return { params in
            let loginViewController = AirwolfLoginViewController(changePasswordInfo: nil)
            loginViewController.loggedInHandler = { session in
                Keymaster.sharedInstance.login(session)
                self.session = session
                DispatchQueue.main.async {
                    self.routeToLoggedInViewController(animated: true)
                }
            }

            return loginViewController
        }
    }

    func resetPasswordRouteHandler() -> RouteHandler {
        return { params in
            let fallback = self.loginRouteHandler()(params)
            guard let params = params, let email = params["username"] as? String, let recoveryToken = params["recovery_token"] as? String else {
                return fallback
            }

            let loginViewController = AirwolfLoginViewController(changePasswordInfo: (email: email, token: recoveryToken))
            loginViewController.loggedInHandler = { session in
                Keymaster.sharedInstance.login(session)
                self.session = session
                DispatchQueue.main.async {
                    self.routeToLoggedInViewController(animated: true)
                }
            }
            return loginViewController
        }
    }
    
    func parentDashboardHandler() -> RouteHandler {
        return { params in
            guard let session = self.session else {
                fatalError("You can't create a ParentDashboardViewController without a Session")
            }
            
            let dashboardVC = DashboardViewController.new(session: session)
            dashboardVC.settingsButtonAction = { [weak dashboardVC] session in
                guard let dashboardVC = dashboardVC else { return }
                self.route(dashboardVC, toURL: self.settingsRoute(), animated: true, modal: true)
            }
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
                self.logout()
            }
            dashboardVC.addStudentAction = { [weak dashboardVC] in
                guard let dashboardVC = dashboardVC else { return }
                self.route(dashboardVC, toURL: self.addStudentRoute(), modal: true)
            }
            
            return dashboardVC
        }
    }

    func addStudentHandler() -> RouteHandler {
        return { params in
            let selectDomainViewController = SelectDomainViewController.new()
            selectDomainViewController.dataSource = ParentSelectDomainDataSource.instance
            selectDomainViewController.pickedDomainAction = { [weak self, weak selectDomainViewController] domain, authenticationProvider in
                guard let session = self?.session else {
                    fatalError("You can't add a user without a session")
                }

                let producer = try! Student.checkDomain(session, parentID: session.user.id, domain: domain)
                producer.observe(on: UIScheduler()).startWithSignal({ signal, disposable in
                    signal.observe { event in
                        switch event {
                        case .failed(let e):
                            print("Error adding Student Domain: \(e)")
                            var createAccountTitle = NSLocalizedString("Unable to Add Student", comment: "Title for alert when failing to add student domain")
                            var createAccountMessage = e.localizedDescription
                            if e.code == 401 || e.code == 400 {
                                AirwolfAPI.validateSessionAndLogout(session, parentID: session.user.id)
                                createAccountMessage = NSLocalizedString("Invalid student domain.\nPlease double-check the domain and try again.", comment: "Alert Message for invalid domain")
                            } else if e.code == 403 {
                                createAccountMessage = NSLocalizedString("This institution has not enabled access to the Canvas Parent mobile app.", comment: "Alert Message for institution not authorized")
                            } else if e.code == 451 {
                                // just in case the server doesn't give us region info as expected
                                var region = NSLocalizedString("Unknown", comment: "Unknown region for student account")
                                do {
                                    if let data = e.data {
                                        let json = try JSONParser.JSONObjectWithData(data)
                                        let airwolfStudentRegion: String = try json <| "studentRegion"
                                        if let regionName = Region
                                            .region(forAirwolfRegionID: airwolfStudentRegion)?
                                            .name {
                                            region = regionName
                                        }
                                    }
                                } catch let e {
                                    print("JSON Parsing error for Parent <-> Student mismatch. \(e.localizedDescription)")
                                }
                                
                                createAccountTitle = NSLocalizedString("Unauthorized Region", comment: "")
                                createAccountMessage = NSLocalizedString("This institution is located outside of your selected region. To add a student at this institution, please use the “Region Picker” option on the login page to select the region of \(region), and create a new account.", comment: "")

                            }
                            let alert = UIAlertController(title: createAccountTitle, message: createAccountMessage, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                            selectDomainViewController?.present(alert, animated: true, completion: nil)
                        case .completed:
                            do {
                                let addVC = try AddStudentViewController(session: session, domain: domain, authenticationProvider: authenticationProvider) { result in
                                    if let presentor = selectDomainViewController?.presentingViewController {
                                        presentor.dismiss(animated: true)
                                    } else {
                                        let _ = selectDomainViewController?.navigationController?.popToRootViewController(animated: true)
                                    }
                                }
                                addVC.prompt = NSLocalizedString("Enter student's login information", comment: "Prompt for logging in as student")
                                selectDomainViewController?.navigationController?.pushViewController(addVC, animated: true)
                            } catch let e as NSError {
                                if let selectDomainViewController = selectDomainViewController {
                                    ErrorReporter.reportError(e, from: selectDomainViewController)
                                }
                            }
                        default:
                            break
                        }
                    }
                })
            }
            selectDomainViewController.useKeymasterLogin = false
            selectDomainViewController.allowMultipleUsers = false
            selectDomainViewController.useMobileVerify = false
            selectDomainViewController.prompt = NSLocalizedString("Find your student's school or district", comment: "Domain Picker Search Placeholder")
            return UINavigationController(rootViewController: selectDomainViewController)
        }
    }

    func viewGuidesHandler() -> RouteHandler {
        return { params in
            let webBrowser = WebBrowserViewController(useAPISafeLinks: false, isModal: false)
            webBrowser.url = URL(string: "https://community.canvaslms.com/community/answers/guides/")!
            return webBrowser
        }
    }

    func reportProblemHandler() -> RouteHandler {
        return { params in
            guard let session = self.session else {
                fatalError("You can't create a ParentDashboardViewController without a Session")
            }

            let supportTicketVC = SupportTicketViewController.new(session, type: .problem)
            return supportTicketVC
        }
    }

    func requestFeatureHandler() -> RouteHandler {
        return { params in
            guard let session = self.session else {
                fatalError("You can't create a ParentDashboardViewController without a Session")
            }
            
            let supportTicketVC = SupportTicketViewController.new(session, type: .featureRequest)
            return supportTicketVC
        }
    }
    
    func settingsPageHandler() -> RouteHandler {
        return { params in
            guard let session = self.session else {
                fatalError("You can't get to the Settings Page without a Session")
            }

            let settingsVC = SettingsViewController.new(session: session)
            
            settingsVC.closeAction = { [weak settingsVC] session in
                settingsVC?.dismiss(animated: true, completion: nil)
            }

            settingsVC.addObserveeAction = { [weak settingsVC] session in
                guard let settingsVC = settingsVC else { return }
                self.route(settingsVC, toURL: self.addStudentRoute(), modal: true)
            }

            settingsVC.requestFeatureAction = { [weak settingsVC] session in
                guard let settingsVC = settingsVC else { return }
                self.route(settingsVC, toURL: self.requestFeatureRoute())
            }

            settingsVC.reportProblemAction = { [weak settingsVC] session in
                guard let settingsVC = settingsVC else { return }
                self.route(settingsVC, toURL: self.reportProblemRoute())
            }

            settingsVC.viewGuidesAction = { [weak settingsVC] session in
                guard let settingsVC = settingsVC else { return }
                self.route(settingsVC, toURL: self.viewGuidesRoute())
            }
            
            settingsVC.observeeSelectedAction = { [weak settingsVC] session, observee in
                guard let settingsVC = settingsVC else { return }
                self.route(settingsVC, toURL: self.thresholdSettingsRoute(studentID: String(observee.id)))
            }
            
            settingsVC.logoutAction = { session in
                self.logout()
            }

            let navigationController = UINavigationController.coloredTriangleNavigationController(withRootViewController: settingsVC)
            navigationController.modalPresentationStyle = .formSheet
            return navigationController
        }
    }

    func adjustThresholdsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? String else {
                fatalError("You can't edit thresholds without a Session and studentID")
            }

            let studentSettingsVC = StudentSettingsViewController.new(session, studentID: studentID)
            return studentSettingsVC
        }
    }

    func courseCalendarEventsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? String, let courseID = parameters["courseID"] as? NSNumber else {
                fatalError("You can't show an course without having a session, student and course id!")
            }

            let calendarWeekPageVC = CalendarEventWeekPageViewController.new(session: session, studentID: studentID, contextCodes: [ContextID(id: courseID.stringValue, context: .course).canvasContextID])
            calendarWeekPageVC.selectCalendarEventAction = { session, studentID, calendarEvent in
                switch calendarEvent.type {
                case .assignment, .quiz:
                    guard let assignmentID = calendarEvent.assignmentID else { fallthrough }
                    self.route(calendarWeekPageVC, toURL: self.standaloneAssignmentDetailsRoute(studentID: studentID, courseID: courseID.stringValue, assignmentID: assignmentID), modal: false)
                default:
                    self.route(calendarWeekPageVC, toURL: self.standaloneCalendarEventDetailsRoute(studentID: studentID, courseID: courseID.stringValue, calendarEventID: calendarEvent.id), modal: false)
                }
            }
            calendarWeekPageVC.useBackgroundView = true

            calendarWeekPageVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: calendarWeekPageVC, action: #selector(CalendarEventWeekPageViewController.close(_:)))
            calendarWeekPageVC.navigationItem.leftBarButtonItem?.tintColor = .white
            calendarWeekPageVC.navigationItem.leftBarButtonItem?.accessibilityLabel = NSLocalizedString("Close", comment: "Close Button Title")
            calendarWeekPageVC.navigationItem.leftBarButtonItem?.accessibilityIdentifier = "close_button"

            // Only add syllabus if the course has a syllabus
            session.enrollmentsDataSource(withScope: studentID.stringValue).producer(ContextID(id: courseID.stringValue, context: .course)).observe(on: UIScheduler()).startWithValues { next in
                guard let course = next as? Course else { return }

                calendarWeekPageVC.title = course.name

                guard let _ = course.syllabusBody else { return }

                let image = UIImage(named: "icon_document_fill")?.imageScaledByPercentage(0.75)
                let syllabusButton = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
                syllabusButton.accessibilityLabel = NSLocalizedString("Syllabus", comment: "Syllabus Button Title")
                syllabusButton.accessibilityIdentifier = "syllabus_button"
                let close = Action<(), (), NoError>() { _ in
                    self.route(calendarWeekPageVC, toURL: self.courseSyllabusRoute(studentID: studentID.stringValue, courseID: courseID.stringValue))
                    return .empty
                }
                syllabusButton.reactive.pressed = CocoaAction(close)
                syllabusButton.tintColor = .white
                calendarWeekPageVC.navigationItem.rightBarButtonItem = syllabusButton
            }

            let navController = UINavigationController.coloredTriangleNavigationController(withRootViewController: calendarWeekPageVC, forObservee: studentID.stringValue)
            navController.navigationBar.tintColor = .white
            navController.navigationBar.accessibilityIdentifier = "navigation_bar"
            return navController
        }
    }

    func assignmentDetailsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? String, let courseID = parameters["courseID"] as? NSNumber, let assignmentID = parameters["assignmentID"] as? NSNumber else {
                fatalError("You can't show an assignment without having a session, course and assignment id!")
            }

            let assignmentDetailsVC = try! AssignmentDetailsViewController(session: session, studentID: studentID, courseID: courseID.stringValue, assignmentID: assignmentID.stringValue)

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

            let navController = UINavigationController.coloredTriangleNavigationController(withRootViewController: assignmentDetailsVC, forObservee: studentID.stringValue)
            return navController
        }
    }

    func standaloneAssignmentDetailsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? String, let courseID = parameters["courseID"] as? NSNumber, let assignmentID = parameters["assignmentID"] as? NSNumber else {
                fatalError("You can't show an assignment without having a session, course and assignment id!")
            }

            let assignmentDetailsVC = try! AssignmentDetailsViewController(session: session, studentID: studentID, courseID: courseID.stringValue, assignmentID: assignmentID.stringValue)
            return assignmentDetailsVC
        }
    }

    func calendarEventDetailsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? String, let calendarEventID = parameters["calendarEventID"] as? NSNumber, let courseID = parameters["courseID"] as? NSNumber else {
                fatalError("You can't show a calendar event without having a session and a calendar event id!")
            }

            let calendarEventDetailsVC = try! CalendarEventDetailsViewController(session: session, studentID: studentID, courseID: courseID.stringValue, calendarEventID: calendarEventID.stringValue)

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

            let navController = UINavigationController.coloredTriangleNavigationController(withRootViewController: calendarEventDetailsVC, forObservee: studentID.stringValue)
            return navController
        }
    }

    func standaloneCalendarEventDetailsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? String, let calendarEventID = parameters["calendarEventID"] as? NSNumber, let courseID = parameters["courseID"] as? NSNumber else {
                fatalError("You can't show a calendar event without having a session and a calendar event id!")
            }

            let calendarEventDetailsVC = try! CalendarEventDetailsViewController(session: session, studentID: studentID, courseID: courseID.stringValue, calendarEventID: calendarEventID.stringValue)
            calendarEventDetailsVC.navigationItem.leftBarButtonItem?.tintColor = .white

            return calendarEventDetailsVC
        }
    }

    func courseSyllabusHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? String, let courseID = parameters["courseID"] as? NSNumber else {
                fatalError("You can't show a course syllabus without having a session, course id and an student id!")
            }

            let syllabusVC = CourseSyllabusViewController(courseID: courseID.stringValue, studentID: studentID, session: session)
            syllabusVC.navigationItem.title = NSLocalizedString("Syllabus", comment: "")
            return syllabusVC
        }
    }

    func courseAnnouncementHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, let parameters = params, let studentID = parameters["studentID"] as? String, let courseID = parameters["courseID"] as? NSNumber, let announcementID = parameters["announcementID"] as? NSNumber else {
                ❨╯°□°❩╯⌢"You can't show a course announcement with having a session, studentID, courseID and an announcementID dude!"
            }

            let announcementVC = try! AnnouncementDetailsViewController(session: session, studentID: studentID, courseID: courseID.stringValue, announcementID: announcementID.stringValue)
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

            let navController = UINavigationController.coloredTriangleNavigationController(withRootViewController: announcementVC, forObservee: studentID.stringValue)
            return navController
        }
    }

    func logout() {
        self.session = nil
        Keymaster.sharedInstance.logout()
        routeToLoggedOutViewController(animated: true)
    }
}

extension Router {
    func applicationWindow() -> UIWindow? {
        return appDelegate().window
    }

    func appDelegate() -> AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("How is the App Delegate wrong?")
        }

        return appDelegate
    }
}
