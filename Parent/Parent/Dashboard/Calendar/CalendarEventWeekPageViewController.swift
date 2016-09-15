//
//  CalendarEventWeekPageViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 3/14/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation

import TooLegit
import SoLazy
import CalendarKit
import SoPretty

typealias EventWeekPageSelectCalendarEventAction = (session: Session, observeeID: String, calendarEvent: CalendarEvent)->Void

class CalendarEventWeekPageViewController: UIViewController {

    static var headerDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter
    }()

    static var numberOfDaysInWeek: Int = {
        return NSCalendar.currentCalendar().maximumRangeOfUnit(.Weekday).length
    }()

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var nextWeekButton: UIButton!
    @IBOutlet weak var prevWeekButton: UIButton!
    var backgroundView: TriangleBackgroundGradientView?
    var pageViewController: UIPageViewController?

    var session: Session!
    var studentID: String!
    var initialReferenceDate: NSDate!
    var contextCodes: [String]!
    var useBackgroundView = false

    var selectCalendarEventAction: EventWeekPageSelectCalendarEventAction? = nil {
        didSet {
            guard let viewControllers = pageViewController?.viewControllers else {
                return
            }

            for viewController in viewControllers {
                if let viewController = viewController as? CalendarEventListViewController {
                    viewController.selectCalendarEventAction = self.selectCalendarEventAction
                }
            }
        }
    }

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "CalendarEventWeekPageViewController"
    static func new(storyboardName: String = defaultStoryboardName, session: Session, studentID: String, contextCodes: [String] = [], initialReferenceDate: NSDate = NSDate()) -> CalendarEventWeekPageViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: self)).instantiateInitialViewController() as? CalendarEventWeekPageViewController else {
            fatalError("Initial ViewController is not of type CalendarEventWeekPageViewController")
        }
        
        controller.session = session
        controller.studentID = studentID
        controller.initialReferenceDate = initialReferenceDate.dateOnSundayAtTheBeginningOfTheWeek
        controller.contextCodes = contextCodes
        
        return controller
    }

    // ---------------------------------------------
    // MARK: - ViewController Lifecycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()

        nextWeekButton.tintColor = UIColor.whiteColor()
        nextWeekButton.setImage(UIImage(named: "icon_forward")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        nextWeekButton.accessibilityIdentifier = "next_week_button"
        nextWeekButton.accessibilityLabel = NSLocalizedString("Next Week", comment: "Next Week Button Accessibility Label")

        prevWeekButton.tintColor = UIColor.whiteColor()
        prevWeekButton.setImage(UIImage(named: "icon_back")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        prevWeekButton.accessibilityIdentifier = "last_week_button"
        prevWeekButton.accessibilityLabel = NSLocalizedString("Last Week", comment: "Last Week Button Accessibility Label")

        updateHeaderTitle()

        if useBackgroundView {
            backgroundView = insertTriangleBackgroundView()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embed_page_view_controller" {
            guard let pageVC = segue.destinationViewController as? UIPageViewController else {
                fatalError("PageViewController is not of type UIPageViewController")
            }

            pageVC.delegate = self
            pageVC.dataSource = self
            pageVC.setViewControllers([UIViewController()], direction: .Forward, animated: false, completion: nil)
            let startDate = initialReferenceDate.dateOnSundayAtTheBeginningOfTheWeek
            let endDate = startDate + CalendarEventWeekPageViewController.numberOfDaysInWeek.daysComponents
            let initialViewController = try! CalendarEventListViewController(session: session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
            initialViewController.selectCalendarEventAction = selectCalendarEventAction
            pageVC.setViewControllers([initialViewController], direction: .Forward, animated: false, completion: nil)

            pageViewController = pageVC
        }
    }

    // ---------------------------------------------
    // MARK: - Update View
    // ---------------------------------------------
    func updateHeaderTitle() {
        guard let viewController = pageViewController?.viewControllers?[0] as? CalendarEventListViewController else {
            fatalError("View Controller in a CalendarEventWeekPageViewController should always be of type CalendarEventListViewController")
        }

        let formatter = CalendarEventWeekPageViewController.headerDateFormatter
        headerLabel.text = "\(formatter.stringFromDate(viewController.startDate)) - \(formatter.stringFromDate(viewController.endDate - 1.secondsComponents))"
        headerLabel.accessibilityIdentifier = "week_header_label"
        headerLabel.accessibilityLabel = String(format: NSLocalizedString("%@ to %@", comment: "Something to Something"), formatter.stringFromDate(viewController.startDate), formatter.stringFromDate(viewController.endDate))


    }

    override func insertTriangleBackgroundView() -> TriangleBackgroundGradientView {
        if let oldBackgroundView = self.backgroundView {
            oldBackgroundView.removeFromSuperview()
        }

        let colorScheme = ColorCoordinator.colorSchemeForStudentID(studentID)
        let backgroundView = TriangleBackgroundGradientView(frame: CGRectZero, tintTopColor: colorScheme.tintTopColor, tintBottomColor: colorScheme.tintBottomColor)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(backgroundView, atIndex: 0)
        backgroundView.clipsToBounds = true

        var barHeight: CGFloat = CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
        if let navbarFrame = self.navigationController?.navigationBar.frame {
            barHeight += CGRectGetHeight(navbarFrame)
        }

        let offset = -barHeight

        let horizontalAccountsConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["subview": backgroundView])
        let verticalAccountsConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-offset-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: ["offset": offset], views: ["subview": backgroundView])
        self.view.addConstraints(horizontalAccountsConstraints)
        self.view.addConstraints(verticalAccountsConstraints)
        return backgroundView
    }

    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction func scrollToNextWeek(sender: UIButton) {
        guard let pageViewController = pageViewController, viewController = pageViewController.viewControllers?[0] as? CalendarEventListViewController else {
            fatalError("View Controller in a CalendarEventWeekPageViewController should always be of type CalendarEventListViewController")
        }

        let numDays = CalendarEventWeekPageViewController.numberOfDaysInWeek
        let startDate = viewController.startDate + numDays.daysComponents
        let initialViewController = eventListController(startDate)
        pageViewController.setViewControllers([initialViewController], direction: .Forward, animated: true, completion: { [unowned self] finished in
            if (finished) {
                self.updateHeaderTitle()
            }
        })
    }

    @IBAction func scrollToPrevWeek(sender: UIButton) {
        guard let pageViewController = pageViewController, viewController = pageViewController.viewControllers?[0] as? CalendarEventListViewController else {
            fatalError("View Controller in a CalendarEventWeekPageViewController should always be of type CalendarEventListViewController")
        }

        let numDays = CalendarEventWeekPageViewController.numberOfDaysInWeek
        let startDate = viewController.startDate - numDays.daysComponents
        let initialViewController = eventListController(startDate)
        pageViewController.setViewControllers([initialViewController], direction: .Reverse, animated: true, completion: { [unowned self] finished in
            if finished {
                self.updateHeaderTitle()
            }
        })
    }

    func close(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // ---------------------------------------------
    // MARK: - Helper Functions
    // ---------------------------------------------
    func eventListController(startDate: NSDate) -> CalendarEventListViewController {
        let endDate = startDate + CalendarEventWeekPageViewController.numberOfDaysInWeek.daysComponents

        // Failing on purpose here.  If this is broken it's programmer error
        let eventListViewController = try! CalendarEventListViewController(session: session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        eventListViewController.selectCalendarEventAction = selectCalendarEventAction
        return eventListViewController
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        coordinator.animateAlongsideTransition(nil, completion: {[unowned self] context in
            if self.useBackgroundView {
                self.backgroundView = self.insertTriangleBackgroundView()
            }
        })
    }
}

// ---------------------------------------------
// MARK: - UIPageViewControllerDataSource
// ---------------------------------------------
extension CalendarEventWeekPageViewController : UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarEventListViewController else {
            return nil
        }

        let numDays = CalendarEventWeekPageViewController.numberOfDaysInWeek
        let startDate = viewController.startDate - numDays.daysComponents
        return eventListController(startDate)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarEventListViewController else {
            return nil
        }

        let numDays = CalendarEventWeekPageViewController.numberOfDaysInWeek
        let startDate = viewController.startDate + numDays.daysComponents
        return eventListController(startDate)
    }
}

// ---------------------------------------------
// MARK: - UIPageViewControllerDelegate
// ---------------------------------------------
extension CalendarEventWeekPageViewController : UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            updateHeaderTitle()
        }
    }
}
