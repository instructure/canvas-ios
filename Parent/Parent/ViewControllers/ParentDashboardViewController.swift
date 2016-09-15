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

typealias DashboardSettingsAction = (session: Session)->Void

class ParentDashboardViewController: UIViewController {
    
    @IBOutlet var carouselContainerView: UIView!
    @IBOutlet var observeeNameLabel: UILabel!
    
    @IBOutlet weak var coursesTabView: DashboardTabView!
    @IBOutlet weak var calendarTabView: DashboardTabView!
    @IBOutlet weak var alertsTabView: DashboardTabView!
    var tabs: [DashboardTabView]!
    enum TabIndex: Int {
        case Courses = 0, Calendar, Alerts
    }
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var pageViewController: UIPageViewController!
    @IBOutlet weak var gradientView: CanvasBackgroundGradientView!
    var viewControllers: [UIViewController]!
    var session: Session!
    
    var coursesViewController: UIViewController?
    var calendarViewController: UIViewController?
    var alertsViewController: UIViewController?
    
    var settingsButtonAction: DashboardSettingsAction? = nil
    var currentUser: User? {
        didSet {
            if let user = currentUser {
                if oldValue?.id == user.id {
                    return
                }
                
                let colorScheme = UserColorCoordinator.colorSchemeForUser(user)
                gradientView.transitionToColors(colorScheme.topBackgroundTintColor, tintBottomColor: colorScheme.bottomBackgroundTintColor)

                observeeNameLabel.text = user.name.uppercaseString
                
                self.reloadObserveeData()
            }
        }
    }
    
    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "ParentDashboardViewController"
    static func new(storyboardName: String = defaultStoryboardName, session: Session) -> ParentDashboardViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: self)).instantiateInitialViewController() as? ParentDashboardViewController else {
            fatalError("Initial ViewController is not of type ParentDashboardViewController")
        }
        controller.session = session
        
        return controller
    }

    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCarousel()
        setupTabs()
        setupSettingButton()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embed_page_view_controller" {
            guard let pageViewController = segue.destinationViewController as? UIPageViewController else {
                fatalError("PageViewController is not of type UIPageViewController")
            }
            
            self.pageViewController = pageViewController
            self.pageViewController?.delegate = self
//            self.pageViewController?.dataSource = self
            self.pageViewController?.setViewControllers([UIViewController()], direction: .Forward, animated: false, completion: { completed in
            })
            
        }
    }
    
    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func setupCarousel() {
        let context = try! User.context(session)
        let frc = User.fetchedResults(nil, sortDescriptors: ["name".ascending], sectionNameKeypath: nil, inContext: context)
        let collection: UserFetchedCollection = try! FetchedCollection(frc: frc, viewModelFactory: { $0 } )
        
        let remote = try! User.getObserveeUsers(session)
        let fetchRequest = User.fetch(nil, sortDescriptors: ["name".ascending], inContext: context)
        let sync = User.syncSignalProducer(fetchRequest, inContext: context, fetchRemote: remote)
        
        let observedUserCarousel = ObservedUsersCarouselViewController(collection: collection, syncProducer: sync)
        observedUserCarousel.userChanged = { user in
            self.currentUser = user
        }
        observedUserCarousel.willMoveToParentViewController(self)
        addChildViewController(observedUserCarousel)
        carouselContainerView.addSubview(observedUserCarousel.view)
        observedUserCarousel.didMoveToParentViewController(self)
        carouselContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": observedUserCarousel.view]))
        carouselContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": observedUserCarousel.view]))
    }
    
    func setupTabs() {
        let coursesTap = UITapGestureRecognizer(target: self, action: "coursesTabPressed:")
        coursesTabView.addGestureRecognizer(coursesTap)
        coursesTabView.title = NSLocalizedString("COURSES", comment: "Courses Tab")
        alertsTabView.accessibilityLabel = NSLocalizedString("Courses Tab Title", value: "View Courses", comment: "Courses Tab Title")
        alertsTabView.accessibilityIdentifier = "View Calendar Tab"
        coursesTabView.normalImage = UIImage(named: "icon_courses")?.imageWithRenderingMode(.AlwaysTemplate)
        coursesTabView.selectedImage = UIImage(named: "icon_courses_fill")?.imageWithRenderingMode(.AlwaysTemplate)
        
        let calendarTap = UITapGestureRecognizer(target: self, action: "calendarTabPressed:")
        calendarTabView.addGestureRecognizer(calendarTap)
        calendarTabView.title = NSLocalizedString("CALENDAR", comment: "Calendar Tab")
        alertsTabView.accessibilityLabel = NSLocalizedString("Calendar Tab Title", value: "View Calendar", comment: "Calendar Tab Title")
        alertsTabView.accessibilityIdentifier = "View Calendar Tab"
        calendarTabView.normalImage = UIImage(named: "icon_calendar")?.imageWithRenderingMode(.AlwaysTemplate)
        calendarTabView.selectedImage = UIImage(named: "icon_calendar_fill")?.imageWithRenderingMode(.AlwaysTemplate)
        
        let alertsTap = UITapGestureRecognizer(target: self, action: "alertsTabPressed:")
        alertsTabView.addGestureRecognizer(alertsTap)
        alertsTabView.title = NSLocalizedString("ALERTS", comment: "Alerts Tab")
        alertsTabView.accessibilityLabel = NSLocalizedString("Alerts Tab Title", value: "View Alerts", comment: "Alerts Tab Title")
        alertsTabView.accessibilityIdentifier = "View Alerts Tab"
        alertsTabView.normalImage = UIImage(named: "icon_notification")?.imageWithRenderingMode(.AlwaysTemplate)
        alertsTabView.selectedImage = UIImage(named: "icon_notification_fill")?.imageWithRenderingMode(.AlwaysTemplate)
        
        // TODO: Eventually we'll remember what tab the user was on.  Return that viewController here
        tabs = [coursesTabView, calendarTabView, alertsTabView]
        selectTabAtIndex(.Courses)
    }
    
    func setupSettingButton() {
        settingsButton.setImage(UIImage(named: "icon_cog")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        settingsButton.setImage(UIImage(named: "icon_cog_fil")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Selected)
        settingsButton.accessibilityLabel = NSLocalizedString("Domain Picker Search Placeholder", value: "Find your school or district", comment: "Domain Picker Search Placeholder")
        settingsButton.accessibilityIdentifier = "DomainSearchTextField"
        settingsButton.tintColor = UIColor.whiteColor()
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
        
        // TODO: Eventually we'll remember what tab the user was on.
        coursesTabPressed(nil)
    }
    
    // ---------------------------------------------
    // MARK: - ChildViewControllers
    // ---------------------------------------------
    func initialViewController() -> UIViewController? {
        // TODO: Eventually we'll remember what tab the user was on.  Return that viewController here
        return coursesViewController
    }
    
    func coursesViewController(session: Session) -> UIViewController? {
        guard let currentUser = currentUser else {
            return nil
        }
        
        return try! observedUserCoursesViewController(session, viewModelFactory: { ObserveeCourseCellViewModel(courseObject: $0) }, observeeID: "\(currentUser.id)");
    }
    
    func calendarViewController(session: Session) -> UIViewController? {
        guard let currentUser = currentUser else {
            return nil
        }
        
        let calendar = NSCalendar.currentCalendar()
        let startDateComponents = NSDateComponents()
        startDateComponents.calendar = calendar
        startDateComponents.day = 1
        startDateComponents.month = 1
        startDateComponents.year = 2015
        
        let endDateComponents = NSDateComponents()
        endDateComponents.calendar = calendar
        endDateComponents.day = 31
        endDateComponents.month = 12
        endDateComponents.year = 2015
        
        let startDate = calendar.dateFromComponents(startDateComponents) ?? NSDate()
        let endDate = calendar.dateFromComponents(endDateComponents) ?? NSDate()
        
        return try! observedUserCalendarEventsViewController(session, viewModelFactory: { CalendarEventCellViewModel(calendarObject: $0) }, observeeID: "\(currentUser.id)", startDate: startDate, endDate: endDate, contextCodes: ["course_1"])
    }

    func alertsViewController(session: Session) -> UIViewController? {
        guard let currentUser = currentUser else { return nil }
        return try? observedUserAlertsViewController(session, viewModelFactory: { ObserveeAlertCellViewModel(alertObject: $0) }, observeeID: currentUser.id)
    }
    
    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction func coursesTabPressed(sender: UITapGestureRecognizer?) {
        selectTabAtIndex(.Courses)
        
        guard let coursesViewController = coursesViewController else {
            return
        }
        
        self.pageViewController?.setViewControllers([coursesViewController], direction: .Reverse, animated: true, completion: { completed in
//            print(completed)
        })
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
        self.pageViewController?.setViewControllers([calendarViewController], direction: direction, animated: true, completion: { completed in
            
        })
    }
    
    @IBAction func alertsTabPressed(sender: UITapGestureRecognizer?) {
        selectTabAtIndex(.Alerts)
        
        guard let alertsViewController = alertsViewController else {
            return
        }
        
        self.pageViewController?.setViewControllers([alertsViewController], direction: .Forward, animated: true, completion: { completed in
//            print(completed)
        })
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
    
}

extension ParentDashboardViewController : UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.indexOf(viewController) else {
            return nil
        }
        
        if index <= 0 {
            return nil
        } else {
            return viewControllers[index - 1]
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.indexOf(viewController) else {
            return nil
        }
        
        if index >= (viewControllers.count - 1) {
            return nil
        } else {
            return viewControllers[index + 1]
        }
    }
    
}

extension ParentDashboardViewController : UIPageViewControllerDelegate {
    
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
