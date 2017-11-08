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
    
    

import Foundation


import CanvasCore
import CanvasCore


typealias EventWeekPageSelectCalendarEventAction = (_ session: Session, _ observeeID: String, _ calendarEvent: CalendarEvent)->Void

class CalendarEventWeekPageViewController: UIViewController {

    static var headerDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter
    }()

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var nextWeekButton: UIButton!
    @IBOutlet weak var prevWeekButton: UIButton!
    var backgroundView: TriangleBackgroundGradientView?
    var pageViewController: UIPageViewController?

    var session: Session!
    var studentID: String!
    var initialReferenceDate: Date!
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
    fileprivate static let defaultStoryboardName = "CalendarEventWeekPageViewController"
    static func new(_ storyboardName: String = defaultStoryboardName, session: Session, studentID: String, contextCodes: [String] = [], initialReferenceDate: Date = Date()) -> CalendarEventWeekPageViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: Bundle(for: self)).instantiateInitialViewController() as? CalendarEventWeekPageViewController else {
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

        let nextImage = UIImage.RTLImage("icon_forward", renderingMode: .alwaysTemplate)
        let prevImage = UIImage.RTLImage("icon_back", renderingMode: .alwaysTemplate)
        
        nextWeekButton.tintColor = UIAccessibilityIsReduceTransparencyEnabled() ? UIColor.black : UIColor.white
        nextWeekButton.setImage(nextImage, for: .normal)
        nextWeekButton.accessibilityIdentifier = "next_week_button"
        nextWeekButton.accessibilityLabel = NSLocalizedString("Next Week", comment: "Next Week Button Accessibility Label")
        
        prevWeekButton.tintColor = UIAccessibilityIsReduceTransparencyEnabled() ? UIColor.black : UIColor.white
        prevWeekButton.setImage(prevImage, for: .normal)
        prevWeekButton.accessibilityIdentifier = "last_week_button"
        prevWeekButton.accessibilityLabel = NSLocalizedString("Last Week", comment: "Last Week Button Accessibility Label")
        
        updateHeaderTitle()

        if useBackgroundView {
            backgroundView = insertBackgroundView()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed_page_view_controller" {
            guard let pageVC = segue.destination as? UIPageViewController else {
                fatalError("PageViewController is not of type UIPageViewController")
            }

            pageVC.delegate = self
            pageVC.dataSource = self
            pageVC.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)
            let startDate = initialReferenceDate.dateOnSundayAtTheBeginningOfTheWeek
            let endDate = startDate + Calendar.current.numberOfDaysInWeek.daysComponents
            let initialViewController = try! CalendarEventListViewController(session: session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
            initialViewController.selectCalendarEventAction = selectCalendarEventAction
            pageVC.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)

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
        headerLabel.text = "\(formatter.string(from: viewController.startDate)) - \(formatter.string(from: viewController.endDate - 1.secondsComponents))"
        headerLabel.accessibilityIdentifier = "week_header_label"
        headerLabel.accessibilityLabel = String(format: NSLocalizedString("%@ to %@", comment: "Something to Something"), formatter.string(from: viewController.startDate), formatter.string(from: viewController.endDate))
        headerLabel.textColor = UIAccessibilityIsReduceTransparencyEnabled() ? UIColor.black : UIColor.white

    }

    func insertBackgroundView() -> TriangleBackgroundGradientView {
        if let oldBackgroundView = self.backgroundView {
            oldBackgroundView.removeFromSuperview()
        }

        let colorScheme = ColorCoordinator.colorSchemeForStudentID(studentID)
        let backgroundView = TriangleBackgroundGradientView(frame: CGRect.zero, tintTopColor: colorScheme.tintTopColor, tintBottomColor: colorScheme.tintBottomColor)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(backgroundView, at: 0)
        backgroundView.clipsToBounds = true

        var barHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        if let navbarFrame = self.navigationController?.navigationBar.frame {
            barHeight += navbarFrame.height
        }

        let offset = -barHeight

        let horizontalAccountsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics: nil, views: ["subview": backgroundView])
        let verticalAccountsConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-offset-[subview]-0-|", options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics: ["offset": offset], views: ["subview": backgroundView])
        self.view.addConstraints(horizontalAccountsConstraints)
        self.view.addConstraints(verticalAccountsConstraints)
        return backgroundView
    }

    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction func scrollToNextWeek(_ sender: UIButton) {
        guard let pageViewController = pageViewController, let viewController = pageViewController.viewControllers?[0] as? CalendarEventListViewController else {
            fatalError("View Controller in a CalendarEventWeekPageViewController should always be of type CalendarEventListViewController")
        }

        let numDays = Calendar.current.numberOfDaysInWeek
        let startDate = viewController.startDate + numDays.daysComponents
        let initialViewController = eventListController(startDate)
        pageViewController.setViewControllers([initialViewController], direction: .forward, animated: true, completion: { [unowned self] finished in
            if (finished) {
                self.updateHeaderTitle()
            }
        })
    }

    @IBAction func scrollToPrevWeek(_ sender: UIButton) {
        guard let pageViewController = pageViewController, let viewController = pageViewController.viewControllers?[0] as? CalendarEventListViewController else {
            fatalError("View Controller in a CalendarEventWeekPageViewController should always be of type CalendarEventListViewController")
        }

        let numDays = Calendar.current.numberOfDaysInWeek
        let startDate = viewController.startDate - numDays.daysComponents
        let initialViewController = eventListController(startDate)
        pageViewController.setViewControllers([initialViewController], direction: .reverse, animated: true, completion: { [unowned self] finished in
            if finished {
                self.updateHeaderTitle()
            }
        })
    }

    func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    // ---------------------------------------------
    // MARK: - Helper Functions
    // ---------------------------------------------
    func eventListController(_ startDate: Date) -> CalendarEventListViewController {
        let endDate = startDate + Calendar.current.numberOfDaysInWeek.daysComponents

        // Failing on purpose here.  If this is broken it's programmer error
        let eventListViewController = try! CalendarEventListViewController(session: session, studentID: studentID, startDate: startDate, endDate: endDate, contextCodes: contextCodes)
        eventListViewController.selectCalendarEventAction = selectCalendarEventAction
        return eventListViewController
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil, completion: {[unowned self] context in
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
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarEventListViewController else {
            return nil
        }

        let numDays = Calendar.current.numberOfDaysInWeek
        let startDate = viewController.startDate - numDays.daysComponents
        return eventListController(startDate)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? CalendarEventListViewController else {
            return nil
        }

        let numDays = Calendar.current.numberOfDaysInWeek
        let startDate = viewController.startDate + numDays.daysComponents
        return eventListController(startDate)
    }
}

// ---------------------------------------------
// MARK: - UIPageViewControllerDelegate
// ---------------------------------------------
extension CalendarEventWeekPageViewController : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            updateHeaderTitle()
        }
    }
}
