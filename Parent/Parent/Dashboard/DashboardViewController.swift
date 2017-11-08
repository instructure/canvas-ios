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
import CoreData
import ReactiveSwift

import CanvasCore
import CanvasCore


import CanvasCore


typealias DashboardSettingsAction = (_ session: Session)->Void
typealias DashboardSelectCalendarEventAction = (_ session: Session, _ observeeID: String, _ calendarEvent: CalendarEvent)->Void
typealias DashboardSelectCourseAction = (_ session: Session, _ observeeID: String, _ course: Course)->Void
typealias DashboardSelectAlertAction = (_ session: Session, _ observeeID: String, _ alert: Alert)->Void

class DashboardViewController: UIViewController {
    enum TabIndex: Int {
        case courses = 0, calendar, alerts
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

    var logoutAction: (()->Void)? = nil
    var addStudentAction: (()->Void)? = nil

    var currentStudent: Student? {
        didSet {
            if let student = currentStudent {
                if !UIAccessibilityIsReduceTransparencyEnabled() {
                    let colorScheme = ColorCoordinator.colorSchemeForStudentID(student.id)
                    backgroundView.transitionToColors(colorScheme.tintTopColor, tintBottomColor: colorScheme.tintBottomColor)
                }
            }

            observeeNameLabel.text = currentStudent?.name.uppercased() ?? ""

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
    fileprivate static let defaultStoryboardName = "DashboardViewController"
    static func new(_ storyboardName: String = defaultStoryboardName, session: Session) -> DashboardViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: Bundle(for: self)).instantiateInitialViewController() as? DashboardViewController else {
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

        if UIAccessibilityIsReduceTransparencyEnabled() {
            observeeNameLabel.textColor = UIColor.black
        } else {
            self.backgroundView = self.insertTriangleBackgroundView()
            let colorScheme = ColorCoordinator.colorSchemeForParent()
            backgroundView.transitionToColors(colorScheme.tintTopColor, tintBottomColor: colorScheme.tintBottomColor)
        }

        do {
            try setupCarousel()
            setupTabs()
            setupSettingButton()
            try setupNoStudentsViewController()
        } catch let error as NSError {
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embed_page_view_controller" {
            guard let pageViewController = segue.destination as? UIPageViewController else {
                fatalError("PageViewController is not of type UIPageViewController")
            }
            
            self.pageViewController = pageViewController
            self.pageViewController?.delegate = self
            self.pageViewController?.setViewControllers([UIViewController()], direction: .forward, animated: false, completion: nil)
        }
    }
    
    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if UIAccessibilityIsReduceTransparencyEnabled() {
            return .default
        } else {
            return .lightContent
        }
    }

    func setupCarousel() throws {
        observedUserCarousel = try! ObserveesCarouselViewController(session: session)
        observedUserCarousel.studentChanged = { [weak self] student in
            self?.currentStudent = student
        }
        observedUserCarousel.willMove(toParentViewController: self)
        addChildViewController(observedUserCarousel)
        carouselContainerView.addSubview(observedUserCarousel.view)
        observedUserCarousel.didMove(toParentViewController: self)
        carouselContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": observedUserCarousel.view]))
        carouselContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["subview": observedUserCarousel.view]))
    }
    
    func setupTabs() {
        let coursesTap = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.coursesTabPressed(_:)))
        coursesTabView.addGestureRecognizer(coursesTap)
        let coursesTitle = NSLocalizedString("COURSES", comment: "Courses Tab")
        let tabViewFormatString = NSLocalizedString("%@ %d of %d", comment: "<String> <Int> of <Int>")
        coursesTabView.title = coursesTitle
        coursesTabView.normalImage = UIImage(named: "icon_courses")?.withRenderingMode(.alwaysTemplate)
        coursesTabView.selectedImage = UIImage(named: "icon_courses_fill")?.withRenderingMode(.alwaysTemplate)
        coursesTabView.accessibilityLabel = "\(coursesTitle) 1 of 3"
        coursesTabView.accessibilityLabel = String.localizedStringWithFormat(tabViewFormatString, coursesTitle, 1, 3)
        
        let calendarTap = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.calendarTabPressed(_:)))
        calendarTabView.addGestureRecognizer(calendarTap)
        let calendarTitle = NSLocalizedString("WEEK", comment: "Calendar Tab")
        calendarTabView.title = calendarTitle
        calendarTabView.normalImage = UIImage(named: "icon_calendar")?.withRenderingMode(.alwaysTemplate)
        calendarTabView.selectedImage = UIImage(named: "icon_calendar_fill")?.withRenderingMode(.alwaysTemplate)
        calendarTabView.accessibilityLabel = String.localizedStringWithFormat(tabViewFormatString, calendarTitle, 2, 3)
        
        let alertsTap = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.alertsTabPressed(_:)))
        alertsTabView.addGestureRecognizer(alertsTap)
        let alertsTitle = NSLocalizedString("ALERTS", comment: "Alerts Tab")
        alertsTabView.title = alertsTitle
        alertsTabView.normalImage = UIImage(named: "icon_notification")?.withRenderingMode(.alwaysTemplate)
        alertsTabView.selectedImage = UIImage(named: "icon_notification_fill")?.withRenderingMode(.alwaysTemplate)
        alertsTabView.accessibilityLabel = String.localizedStringWithFormat(tabViewFormatString, alertsTitle, 3, 3)
        
        // TODO: Eventually we'll remember what tab the user was on.  Return that viewController here
        tabs = [coursesTabView, calendarTabView, alertsTabView]
        selectTabAtIndex(.courses)
    }
    
    func setupSettingButton() {
        settingsButton.setImage(UIImage(named: "icon_cog")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        settingsButton.setImage(UIImage(named: "icon_cog_fill")?.withRenderingMode(.alwaysTemplate), for: .selected)
        settingsButton.accessibilityLabel = NSLocalizedString("Settings", comment: "Settings Button Title")
        settingsButton.accessibilityIdentifier = "settings_button"
        settingsButton.tintColor = UIAccessibilityIsReduceTransparencyEnabled() ? UIColor.black : UIColor.white
    }

    func setupNoStudentsViewController() throws {
        noStudentsViewController = NoStudentsViewController()
        noStudentsViewController.logoutAction = { [weak self] in self?.logoutAction?() }
        noStudentsViewController.proceedAction = { [weak self] in self?.addStudentAction?() }

        noStudentsViewController.willMove(toParentViewController: self)
        addChildViewController(noStudentsViewController)
        view.addSubview(noStudentsViewController.view)
        noStudentsViewController.didMove(toParentViewController: self)

        noStudentsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[noStudents]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noStudents": noStudentsViewController.view]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[noStudents]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noStudents": noStudentsViewController.view]))

        studentCountObserver = try Student.countOfObservedStudentsObserver(session) { [weak self] count in
            DispatchQueue.main.async {
                self?.noStudentsViewController.view.isHidden = count > 0
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
        
        guard let coursesViewController = coursesViewController, let calendarViewController = calendarViewController, let alertsViewController = alertsViewController else {
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
    
    func coursesViewController(_ session: Session) -> UIViewController? {
        guard let currentStudent = currentStudent else {
            return nil
        }

        let coursesViewController = try! CourseListViewController(session: session, studentID: currentStudent.id)
        coursesViewController.selectCourseAction = { [weak self] in
            self?.selectCourseAction?($0, $1, $2)
        }
        return coursesViewController
    }
    
    func calendarViewController(_ session: Session) -> UIViewController? {
        guard let currentStudent = currentStudent else {
            return nil
        }

        let calendarWeekPageVC = CalendarEventWeekPageViewController.new(session: session, studentID: currentStudent.id)
        calendarWeekPageVC.view.backgroundColor = .clear
        calendarWeekPageVC.selectCalendarEventAction = { [weak self] in
            self?.selectCalendarEventAction?($0, $1, $2)
        }

        return calendarWeekPageVC
    }

    func alertsViewController(_ session: Session) -> UIViewController? {
        guard let currentStudent = currentStudent else { return nil }
        return try! AlertsListViewController(session: session, observeeID: currentStudent.id)
    }
    
    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction func coursesTabPressed(_ sender: UITapGestureRecognizer?) {
        selectTabAtIndex(.courses)
        
        guard let coursesViewController = coursesViewController else {
            return
        }
        
        self.pageViewController?.setViewControllers([coursesViewController], direction: .reverse, animated: true, completion: { _ in })
    }
    
    @IBAction func calendarTabPressed(_ sender: UITapGestureRecognizer?) {
        selectTabAtIndex(.calendar)
        
        guard let calendarViewController = calendarViewController else {
            return
        }
        
        // Because we're in the middle we have to figure out which direction to go
        let viewController = self.pageViewController?.viewControllers?[0]
        var direction = UIPageViewControllerNavigationDirection.forward
        if viewController == alertsViewController {
            direction = UIPageViewControllerNavigationDirection.reverse
        }
        self.pageViewController?.setViewControllers([calendarViewController], direction: direction, animated: true, completion: { _ in })
    }
    
    @IBAction func alertsTabPressed(_ sender: UITapGestureRecognizer?) {
        selectTabAtIndex(.alerts)
        
        guard let alertsViewController = alertsViewController else {
            return
        }
        
        self.pageViewController?.setViewControllers([alertsViewController], direction: .forward, animated: true, completion: { _ in })
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        settingsButtonAction?(self.session)
    }
    
    // ---------------------------------------------
    // MARK: - Tab Selection
    // ---------------------------------------------
    func selectTabAtIndex(_ index: TabIndex) {
        for (i, tab) in tabs.enumerated() {
            tab.setSelected(i == index.rawValue)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        observedUserCarousel.carousel.reloadData()
    }
    
}

extension DashboardViewController : UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let viewController = pageViewController.viewControllers?[0]
        
        if viewController == coursesViewController {
            selectTabAtIndex(.courses)
        }else if viewController == calendarViewController {
            selectTabAtIndex(.calendar)
        }else if viewController == alertsViewController {
            selectTabAtIndex(.alerts)
        }
    }
    
}
