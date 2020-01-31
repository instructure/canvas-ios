//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit
import CoreData
import ReactiveSwift
import CanvasCore
import Core

struct DashboardViewState {
    var studentCount = 0
    var isSiteAdmin = false
    var isValidObserver = true
}

class DashboardViewController: UIViewController, CustomNavbarProtocol {
    @IBOutlet weak var viewControlelrContainerView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var coursesTabItem: UITabBarItem!
    @IBOutlet weak var calendarTabItem: UITabBarItem!
    @IBOutlet weak var alertsTabItem: UITabBarItem!
    @IBOutlet weak var contentContainer: UIView!
    var env = AppEnvironment.shared
    var studentCollection: FetchedCollection<Student>!
    var studentSyncProducer: Student.ModelPageSignalProducer!
    var pageViewController: UIPageViewController!
    var context: NSManagedObjectContext!
    var coursesViewController: CourseListViewController?
    var calendarViewController: UIViewController?
    var alertsViewController: UIViewController?
    var viewControllers: [UIViewController]!
    var badgeCount: UInt = 0
    var session: Session!
    var presenter: DashboardPresenter?
    var alertTabBadgeCountCoordinator: AlertCountCoordinator?
    var studentCountObserver: ManagedObjectCountObserver<Student>!
    var adminViewController: AdminViewController!
    var viewState = DashboardViewState()
    var shownNotAParent = false
    var navbarBottomViewContainer: UIView!
    var navbarMenu: UIView!
    var navbarMenuStackView: HorizontalScrollingStackview!
    var navbarNameButton: DynamicButton!
    var navbarAvatar: AvatarView?
    var navbarMenuHeightConstraint: NSLayoutConstraint!
    weak var customNavbarDelegate: CustomNavbarActionDelegate?
    var customNavBarColor: UIColor? {
        if let id = currentStudentID { return ColorScheme.observee(id).color } else { return ColorScheme.observer.color }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var currentStudent: Student? {
        didSet {
            if let student = currentStudent {
                currentStudentID = student.id
                let color = ColorScheme.observee(student.id).color
                alertsTabItem.badgeColor = color
                navbarNameButton.setTitle(student.name, for: .normal)
                navigationItem.leftBarButtonItem?.addBadge(number: badgeCount, color: color)
                navbarAvatar?.name = student.name
                navbarAvatar?.url = student.avatarURL
                tabBar.tintColor = color
                refreshNavbarColor()
            }

            if currentStudent == nil || oldValue?.id != currentStudent?.id {
                self.updateStudentInfoView()
                self.reloadObserveeData()
            }
        }
    }

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    static func create(env: AppEnvironment = .shared, session: Session) -> DashboardViewController {
        let controller = loadFromStoryboard()
        controller.env = env
        controller.session = session
        controller.presenter = DashboardPresenter(view: controller)
        return controller
    }

    // ---------------------------------------------
    // MARK: - Lifecycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        customNavbarDelegate = self
        setupCustomNavbar()
        configurePageViewController()
        addHamburgerButtonToNavbar()

        tabBar.barTintColor = .named(.backgroundLightest)
        view.backgroundColor = .named(.backgroundLightest)
        tabBar.tintColor = ColorScheme.observer.color
        presenter?.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBadge()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            StartupManager.shared.markStartupFinished()
        }
        // doing this in viewDidAppear since there is a chance we might present
        // and in viewDidLoad it was possible for the view to try to present
        // prior to the view being in the hierarchy
        do {
            try self.setup()
        } catch let error as NSError {
            print(error)
        }
    }

    func configurePageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = self
        addChild(pageViewController)
        contentContainer.addSubview(pageViewController.view)
        pageViewController.view.pin(inside: contentContainer)
        pageViewController.didMove(toParent: self)
        hookupRootViewToMenu(contentContainer)
    }

    func addHamburgerButtonToNavbar() {
        let bbi = UIBarButtonItem(image: UIImage.icon(.hamburger, .solid), style: .plain, target: self, action: #selector(drawerDashboardButtonPressed(_:)))
        bbi.tintColor = .white
        navigationItem.leftBarButtonItem = bbi
        bbi.accessibilityIdentifier = "Dashboard.profileButton"

    }

    func setup() throws {
        guard studentCollection == nil else { return }
        viewState.isSiteAdmin = session.isSiteAdmin
        studentCollection = try Student.observedStudentsCollection(session)
        studentCountObserver = try Student.countOfObservedStudentsObserver(session) { [weak self] count in

            // Check to see if all students were all removed during
            // the current user session
            var noMoreLinkedStudents = false
            if count == 0,
                let state = self?.viewState,
                state.studentCount > 0,
                state.isValidObserver {
                noMoreLinkedStudents = true
            }

            self?.viewState.studentCount = count
            self?.configureStudentMenu()

            if (noMoreLinkedStudents) {
                DispatchQueue.main.async {
                    self?.updateMainView()
                }
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
                self?.updateMainView()
                disposable.dispose()
            })
        }
    }

    public func updateMainView() {
        if (!viewState.isValidObserver &&
            !viewState.isSiteAdmin &&
            presenter?.permissions.pending == false &&
            presenter?.permissions.first?.becomeUser != true) {
            if !shownNotAParent {
                showNotAParentView()
                shownNotAParent = true
            }
            return
        }

        setupTabs()

        if (viewState.isSiteAdmin || presenter?.permissions.first?.becomeUser == true) && viewState.studentCount == 0 {
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
        coursesTabItem.accessibilityIdentifier = "TabBar.coursesTab"

        let calendarTitle = NSLocalizedString("Calendar", comment: "Calendar Tab")
        calendarTabItem.title = calendarTitle
        calendarTabItem.image = UIImage.icon(.calendar)
        calendarTabItem.selectedImage = UIImage.icon(.calendar)
        calendarTabItem.accessibilityLabel = String.localizedStringWithFormat(tabViewFormatString, calendarTitle, 2, 3)
        calendarTabItem.accessibilityIdentifier = "TabBar.calendarTab"

        let alertsTitle = NSLocalizedString("Alerts", comment: "Alerts Tab")
        alertsTabItem.title = alertsTitle
        alertsTabItem.image = UIImage.icon(.notification)
        alertsTabItem.selectedImage = UIImage.icon(.notification)
        alertsTabItem.accessibilityLabel = String.localizedStringWithFormat(tabViewFormatString, alertsTitle, 3, 3)
        alertsTabItem.accessibilityIdentifier = "TabBar.alertsTab"
        alertsTabItem.badgeColor = .named(.backgroundInfo)
        alertsTabItem.setBadgeTextAttributes([.foregroundColor: UIColor.named(.white)], for: .normal)

        selectCoursesTab()
    }

    func showSiteAdminViews() {
        navbarNameButton.setTitle(NSLocalizedString("Admin", comment: "Label displayed when logged in as an admin"), for: .normal)
        let storyboard = UIStoryboard(name: "AdminViewController", bundle: nil)
        adminViewController = storyboard.instantiateViewController(withIdentifier: "vc") as? AdminViewController

        adminViewController.actAsUserHandler = { [weak self] in
            self?.presenter?.showActAsUserScreen()
        }

        pageViewController?.setViewControllers([adminViewController], direction: .reverse, animated: false, completion: { _ in })
    }

    func showNotAParentView() {
        presenter?.showWrongAppScreen()
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
        coursesViewController?.refresher?.refresh(false)
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
                self?.alertsTabItem.badgeValue = count > 0 ? NumberFormatter.localizedString(from: NSNumber(value: count), number: .none) : nil
            }
        } else {
            alertTabBadgeCountCoordinator = nil
            alertsTabItem.badgeValue = nil
        }
    }

    func updateBadge() {
        if ExperimentalFeature.parentInbox.isEnabled {
            env.api.makeRequest(GetConversationsUnreadCountRequest()) { [weak self] (response, _, _) in performUIUpdate {
                let unreadCount = UInt(response?.unread_count ?? 0)
                self?.badgeCount = unreadCount
                performUIUpdate {
                    let color = ColorScheme.observee(currentStudentID ?? "0").color
                    self?.navigationItem.leftBarButtonItem?.addBadge(number: unreadCount, color: color)
                }
            } }
        }
    }

    // ---------------------------------------------
    // MARK: - ChildViewControllers
    // ---------------------------------------------
    func initialViewController() -> UIViewController? {
        return coursesViewController
    }

    func coursesViewController(_ session: Session) -> CourseListViewController? {
        guard let currentStudent = currentStudent else {
            return nil
        }

        return try? CourseListViewController(session: session, studentID: currentStudent.id)
    }

    func calendarViewController(_ session: Session, startDate: Date = Date()) -> UIViewController? {
        guard let currentStudent = currentStudent else { return nil }
        return CalendarEventWeekPageViewController.create(session: session, studentID: currentStudent.id, initialReferenceDate: startDate)
    }

    func alertsViewController(_ session: Session) -> UIViewController? {
        guard let currentStudent = currentStudent else { return nil }
        //  swiftlint:disable:next force_try
        return try! AlertsListViewController(session: session, observeeID: currentStudent.id)
    }

    func configureStudentMenu() {
        guard let collection = studentCollection else { return }
        guard collection.numberOfItemsInSection(0) > 0 else { return }
        navbarMenuStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, student) in collection.enumerated() {
            if student.id == (currentStudent?.id ?? "") { continue }
            let item = MenuItem()
            item.button.tag = index
            item.button.addTarget(self, action: #selector(didSelectStudent(sender:)), for: .primaryActionTriggered)
            navbarMenuStackView.addArrangedSubview(item)
            item.addConstraintsWithVFL("H:[view(90)]")
            item.addConstraintsWithVFL("V:[view(90)]")
            item.avatar.url = student.avatarURL
            item.avatar.name = student.name
            item.label.text = student.shortName
        }
        navbarMenuStackView.leftAlignArrangedSubviews()
    }

    @objc func didSelectStudent(sender: UIButton) {
        let index = sender.tag
        showCustomNavbarMenu(false, completion: { [weak self] in
            self?.currentStudent = self?.studentAtIndex(index)
            self?.configureStudentMenu()
        })
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
        var direction = UIPageViewController.NavigationDirection.forward
        if viewController == alertsViewController {
            direction = UIPageViewController.NavigationDirection.reverse
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

    @IBAction func drawerDashboardButtonPressed(_ sender: UIButton) {
        env.router.route(to: .profile, from: self, options: .modal())
    }

    func displayDefaultStudent() {
        currentStudent = studentAtIndex(0)
    }

    func updateStudentInfoView() {
        navbarAvatar?.url = currentStudent?.avatarURL
    }
}

extension DashboardViewController: UITabBarDelegate {
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

extension DashboardViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let viewController = pageViewController.viewControllers?[0]

        if viewController == coursesViewController {
            tabBar.selectedItem = coursesTabItem
        } else if viewController == calendarViewController {
            tabBar.selectedItem = calendarTabItem
        } else if viewController == alertsViewController {
            tabBar.selectedItem = alertsTabItem
        }
    }

}

extension DashboardViewController: CustomNavbarActionDelegate {
    func didClickNavbarNameButton(sender: UIButton) {
        showCustomNavbarMenu(navbarMenuIsHidden)
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}

class MenuItem: UIView {
    var avatar: AvatarView!
    var button: UIButton!
    var label: DynamicLabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonInit() {
        label = DynamicLabel()
        label.font = UIFont.scaledNamedFont(.semibold12)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.textAlignment = .center
        avatar = AvatarView()
        button = UIButton(type: .system)
        addSubview(avatar)
        addSubview(label)
        addSubview(button)

        label.addConstraintsWithVFL("V:[view(21)]")
        label.addConstraintsWithVFL("H:|[view]|")

        let avatarSize: CGFloat = 48.0
        let metrics = ["size": avatarSize]
        avatar.addConstraintsWithVFL("V:|-(16)-[view(size)]-(8)-[label]", views: ["label": label], metrics: metrics)
        avatar.addConstraintsWithVFL("H:[view(size)]", metrics: metrics)
        avatar.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        avatar.layer.cornerRadius = ceil( avatarSize / 2.0 )
        avatar.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        avatar.layer.shadowColor = UIColor(white: 0, alpha: 0.15).cgColor
        avatar.layer.shadowOpacity = 0.2
        avatar.layer.shadowRadius = 8
        avatar.layer.shouldRasterize = true
        avatar.layer.rasterizationScale = UIScreen.main.scale

        button.pin(inside: self)
    }
}
