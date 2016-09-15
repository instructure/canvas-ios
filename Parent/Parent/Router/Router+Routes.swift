//
//  Router+Routes.swift
//  Parent
//
//  Created by Brandon Pluim on 12/15/15.
//  Copyright © 2015 Instructure Inc. All rights reserved.
//

import UIKit

import Result
import TooLegit
import Keymaster
import ReactiveCocoa
import EnrollmentKit
import Airwolf
import SoLazy
import SoPersistent
import SoSupportive

let LoggedInNotificationName = "LoggedInNotificationName"
let LoggedInNotificationContentsSession = "LoggedInNotificationContentsSession"
let LoggedOutNotificationName = "LoggedOutNotificationName"

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
    func loginRoute(baseURL: NSURL) -> NSURL {
        return NSURL(string: RouteTemplates.loginRouteTemplate)!
    }

    func dashboardRoute() -> NSURL {
        return NSURL(string: RouteTemplates.dashboardRouteTemplate)!
    }

    func settingsRoute() -> NSURL {
        return NSURL(string: RouteTemplates.settingsRouteTemplate)!
    }

    func addStudentRoute() -> NSURL {
        return NSURL(string: RouteTemplates.addStudentRouteTemplate)!
    }

    func viewGuidesRoute() -> NSURL {
        return NSURL(string: RouteTemplates.viewGuidesRouteTemplate)!
    }

    func requestFeatureRoute() -> NSURL {
        return NSURL(string: RouteTemplates.requestFeatureRouteTemplate)!
    }

    func reportProblemRoute() -> NSURL {
        return NSURL(string: RouteTemplates.reportProblemRouteTemplate)!
    }

    func thresholdSettingsRoute(studentID studentID: String) -> NSURL {
        return NSURL(string: "students/\(studentID)/thresholds")!
    }

    func assignmentDetailsRoute(studentID studentID: String, courseID: String, assignmentID: String) -> NSURL {
        return NSURL(string: "students/\(studentID)/courses/\(courseID)/assignments/\(assignmentID)")!
    }

    func standaloneAssignmentDetailsRoute(studentID studentID: String, courseID: String, assignmentID: String) -> NSURL {
        return NSURL(string: "students/\(studentID)/courses/\(courseID)/assignments/\(assignmentID)/standalone")!
    }

    func calendarEventDetailsRoute(studentID studentID: String, courseID: String, calendarEventID: String) -> NSURL {
        return NSURL(string: "students/\(studentID)/courses/\(courseID)/calendar_events/\(calendarEventID)")!
    }

    func standaloneCalendarEventDetailsRoute(studentID studentID: String, courseID: String, calendarEventID: String) -> NSURL {
        return NSURL(string: "students/\(studentID)/courses/\(courseID)/calendar_events/\(calendarEventID)/standalone")!
    }

    func courseCalendarEventsRoute(studentID studentID: String, courseID: String) -> NSURL {
        return NSURL(string: "students/\(studentID)/courses/\(courseID)/calendar_events")!
    }

    func courseSyllabusRoute(studentID studentID: String, courseID: String) -> NSURL {
        return NSURL(string: "students/\(studentID)/courses/\(courseID)/syllabus")!
    }

    func courseAnnouncementRoute(studentID studentID: String, courseID: String, announcementID: String) -> NSURL {
        return NSURL(string: "students/\(studentID)/courses/\(courseID)/discussion_topics/\(announcementID)")!
    }

    func alertRoute(studentID studentID: String, alertAssetPath: String) -> NSURL? {
        let components = NSURLComponents(string: alertAssetPath)
        guard let path = components?.path else { return nil }
        return NSURL(string: "students/\(studentID)")!.URLByAppendingPathComponent(path)
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

        TableViewController.defaultErrorHandler = defaultErrorHandler()
        addRoutesWithDictionary(routeDictionary)
    }
    
    func routeToLoggedInViewController(animated animated: Bool = false) {
        guard let window = applicationWindow() else {
            fatalError("We don't have a window?  We're doomed!")
        }

        if let session = session {
            NSNotificationCenter.defaultCenter().postNotificationName(LoggedInNotificationName, object: self, userInfo: [LoggedInNotificationContentsSession: session])
        }

        let dashboardHandler = Router.sharedInstance.parentDashboardHandler()
        let dashboardVC = dashboardHandler(params: nil)
        Router.sharedInstance.route(window, toRootViewController: dashboardVC, animated: animated)
    }
    
    func routeToLoggedOutViewController(animated animated: Bool = false) {
        guard let window = applicationWindow() else {
            fatalError("We don't have a window?  We're doomed!")
        }

        NSNotificationCenter.defaultCenter().postNotificationName(LoggedOutNotificationName, object: self)

        let initialHandler = Router.sharedInstance.loginRouteHandler()
        let initialViewController = initialHandler(params: nil)
        Router.sharedInstance.route(window, toRootViewController: initialViewController, animated: animated)
    }
    
    func loginRouteHandler() -> RouteHandler {
        return { params in
            let loginViewController = AirwolfLoginViewController()
            loginViewController.loggedInHandler = { session in
                Keymaster.sharedInstance.login(session)
                self.session = session
                dispatch_async(dispatch_get_main_queue()) {
                    self.routeToLoggedInViewController(animated: true)
                }
            }

            return loginViewController
        }
    }

    func resetPasswordRouteHandler() -> RouteHandler {
        return { params in
            let fallback = self.loginRouteHandler()(params: params)
            guard let params = params, email = params["username"] as? String, recoveryToken = params["recovery_token"] as? String else {
                return fallback
            }

            let loginViewController = AirwolfLoginViewController(changePasswordInfo: (email: email, token: recoveryToken))
            loginViewController.loggedInHandler = { session in
                Keymaster.sharedInstance.login(session)
                self.session = session
                dispatch_async(dispatch_get_main_queue()) {
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
            dashboardVC.settingsButtonAction = { session in
                self.route(dashboardVC, toURL: self.settingsRoute(), animated: true, modal: true)
            }
            dashboardVC.selectCalendarEventAction = { session, studentID, calendarEvent in
                guard let courseID = ContextID(canvasContext: calendarEvent.contextCode)?.id else {
                    return
                }

                switch calendarEvent.type {
                case .Assignment, .Quiz:
                    guard let assignmentID = calendarEvent.assignmentID else { fallthrough }
                    self.route(dashboardVC, toURL: self.assignmentDetailsRoute(studentID: studentID, courseID: courseID, assignmentID: assignmentID), modal: true)
                default:
                    self.route(dashboardVC, toURL: self.calendarEventDetailsRoute(studentID: studentID, courseID: courseID, calendarEventID: calendarEvent.id), modal: true)
                }


            }
            dashboardVC.selectCourseAction = { session, studentID, course in
                self.route(dashboardVC, toURL: self.courseCalendarEventsRoute(studentID: studentID, courseID: course.id), modal: true)
            }
            dashboardVC.logoutAction = {
                self.logout()
            }
            dashboardVC.addStudentAction = {
                self.route(dashboardVC, toURL: self.addStudentRoute())
            }
            
            return dashboardVC
        }
    }

    func addStudentHandler() -> RouteHandler {
        return { params in
            let selectDomainViewController = SelectDomainViewController.new()
            selectDomainViewController.dataSource = self.appDelegate()
            selectDomainViewController.pickedDomainAction = { [unowned self] domain in
                guard let session = self.session else {
                    fatalError("You can't add a user without a session")
                }
                let producer = try! Student.checkDomain(session, parentID: session.user.id, domain: domain)
                producer.observeOn(UIScheduler()).startWithSignal({ signal, disposable in
                                        signal.observe { event in
                                            switch event {
                                            case .Failed(let e):
                                                print("Error adding Student Domain: \(e)")
                                                let createAccountTitle = NSLocalizedString("Unable to Add Student", comment: "Title for alert when failing to add student domain")
                                                var createAccountMessage = e.localizedDescription
                                                if e.code == 401 {
                                                    createAccountMessage = NSLocalizedString("Invalid student domain.\nPlease double-check the domain and try again.", comment: "Alert Message for invalid domain")
                                                } else if e.code == 403 {
                                                    createAccountMessage = NSLocalizedString("This institution has not enabled access to the Canvas Parent mobile app.", comment: "Alert Message for institution not authorized")
                                                }
                                                let alert = UIAlertController(title: createAccountTitle, message: createAccountMessage, preferredStyle: .Alert)
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                                                selectDomainViewController.presentViewController(alert, animated: true, completion: nil)
                                            case .Completed:
                                                let addVC = AddStudentViewController(session: session, domain: domain, useBackButton: true) { result in
                                                    selectDomainViewController.navigationController?.popToRootViewControllerAnimated(true)
                                                }
                                                addVC.prompt = NSLocalizedString("Enter student's login information", comment: "Prompt for logging in as student")
                                                selectDomainViewController.navigationController?.pushViewController(addVC, animated: true)
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
            return selectDomainViewController
        }
    }

    func viewGuidesHandler() -> RouteHandler {
        return { params in
            let webBrowser = WebBrowserViewController(useAPISafeLinks: false, isModal: false)
            webBrowser.url = NSURL(string: "https://community.canvaslms.com/community/answers/guides/")!
            return webBrowser
        }
    }

    func reportProblemHandler() -> RouteHandler {
        return { params in
            guard let session = self.session else {
                fatalError("You can't create a ParentDashboardViewController without a Session")
            }

            let supportTicketVC = SupportTicketViewController.new(session, type: .Problem)
            return supportTicketVC
        }
    }

    func requestFeatureHandler() -> RouteHandler {
        return { params in
            guard let session = self.session else {
                fatalError("You can't create a ParentDashboardViewController without a Session")
            }
            
            let supportTicketVC = SupportTicketViewController.new(session, type: .FeatureRequest)
            return supportTicketVC
        }
    }
    
    func settingsPageHandler() -> RouteHandler {
        return { params in
            guard let session = self.session else {
                fatalError("You can't get to the Settings Page without a Session")
            }
            
            let settingsVC = SettingsViewController.new(session: session)
            
            settingsVC.closeAction = { session in
                settingsVC.dismissViewControllerAnimated(true, completion: nil)
            }

            settingsVC.addObserveeAction = { session in
                self.route(settingsVC, toURL: self.addStudentRoute())
            }

            settingsVC.requestFeatureAction = { session in
                self.route(settingsVC, toURL: self.requestFeatureRoute())
            }

            settingsVC.reportProblemAction = { session in
                self.route(settingsVC, toURL: self.reportProblemRoute())
            }

            settingsVC.viewGuidesAction = { session in
                self.route(settingsVC, toURL: self.viewGuidesRoute())
            }
            
            settingsVC.observeeSelectedAction = { session, observee in
                self.route(settingsVC, toURL: self.thresholdSettingsRoute(studentID: String(observee.id)))
            }
            
            settingsVC.logoutAction = { session in
                self.logout()
            }

            let navigationController = UINavigationController.coloredTriangleNavigationController(withRootViewController: settingsVC)
            navigationController.modalPresentationStyle = .FormSheet
            return navigationController
        }
    }

    func adjustThresholdsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, parameters = params, studentID = parameters["studentID"] as? String else {
                fatalError("You can't edit thresholds without a Session and studentID")
            }

            let studentSettingsVC = StudentSettingsViewController.new(session, studentID: studentID)
            return studentSettingsVC
        }
    }

    func courseCalendarEventsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, parameters = params, studentID = parameters["studentID"] as? String, courseID = parameters["courseID"] as? NSNumber else {
                fatalError("You can't show an course without having a session, student and course id!")
            }

            let calendarWeekPageVC = CalendarEventWeekPageViewController.new(session: session, studentID: studentID, contextCodes: [ContextID(id: courseID.stringValue, context: .Course).canvasContextID])
            calendarWeekPageVC.selectCalendarEventAction = { session, studentID, calendarEvent in
                switch calendarEvent.type {
                case .Assignment:
                    guard let assignmentID = calendarEvent.assignmentID else { fallthrough }
                    self.route(calendarWeekPageVC, toURL: self.standaloneAssignmentDetailsRoute(studentID: studentID, courseID: courseID.stringValue, assignmentID: assignmentID), modal: false)
                default:
                    self.route(calendarWeekPageVC, toURL: self.standaloneCalendarEventDetailsRoute(studentID: studentID, courseID: courseID.stringValue, calendarEventID: calendarEvent.id), modal: false)
                }
            }
            calendarWeekPageVC.useBackgroundView = true

            calendarWeekPageVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: calendarWeekPageVC, action: #selector(CalendarEventWeekPageViewController.close(_:)))
            calendarWeekPageVC.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
            calendarWeekPageVC.navigationItem.leftBarButtonItem?.accessibilityLabel = NSLocalizedString("Close", comment: "Close Button Title")
            calendarWeekPageVC.navigationItem.leftBarButtonItem?.accessibilityIdentifier = "close_button"

            // Only add syllabus if the course has a syllabus
            session.enrollmentsDataSource(withScope: studentID.stringValue).producer(ContextID(id: courseID.stringValue, context: .Course)).observeOn(UIScheduler()).startWithNext { next in
                guard let course = next as? Course else { return }

                calendarWeekPageVC.title = course.name

                guard let _ = course.syllabusBody else { return }

                let image = UIImage(named: "icon_document_fill")?.imageScaledByPercentage(0.75)
                let syllabusButton = UIBarButtonItem(image: image, style: .Plain, target: nil, action: nil)
                syllabusButton.accessibilityLabel = NSLocalizedString("Syllabus", comment: "Syllabus Button Title")
                syllabusButton.accessibilityIdentifier = "syllabus_button"
                syllabusButton.rac_command = RACCommand() { _ in
                    self.route(calendarWeekPageVC, toURL: self.courseSyllabusRoute(studentID: studentID.stringValue, courseID: courseID.stringValue))
                    return RACSignal.empty()
                }
                syllabusButton.tintColor = UIColor.whiteColor()
                calendarWeekPageVC.navigationItem.rightBarButtonItem = syllabusButton
            }

            let navController = UINavigationController.coloredTriangleNavigationController(withRootViewController: calendarWeekPageVC, forObservee: studentID.stringValue)
            navController.navigationBar.tintColor = UIColor.whiteColor()
            navController.navigationBar.accessibilityIdentifier = "navigation_bar"
            return navController
        }
    }

    func assignmentDetailsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, parameters = params, studentID = parameters["studentID"] as? String, courseID = parameters["courseID"] as? NSNumber, assignmentID = parameters["assignmentID"] as? NSNumber else {
                fatalError("You can't show an assignment without having a session, course and assignment id!")
            }

            let assignmentDetailsVC = try! AssignmentDetailsViewController(session: session, studentID: studentID, courseID: courseID.stringValue, assignmentID: assignmentID.stringValue)

            let closeButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: nil, action: nil)
            closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Close Button Title")
            closeButton.accessibilityIdentifier = "close_button"
            closeButton.rac_command = RACCommand() { _ in
                assignmentDetailsVC.dismissViewControllerAnimated(true, completion: nil)
                return RACSignal.empty()
            }
            assignmentDetailsVC.navigationItem.leftBarButtonItem = closeButton
            assignmentDetailsVC.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()

            let navController = UINavigationController.coloredTriangleNavigationController(withRootViewController: assignmentDetailsVC, forObservee: studentID.stringValue)
            return navController
        }
    }

    func standaloneAssignmentDetailsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, parameters = params, studentID = parameters["studentID"] as? String, courseID = parameters["courseID"] as? NSNumber, assignmentID = parameters["assignmentID"] as? NSNumber else {
                fatalError("You can't show an assignment without having a session, course and assignment id!")
            }

            let assignmentDetailsVC = try! AssignmentDetailsViewController(session: session, studentID: studentID, courseID: courseID.stringValue, assignmentID: assignmentID.stringValue)
            return assignmentDetailsVC
        }
    }

    func calendarEventDetailsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, parameters = params, studentID = parameters["studentID"] as? String, calendarEventID = parameters["calendarEventID"] as? NSNumber, courseID = parameters["courseID"] as? NSNumber else {
                fatalError("You can't show a calendar event without having a session and a calendar event id!")
            }

            let calendarEventDetailsVC = try! CalendarEventDetailsViewController(session: session, studentID: studentID, courseID: courseID.stringValue, calendarEventID: calendarEventID.stringValue)

            let closeButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: nil, action: nil)
            closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Close Button Title")
            closeButton.accessibilityIdentifier = "close_button"
            closeButton.rac_command = RACCommand() { _ in
                calendarEventDetailsVC.dismissViewControllerAnimated(true, completion: nil)
                return RACSignal.empty()
            }
            calendarEventDetailsVC.navigationItem.leftBarButtonItem = closeButton
            calendarEventDetailsVC.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()

            let navController = UINavigationController.coloredTriangleNavigationController(withRootViewController: calendarEventDetailsVC, forObservee: studentID.stringValue)
            return navController
        }
    }

    func standaloneCalendarEventDetailsHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, parameters = params, studentID = parameters["studentID"] as? String, calendarEventID = parameters["calendarEventID"] as? NSNumber, courseID = parameters["courseID"] as? NSNumber else {
                fatalError("You can't show a calendar event without having a session and a calendar event id!")
            }

            let calendarEventDetailsVC = try! CalendarEventDetailsViewController(session: session, studentID: studentID, courseID: courseID.stringValue, calendarEventID: calendarEventID.stringValue)
            calendarEventDetailsVC.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()

            return calendarEventDetailsVC
        }
    }

    func courseSyllabusHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, parameters = params, studentID = parameters["studentID"] as? String, courseID = parameters["courseID"] as? NSNumber else {
                fatalError("You can't show a course syllabus without having a session, course id and an student id!")
            }

            let syllabusVC = CourseSyllabusViewController(courseID: courseID.stringValue, studentID: studentID, session: session)
            syllabusVC.navigationItem.title = NSLocalizedString("Syllabus", comment: "")
            return syllabusVC
        }
    }

    func courseAnnouncementHandler() -> RouteHandler {
        return { params in
            guard let session = self.session, parameters = params, studentID = parameters["studentID"] as? String, courseID = parameters["courseID"] as? NSNumber, announcementID = parameters["announcementID"] as? NSNumber else {
                ❨╯°□°❩╯⌢"You can't show a course announcement with having a session, studentID, courseID and an announcementID dude!"
            }

            let announcementVC = try! AnnouncementDetailsViewController(session: session, studentID: studentID, courseID: courseID.stringValue, announcementID: announcementID.stringValue)
            let closeButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: nil, action: nil)
            closeButton.accessibilityLabel = NSLocalizedString("Close", comment: "Close Button Title")
            closeButton.accessibilityIdentifier = "close_button"
            closeButton.rac_command = RACCommand() { _ in
                announcementVC.dismissViewControllerAnimated(true, completion: nil)
                return RACSignal.empty()
            }
            announcementVC.navigationItem.leftBarButtonItem = closeButton
            announcementVC.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()

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
        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else {
            fatalError("How is the App Delegate wrong?")
        }

        return appDelegate
    }
}