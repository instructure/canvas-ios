//
//  ParentDashboardViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 1/7/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

import TooLegit
import Result
import CoreData
import ReactiveCocoa
import SoPersistent
import EnrollmentKit
import CalendarKit
import ObserverAlertKit
import SoPretty
import SoLazy
import Airwolf

typealias DashboardSettingsAction = (session: Session)->Void
typealias DashboardSelectCalendarEventAction = (session: Session, observeeID: String, calendarEvent: CalendarEvent)->Void
typealias DashboardSelectCourseAction = (session: Session, observeeID: String, course: Course)->Void
typealias DashboardSelectAlertAction = (session: Session, observeeID: String, alert: Alert)->Void

class DashboardViewController: UIViewController {
    enum TabIndex: Int {
        case Courses = 0, Calendar, Alerts
    }

    // Views created from storyboard
    @IBOutlet var carouselContainerView: UIView!
    @IBOutlet var observeeNameLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var coursesTabView: DashboardTabView!
    @IBOutlet weak var calendarTabView: DashboardTabView!
    @IBOutlet weak var alertsTabView: DashboardTabView!

    // Views hooked up
    var observedUserCarousel: ObserveesCarouselViewController!
    var pageViewController: UIPageViewController!
    var context: NSManagedObjectContext!
    var coursesViewController: UIViewController?
    var calendarViewController: UIViewController?
    var alertsViewController: UIViewController?
    var tabs: [DashboardTabView]!
    var backgroundView: TriangleBackgroundGradientView!
    var viewControllers: [UIViewController]!

    var session: Session!
    
    var settingsButtonAction: DashboardSettingsAction? = nil
    var selectCourseAction: DashboardSelectCourseAction? = nil
    var selectCalendarEventAction: DashboardSelectCalendarEventAction? = nil
    var selectAlertAction: DashboardSelectAlertAction? = nil

    var logoutAction: ((Void)->Void)? = nil
    var addStudentAction: ((Void)->Void)? = nil

    var currentStudent: Student? {
        didSet {
            if let student = currentStudent {
                let colorScheme = ColorCoordinator.colorSchemeForStudentID(student.id)
                backgroundView.transitionToColors(colorScheme.tintTopColor, tintBottomColor: colorScheme.tintBottomColor)
            }

            observeeNameLabel.text = currentStudent?.name.uppercaseString ?? ""

            if oldValue?.id != currentStudent?.id {
                self.reloadObserveeData()
            }
        }
    }

    var alertTabBadgeCountCoordinator: AlertCountCoordinator?

    var studentCountObserver: ManagedObjectCountObserver<Student>!
    var noStudentsViewController: NoStudentsViewController!
    
    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "DashboardViewController"
    static func new(storyboardName: String = defaultStoryboardName, session: Session) -> DashboardViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: self)).instantiateInitialViewController() as? DashboardViewController else {
            fatalError("Initial ViewController is not of type DashboardViewController")
        }
        controller.session = session
        
        return controller
    }

    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        self.backgroundView = self.insertTriangleBackgroundView()
        let colorScheme = ColorCoordinator.colorSchemeForParent()
        backgroundView.transitionToColors(colorScheme.tintTopColor, tintBottomColor: colorScheme.tintBottomColor)

        do {
            try setupCarousel()
            setupTabs()
            setupSettingButton()
            try setupNoStudentsViewController()
        } catch let error as NSError {
            print(error)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embed_page_view_controller" {
            guard let pageViewController = segue.destinationViewController as? UIPageViewController else {
                fatalError("PageViewController is not of type UIPageViewController")
            }
            
            self.pageViewController = pageViewController
            self.pageViewController?.delegate = self
            self.pageViewController?.setViewControllers([UIViewController()], direction: .Forward, animated: false, completion: nil)
        }
    }
    
    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func setupCarousel() throws {
        observedUserCarousel = try! ObserveesCarouselViewController(session: session)
        observedUserCarousel.studentChanged = { student in
            self.currentStudent = student
        }
        observedUserCarousel.willMoveToParentViewController(self)
        addChildViewController(observedUserCarousel)
        carouselContainerView.addSubview(observedUserCarousel.view)
        observedUserCarousel.didMoveToParentViewController(self)
        carouselContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": observedUserCarousel.view]))
        carouselContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": observedUserCarousel.view]))
    }
    
    func setupTabs() {
        let coursesTap = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.coursesTabPressed(_:)))
        coursesTabView.addGestureRecognizer(coursesTap)
        let coursesTitle = NSLocalizedString("COURSES", comment: "Courses Tab")
        let tabViewFormatString = NSLocalizedString("%@ %d of %d", comment: "<String> <Int> of <Int>")
        coursesTabView.title = coursesTitle
        coursesTabView.normalImage = UIImage(named: "icon_courses")?.imageWithRenderingMode(.AlwaysTemplate)
        coursesTabView.selectedImage = UIImage(named: "icon_courses_fill")?.imageWithRenderingMode(.AlwaysTemplate)
        coursesTabView.accessibilityLabel = "\(coursesTitle) 1 of 3"
        coursesTabView.accessibilityLabel = String.localizedStringWithFormat(tabViewFormatString, coursesTitle, 1, 3)
        
        let calendarTap = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.calendarTabPressed(_:)))
        calendarTabView.addGestureRecognizer(calendarTap)
        let calendarTitle = NSLocalizedString("WEEK", comment: "Calendar Tab")
        calendarTabView.title = calendarTitle
        calendarTabView.normalImage = UIImage(named: "icon_calendar")?.imageWithRenderingMode(.AlwaysTemplate)
        calendarTabView.selectedImage = UIImage(named: "icon_calendar_fill")?.imageWithRenderingMode(.AlwaysTemplate)
        calendarTabView.accessibilityLabel = String.localizedStringWithFormat(tabViewFormatString, calendarTitle, 2, 3)
        
        let alertsTap = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.alertsTabPressed(_:)))
        alertsTabView.addGestureRecognizer(alertsTap)
        let alertsTitle = NSLocalizedString("ALERTS", comment: "Alerts Tab")
        alertsTabView.title = alertsTitle
        alertsTabView.normalImage = UIImage(named: "icon_notification")?.imageWithRenderingMode(.AlwaysTemplate)
        alertsTabView.selectedImage = UIImage(named: "icon_notification_fill")?.imageWithRenderingMode(.AlwaysTemplate)
        alertsTabView.accessibilityLabel = String.localizedStringWithFormat(tabViewFormatString, alertsTitle, 3, 3)
        
        // TODO: Eventually we'll remember what tab the user was on.  Return that viewController here
        tabs = [coursesTabView, calendarTabView, alertsTabView]
        selectTabAtIndex(.Courses)
    }
    
    func setupSettingButton() {
        settingsButton.setImage(UIImage(named: "icon_cog")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        settingsButton.setImage(UIImage(named: "icon_cog_fill")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        settingsButton.accessibilityLabel = NSLocalizedString("Settings", comment: "Settings Button Title")
        settingsButton.accessibilityIdentifier = "settings_button"
        settingsButton.tintColor = UIColor.whiteColor()
    }

    func setupNoStudentsViewController() throws {
        noStudentsViewController = NoStudentsViewController()
        noStudentsViewController.logoutAction = { [weak self] in self?.logoutAction?() }
        noStudentsViewController.proceedAction = { [weak self] in self?.addStudentAction?() }

        noStudentsViewController.willMoveToParentViewController(self)
        addChildViewController(noStudentsViewController)
        view.addSubview(noStudentsViewController.view)
        noStudentsViewController.didMoveToParentViewController(self)

        noStudentsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[noStudents]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noStudents": noStudentsViewController.view]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[noStudents]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noStudents": noStudentsViewController.view]))

        studentCountObserver = try Student.countOfObservedStudentsObserver(session) { [weak self] count in
            dispatch_async(dispatch_get_main_queue()) {
                self?.noStudentsViewController.view.hidden = count > 0
            }
        }
    }
    
    // ---------------------------------------------
    // MARK: - Data Methods
    // ---------------------------------------------
    func reloadObserveeData() {
        coursesViewController = coursesViewController(session)
        calendarViewController = calendarViewController(session)
        alertsViewController = alertsViewController(session)
        
        guard let coursesViewController = coursesViewController, calendarViewController = calendarViewController, alertsViewController = alertsViewController else {
            return
        }
        
        viewControllers = [coursesViewController, calendarViewController, alertsViewController]

        coursesTabPressed(nil)

        if let observeeID = currentStudent?.id {
            alertsTabView.badgeView.badgeValue = 0
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [Alert.unreadPredicate(), Alert.undismissedPredicate(), Alert.observeePredicate(observeeID)])
            alertTabBadgeCountCoordinator = AlertCountCoordinator(session: session, predicate: predicate) { [weak self] count in
                self?.alertsTabView.badgeView.badgeValue = count
            }
        } else {
            alertTabBadgeCountCoordinator = nil
            alertsTabView.badgeView.badgeValue = 0
        }

    }
    
    // ---------------------------------------------
    // MARK: - ChildViewControllers
    // ---------------------------------------------
    func initialViewController() -> UIViewController? {
        return coursesViewController
    }
    
    func coursesViewController(session: Session) -> UIViewController? {
        guard let currentStudent = currentStudent else {
            return nil
        }

        let coursesViewController = try! CourseListViewController(session: session, studentID: currentStudent.id)
        coursesViewController.selectCourseAction = selectCourseAction
        return coursesViewController
    }
    
    func calendarViewController(session: Session) -> UIViewController? {
        guard let currentStudent = currentStudent else {
            return nil
        }

        let calendarWeekPageVC = CalendarEventWeekPageViewController.new(session: session, studentID: currentStudent.id)
        calendarWeekPageVC.view.backgroundColor = UIColor.clearColor()
        calendarWeekPageVC.selectCalendarEventAction = selectCalendarEventAction

        return calendarWeekPageVC
    }

    func alertsViewController(session: Session) -> UIViewController? {
        guard let currentStudent = currentStudent else { return nil }
        return try! AlertsListViewController(session: session, observeeID: currentStudent.id)
    }
    
    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction func coursesTabPressed(sender: UITapGestureRecognizer?) {
        selectTabAtIndex(.Courses)
        
        guard let coursesViewController = coursesViewController else {
            return
        }
        
        self.pageViewController?.setViewControllers([coursesViewController], direction: .Reverse, animated: true, completion: { _ in })
    }
    
    @IBAction func calendarTabPressed(sender: UITapGestureRecognizer?) {
        selectTabAtIndex(.Calendar)
        
        guard let calendarViewController = calendarViewController else {
            return
        }
        
        // Because we're in the middle we have to figure out which direction to go
        let viewController = self.pageViewController?.viewControllers?[0]
        var direction = UIPageViewControllerNavigationDirection.Forward
        if viewController == alertsViewController {
            direction = UIPageViewControllerNavigationDirection.Reverse
        }
        self.pageViewController?.setViewControllers([calendarViewController], direction: direction, animated: true, completion: { _ in })
    }
    
    @IBAction func alertsTabPressed(sender: UITapGestureRecognizer?) {
        selectTabAtIndex(.Alerts)
        
        guard let alertsViewController = alertsViewController else {
            return
        }
        
        self.pageViewController?.setViewControllers([alertsViewController], direction: .Forward, animated: true, completion: { _ in })
    }
    
    @IBAction func settingsButtonPressed(sender: UIButton) {
        settingsButtonAction?(session: self.session)
    }
    
    // ---------------------------------------------
    // MARK: - Tab Selection
    // ---------------------------------------------
    func selectTabAtIndex(index: TabIndex) {
        for (i, tab) in tabs.enumerate() {
            tab.setSelected(i == index.rawValue)
        }
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        observedUserCarousel.carousel.reloadData()
    }
    
}

extension DashboardViewController : UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let viewController = pageViewController.viewControllers?[0]
        
        if viewController == coursesViewController {
            selectTabAtIndex(.Courses)
        }else if viewController == calendarViewController {
            selectTabAtIndex(.Calendar)
        }else if viewController == alertsViewController {
            selectTabAtIndex(.Alerts)
        }
    }
    
}
