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

typealias DashboardSettingsAction = (_ session: Session)->Void
typealias DashboardSelectCalendarEventAction = (_ session: Session, _ observeeID: String, _ calendarEvent: CalendarEvent)->Void
typealias DashboardSelectCourseAction = (_ session: Session, _ observeeID: String, _ course: Course)->Void
typealias DashboardSelectAlertAction = (_ session: Session, _ observeeID: String, _ alert: Alert)->Void

let DrawerTransition = DrawerTransitionDelegate()

struct DashboardViewState {
    var studentCount = 0
    var isSiteAdmin = false
    var isValidObserver = true
}

class DashboardViewController: UIViewController {
    var studentCollection: FetchedCollection<Student>!
    var studentSyncProducer: Student.ModelPageSignalProducer!
    
    
    // Views created from storyboard
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var studentInfoContainer: UIView!
    @IBOutlet weak var studentInfoStackView: UIStackView!
    @IBOutlet weak var studentInfoAvatar: UIImageView!
    @IBOutlet weak var studentInfoName: UILabel!
    @IBOutlet weak var studentInfoDownArrow: UIImageView!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var coursesTabItem: UITabBarItem!
    @IBOutlet weak var calendarTabItem: UITabBarItem!
    @IBOutlet weak var alertsTabItem: UITabBarItem!
    
    // Views hooked up
    var pageViewController: UIPageViewController!
    var context: NSManagedObjectContext!
    var coursesViewController: UIViewController?
    var calendarViewController: UIViewController?
    var alertsViewController: UIViewController?
    var viewControllers: [UIViewController]!

    var session: Session!
    
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
                    headerContainerView.backgroundColor = colorScheme.mainColor
                    tabBar.tintColor = colorScheme.mainColor
                    navigationController?.view.backgroundColor = colorScheme.mainColor
                }
            }

            if oldValue?.id != currentStudent?.id {
                self.updateStudentInfoView()
                self.reloadObserveeData()
            }
        }
    }

    var alertTabBadgeCountCoordinator: AlertCountCoordinator?

    var studentCountObserver: ManagedObjectCountObserver<Student>!
    var adminViewController: AdminViewController!
    var viewState = DashboardViewState()
    
    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    fileprivate static let defaultStoryboardName = "DashboardViewController"
    static func new(_ storyboardName: String = defaultStoryboardName, session: Session) -> DashboardViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: Bundle(for: self)).instantiateInitialViewController() as? DashboardViewController else {
            fatalError("Initial ViewController is not of type DashboardViewController")
        }
        controller.session = session
        do {
            try controller.setup()
        } catch let error as NSError {
            print(error)
        }
        
        return controller
    }

    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    override func viewDidLoad() {

        super.viewDidLoad()
        
        // Remove the testing background colors
        studentInfoContainer.backgroundColor = .clear
        studentInfoName.backgroundColor = .clear
        
        studentInfoDownArrow.image = UIImage.icon(.dropdown)
        
        // Decorate the avatar to be circular
        studentInfoAvatar.layer.cornerRadius = studentInfoAvatar.frame.width / 2
        studentInfoAvatar.layer.borderWidth = 1
        studentInfoAvatar.layer.borderColor = UIColor.white.cgColor
        studentInfoAvatar.clipsToBounds = true
        
        // Add the gesture recognizer that will open the action sheet to select a student
        let tap = UITapGestureRecognizer(target: self, action: #selector(studentInfoTapped))
        studentInfoContainer.addGestureRecognizer(tap)
        
        // Set the tab navigation background and the base view to be the same
        // This will make color below the safe area to be the same as the tab nav
        tabBar.barTintColor = UIColor.init(r: 254, g: 254, b: 254)
        view.backgroundColor = tabBar.barTintColor
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let colorScheme = ColorCoordinator.colorSchemeForParent()
            headerContainerView.backgroundColor = colorScheme.mainColor
            tabBar.tintColor = colorScheme.mainColor
        }
        
        self.studentInfoContainer.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            StartupManager.shared.markStartupFinished()
        }
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

    func setup() throws {
        viewState.isSiteAdmin = session.isSiteAdmin
        studentCollection = try Student.observedStudentsCollection(session)
        studentCountObserver = try Student.countOfObservedStudentsObserver(session) { [weak self] count in
            
            // Check to see if all students were all removed during
            // the current user session
            var noMoreLinkedStudents = false
            if count == 0,
               let state = self?.viewState,
               state.studentCount > 0,
               state.isValidObserver
            {
                noMoreLinkedStudents = true
            }
            
            self?.viewState.studentCount = count
            
            if (noMoreLinkedStudents) {
                self?.retrieveStudentsCompleted()
            }
        }
        
        try retrieveStudents()
    }
    
    func retrieveStudents() throws {
        studentSyncProducer = try Student.observedStudentsSyncProducer(session)
        studentSyncProducer.startWithSignal { [weak self] (signal, disposable) in
            signal.observe({ (event) in
                if let error = event.error, error.code == Student.Error.NoObserverEnrollments {
                    self?.viewState.isValidObserver = false
                }
                self?.retrieveStudentsCompleted()
                disposable.dispose()
            })
        }
    }
    
    func retrieveStudentsCompleted() {
        guard viewState.isValidObserver && viewState.studentCount > 0 else {
            return showNotAParentView()
        }
        
        self.studentInfoContainer.isHidden = false
        setupTabs()
        
        if(viewState.isSiteAdmin && viewState.studentCount == 0) {
            showSiteAdminViews()
        }
        
        displayDefaultStudent()
    }
    
    func studentAtIndex(_ index: Int) -> Student? {
        guard index >= 0 else { return nil }
        guard let collection = studentCollection else { return nil }
        guard collection.numberOfItemsInSection(0) > index else { return nil }
        return collection[IndexPath(row: index, section: 0)]
    }
    
    func setupTabs() {
        tabBar.delegate = self
        
        let coursesTitle = NSLocalizedString("Courses", comment: "Courses Tab")
        let tabViewFormatString = NSLocalizedString("%@ %d of %d", comment: "<String> <Int> of <Int>")
        
        coursesTabItem.title = coursesTitle
        coursesTabItem.image = UIImage.icon(.courses)
        coursesTabItem.selectedImage = UIImage.icon(.courses)
        coursesTabItem.accessibilityLabel = String.localizedStringWithFormat(tabViewFormatString, coursesTitle, 1, 3)
        
        let calendarTitle = NSLocalizedString("Week", comment: "Calendar Tab")
        calendarTabItem.title = calendarTitle
        calendarTabItem.image = UIImage.icon(.calendar)
        calendarTabItem.selectedImage = UIImage.icon(.calendar)
        calendarTabItem.accessibilityLabel = String.localizedStringWithFormat(tabViewFormatString, calendarTitle, 2, 3)
        
        let alertsTitle = NSLocalizedString("Alerts", comment: "Alerts Tab")
        alertsTabItem.title = alertsTitle
        alertsTabItem.image = UIImage.icon(.notification)
        alertsTabItem.selectedImage = UIImage.icon(.notification)
        alertsTabItem.accessibilityLabel = String.localizedStringWithFormat(tabViewFormatString, alertsTitle, 3, 3)
        
        selectCoursesTab()
    }
    
    func showSiteAdminViews() {
        studentInfoName.text = NSLocalizedString("Admin", comment: "Label displayed when logged in as an admin")
        studentInfoContainer.accessibilityLabel = studentInfoName.text
        studentInfoAvatar.isHidden = true
        let storyboard = UIStoryboard(name: "AdminViewController", bundle: nil)
        adminViewController = storyboard.instantiateViewController(withIdentifier: "vc") as! AdminViewController
        
        adminViewController.actAsUserHandler = { [weak self] in
            let masquerade = HelmViewController(moduleName: "/masquerade", props: [:])
            self?.present(masquerade, animated: true, completion: nil)
        }
        
        pageViewController?.setViewControllers([adminViewController], direction: .reverse, animated: false, completion: { _ in })
    }
    
    func showNotAParentView() {
        let vc =  HelmViewController( moduleName: "/parent/notAParent", props: [:] )
        showViewController(vc)
    }
    
    //  MARK: - Helpers
    func showViewController(_ viewController: UIViewController) {
        viewController.willMove(toParentViewController: self)
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
        viewController.view.pinToAllSidesOfSuperview()
    }
    
    // ---------------------------------------------
    // MARK: - Data Methods
    // ---------------------------------------------
    func reloadObserveeData() {
        var calendarStartDate: Date = Date()
        if let calendarVC = calendarViewController as? CalendarEventWeekPageViewController, let currentStart = calendarVC.currentStartDate {
            calendarStartDate = currentStart
        }
        
        coursesViewController = coursesViewController(session)
        calendarViewController = calendarViewController(session, startDate: calendarStartDate)
        alertsViewController = alertsViewController(session)

        guard let coursesViewController = coursesViewController, let calendarViewController = calendarViewController, let alertsViewController = alertsViewController else {
            return
        }
        
        viewControllers = [coursesViewController, calendarViewController, alertsViewController]
        
        // MBL-10849: Re-select the same view when switching between students
        if let selected = tabBar.selectedItem {
            if selected == calendarTabItem {
                selectCalendarTab()
            } else if selected == alertsTabItem {
                selectAlertsTab()
            } else {
                selectCoursesTab()
            }
        } else {
            selectCoursesTab()
        }

        if let observeeID = currentStudent?.id {
            alertsTabItem.badgeValue = nil
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [Alert.unreadPredicate(), Alert.undismissedPredicate(), Alert.observeePredicate(observeeID)])
            alertTabBadgeCountCoordinator = AlertCountCoordinator(session: session, studentID: observeeID, predicate: predicate) { [weak self] count in
                self?.alertsTabItem.badgeValue = count > 0 ? "\(count)" : nil
            }
        } else {
            alertTabBadgeCountCoordinator = nil
            alertsTabItem.badgeValue = nil
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
    
    func calendarViewController(_ session: Session, startDate: Date = Date()) -> UIViewController? {
        guard let currentStudent = currentStudent else {
            return nil
        }

        let calendarWeekPageVC = CalendarEventWeekPageViewController.new(session: session, studentID: currentStudent.id, contextCodes: [], initialReferenceDate: startDate)
        calendarWeekPageVC.selectCalendarEventAction = { [weak self] in
            self?.selectCalendarEventAction?($0, $1, $2)
        }

        return calendarWeekPageVC
    }

    func alertsViewController(_ session: Session) -> UIViewController? {
        guard let currentStudent = currentStudent else { return nil }
        return try! AlertsListViewController(session: session, observeeID: currentStudent.id)
    }
    
    func studentInfoTapped(gesture: UITapGestureRecognizer) {
        guard let collection = studentCollection else { return }
        guard collection.numberOfItemsInSection(0) > 0 else { return }
        
        let alertControllerTitle = NSLocalizedString("Choose a student", comment: "")
        let alertController = UIAlertController(title: alertControllerTitle, message: nil, preferredStyle: .actionSheet)
        if let popover = alertController.popoverPresentationController {
            popover.permittedArrowDirections = [.up]
            popover.sourceView = view
            
            // position the alert to be below the student name and in the center of it
            let frame = view.convert(studentInfoName.frame, from: studentInfoStackView)
            popover.sourceRect = CGRect(x: frame.midX, y: frame.maxY + 3, width: 0, height: 0)
        }
        
        collection.forEach { student in
            alertController.addAction(UIAlertAction(title: student.name, style: .default) { [weak self] action in
                self?.currentStudent = student
            })
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }

    func selectCoursesTab() {
        tabBar.selectedItem = coursesTabItem
        
        guard let coursesViewController = coursesViewController else {
            return
        }
        
        self.pageViewController?.setViewControllers([coursesViewController], direction: .reverse, animated: false, completion: { _ in })
    }
    
    func selectCalendarTab() {
        tabBar.selectedItem = calendarTabItem
        
        guard let calendarViewController = calendarViewController else {
            return
        }
        
        // Because we're in the middle we have to figure out which direction to go
        let viewController = self.pageViewController?.viewControllers?[0]
        var direction = UIPageViewControllerNavigationDirection.forward
        if viewController == alertsViewController {
            direction = UIPageViewControllerNavigationDirection.reverse
        }
        self.pageViewController?.setViewControllers([calendarViewController], direction: direction, animated: false, completion: { _ in })
    }
    
    func selectAlertsTab() {
        tabBar.selectedItem = alertsTabItem
        
        guard let alertsViewController = alertsViewController else {
            return
        }
        
        self.pageViewController?.setViewControllers([alertsViewController], direction: .forward, animated: false, completion: { _ in })
    }
    
    @IBAction func drawerDashboardButtonPreseed(_ sender: UIButton) {
        let dashboard = HelmViewController(moduleName: "/profile", props: [:])
        dashboard.modalPresentationStyle = .custom
        dashboard.transitioningDelegate = DrawerTransition
        self.present(dashboard, animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // TODO
        // reload user dropdown?
    }
    
    func displayDefaultStudent() {
        currentStudent = studentAtIndex(0)
    }
    
    func updateStudentInfoView() {
        guard let student = currentStudent else { return }
        
        studentInfoName.text = student.name
        studentInfoContainer.accessibilityLabel = student.name
        studentInfoAvatar.isHidden = false
        
        if let url = student.avatarURL {
            studentInfoAvatar.accessibilityLabel = student.name
            studentInfoAvatar.kf.setImage(with: url,
                                 placeholder: DefaultAvatarCoordinator.defaultAvatarForStudent(student))
        }
    }
}

extension DashboardViewController : UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == calendarTabItem {
            selectCalendarTab()
        } else if item == alertsTabItem {
            selectAlertsTab()
        } else {
            selectCoursesTab()
        }
    }
}

extension DashboardViewController : UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let viewController = pageViewController.viewControllers?[0]
        
        if viewController == coursesViewController {
            tabBar.selectedItem = coursesTabItem
        }else if viewController == calendarViewController {
            tabBar.selectedItem = calendarTabItem
        }else if viewController == alertsViewController {
            tabBar.selectedItem = alertsTabItem
        }
    }
    
}
