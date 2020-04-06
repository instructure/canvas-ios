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

/// Always uses the nav bar style to update status bar, even if hidden
class DashboardNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? { nil }
}

class DashboardViewController: UIViewController, CustomNavbarProtocol {
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var coursesTabItem: UITabBarItem!
    @IBOutlet weak var calendarTabItem: UITabBarItem!
    @IBOutlet weak var alertsTabItem: UITabBarItem!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var customNavBarContainer: UIView!
    @IBOutlet weak var hamburgerMenuButton: DynamicButton!

    var env = AppEnvironment.shared
    var pageViewController: UIPageViewController!
    var context: NSManagedObjectContext!
    var coursesViewController: CourseListViewController?
    var calendarViewController: PlannerViewController?
    var alertsViewController: UIViewController?
    var viewControllers: [UIViewController]!
    var badgeCount: UInt = 0
    var session: Session!
    var presenter: DashboardPresenter?
    var alertTabBadgeCountCoordinator: AlertCountCoordinator?
    lazy var adminViewController = AdminViewController.create()
    var shownNotAParent = false
    var navbarContentContainer: UIView!
    var navbarActionButton: UIButton!
    var navbarMenu: UIView!
    var navbarMenuStackView: HorizontalScrollingStackview!
    var navbarNameButton: DynamicButton!
    var navbarAvatar: AvatarView?
    var navbarMenuHeightConstraint: NSLayoutConstraint!
    weak var customNavbarDelegate: CustomNavbarActionDelegate?
    var customNavBarColor: UIColor? {
        currentStudentID.flatMap {
            ColorScheme.observee($0).color
        } ?? ColorScheme.observeeBlue.color
    }
    var currentStudent: Core.User? {
        didSet {
            if let student = currentStudent {
                currentStudentID = student.id
                let color = ColorScheme.observee(student.id).color
                env.userDefaults?.parentCurrentStudentID = student.id
                alertsTabItem.badgeColor = color
                let displayName = Core.User.displayName(student.shortName, pronouns: student.pronouns)
                navbarNameButton.setTitle(displayName, for: .normal)
                navbarNameButton.isAccessibilityElement = false
                let template = NSLocalizedString("Current student: %@. Tap to switch students", comment: "")
                navbarActionButton.accessibilityLabel = String.localizedStringWithFormat(template, displayName)
                navbarActionButton.accessibilityTraits.insert(.header)
                updateBadgeCount(color: color)
                navbarAvatar?.name = student.name
                navbarAvatar?.url = student.avatarURL
                navbarAvatar?.imageView.contentMode = .scaleAspectFill
                navbarAvatar?.imageView.tintColor = .named(.textDark)
                navbarAvatar?.label.backgroundColor = .named(.white)
                tabBar.tintColor = color
                view.tintColor = color
                refreshNavbarColor()
            }

            if currentStudent == nil || oldValue?.id != currentStudent?.id {
                navbarAvatar?.url = currentStudent?.avatarURL
                self.reloadObserveeData()
            }
        }
    }
    lazy var students = env.subscribe(GetObservedStudents(observerID: env.currentSession?.userID ??  "")) { [weak self] in
        self?.update()
    }
    lazy var addStudentController = AddStudentController(presentingViewController: self, handler: { [weak self] error in
        if error == nil {
            self?.students.exhaust()
        }
    })

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
        view.backgroundColor = .named(.backgroundLightest)
        customNavbarDelegate = self
        setupCustomNavbar()
        configurePageViewController()
        setupTabBar()

        students.exhaust()
        presenter?.viewIsReady()

        hamburgerMenuButton.accessibilityIdentifier = "Dashboard.profileButton"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(currentStudentID.map {
            ColorScheme.observee($0).color
        })
        navigationController?.setNavigationBarHidden(true, animated: true)
        updateBadge()
        refreshNavbarColor()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            StartupManager.shared.markStartupFinished()
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

    func update() {
        let pending = students.pending || presenter?.permissions.pending == true
        if !pending {
            let isObserver = students.error == nil
            let isAdmin = (session.isSiteAdmin || presenter?.permissions.first?.becomeUser == true) && students.isEmpty
            let showNotAParentModal = (!isObserver && !isAdmin && presenter?.permissions.first?.becomeUser != true)

            if !isAdmin, showNotAParentModal || students.isEmpty {
                if !shownNotAParent {
                    showNotAParentView()
                    shownNotAParent = true
                }
                return
            }

            displayDefaultStudent()
            configureStudentMenu()

            if isAdmin {
                showSiteAdminViews()
            }
        }
    }

    func studentAtIndex(_ index: Int) -> Core.User? {
        guard students.count > 0, index >= 0 else { return nil }
        guard index < students.count else { return nil }
        return students[IndexPath(row: index, section: 0)]
    }

    func setupTabBar() {
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

        tabBar.tintColor = ColorScheme.observer.color
        tabBar.barTintColor = .named(.backgroundLightest)
        tabBar.isTranslucent = false

        selectCoursesTab()
    }

    func showSiteAdminViews() {
        let color = ColorScheme.observeeBlue.color
        alertsTabItem.badgeColor = color
        navbarNameButton.setTitle(NSLocalizedString("Add Student", comment: ""), for: .normal)
        navbarNameButton.isAccessibilityElement = false
        navbarActionButton.accessibilityLabel = NSLocalizedString("Add Student", comment: "")
        navbarActionButton.accessibilityTraits.insert(.header)
        updateBadgeCount(color: color)
        navbarAvatar?.label.isHidden = true
        navbarAvatar?.imageView.image = UIImage.icon(.add, .solid)
            .scaleTo(CGSize(width: 16, height: 16))
            .withRenderingMode(.alwaysTemplate)
        navbarAvatar?.imageView.contentMode = .center
        navbarAvatar?.imageView.tintColor = color
        tabBar.tintColor = color
        view.tintColor = color
        refreshNavbarColor()
        pageViewController?.setViewControllers([adminViewController], direction: .reverse, animated: false)
    }

    func showNotAParentView() {
        presenter?.showWrongAppScreen()
    }

    // ---------------------------------------------
    // MARK: - Data Methods
    // ---------------------------------------------
    func reloadObserveeData() {
        coursesViewController = coursesViewController(session)
        coursesViewController?.refresher?.refresh(false)
        calendarViewController = calendarViewController(
            calendarViewController?.selectedDate ?? Clock.now
        )
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
        env.api.makeRequest(GetConversationsUnreadCountRequest()) { [weak self] (response, _, _) in performUIUpdate {
            let unreadCount = UInt(response?.unread_count ?? 0)
            self?.badgeCount = unreadCount
            performUIUpdate {
                let color = ColorScheme.observee(currentStudentID ?? "0").color
                self?.updateBadgeCount(color: color)
            }
        } }
    }

    func updateBadgeCount(color: UIColor) {
        hamburgerMenuButton.addBadge(number: badgeCount, color: color)
        let accessibilityLabel: String
        if badgeCount > 0 {
            let pluralFormat = NSLocalizedString("conversation_unread_messages", bundle: .core, comment: "")
            let unreadMessages = String.localizedStringWithFormat(pluralFormat, badgeCount)
            accessibilityLabel = String.localizedStringWithFormat( NSLocalizedString("Settings. %@", comment: ""), unreadMessages)
        } else {
            accessibilityLabel = NSLocalizedString("Settings", comment: "")
        }
        hamburgerMenuButton.accessibilityLabel = accessibilityLabel
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

    func calendarViewController(_ selectedDate: Date) -> PlannerViewController? {
        guard let currentStudent = currentStudent else { return nil }
        return PlannerViewController.create(studentID: currentStudent.id, selectedDate: selectedDate)
    }

    func alertsViewController(_ session: Session) -> UIViewController? {
        guard let currentStudent = currentStudent else { return nil }
        //  swiftlint:disable:next force_try
        return try! AlertsListViewController(session: session, observeeID: currentStudent.id)
    }

    func configureStudentMenu() {
        navbarMenuStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        navbarNameButton.setImage(students.isEmpty ? nil : .icon(.dropdown), for: .normal)
        for (index, student) in students.enumerated() {
            let item = MenuItem()
            item.button.tag = index
            let studentName = Core.User.displayName(student.shortName, pronouns: student.pronouns)
            item.button.accessibilityLabel = studentName
            item.button.addTarget(self, action: #selector(didSelectStudent(sender:)), for: .primaryActionTriggered)
            navbarMenuStackView.addArrangedSubview(item)
            item.addConstraintsWithVFL("H:[view(90)]")
            item.addConstraintsWithVFL("V:[view(90)]")
            item.avatar.url = student.avatarURL
            item.avatar.name = student.name
            item.label.text = studentName
            item.label.isAccessibilityElement = false
        }
        addAddStudentButtonToMenu()
    }

    func addAddStudentButtonToMenu() {
        let item = MenuItem()
        let img = UIImage.icon(.add, .solid)
        let iv = UIImageView(image: img)
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .red
        item.insertSubview(iv, belowSubview: item.button)
        iv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 20),
            iv.heightAnchor.constraint(equalToConstant: 20),
            iv.centerXAnchor.constraint(equalTo: item.avatar.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: item.avatar.centerYAnchor),
        ])

        item.label.text = NSLocalizedString("Add Student", comment: "")
        navbarMenuStackView.addArrangedSubview(item)
        item.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            item.widthAnchor.constraint(equalToConstant: 90),
            item.heightAnchor.constraint(equalToConstant: 90),
        ])
        item.button.addTarget(addStudentController, action: #selector(addStudentController.actionAddStudent), for: .primaryActionTriggered)
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
        let viewController = self.pageViewController?.viewControllers?.first
        var direction = UIPageViewController.NavigationDirection.forward
        if viewController == alertsViewController {
            direction = UIPageViewController.NavigationDirection.reverse
        }
        self.pageViewController?.setViewControllers([calendarViewController], direction: direction, animated: false)
    }

    func selectAlertsTab() {
        tabBar.selectedItem = alertsTabItem

        guard let alertsViewController = alertsViewController else {
            return
        }

        self.pageViewController?.setViewControllers([alertsViewController], direction: .forward, animated: false)
    }

    @IBAction func hamburgerMenuPressed(_ sender: Any) {
        env.router.route(to: .profile, from: self, options: .modal())
    }

    func displayDefaultStudent() {
        if let id = env.userDefaults?.parentCurrentStudentID, let persistedStudent = students.filter({ $0.id == id }).first {
            currentStudent = persistedStudent
        } else {
            currentStudent = studentAtIndex(0)
        }
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
        guard !students.isEmpty else {
            return addStudentController.actionAddStudent()
        }
        showCustomNavbarMenu(navbarMenuIsHidden)
    }
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
        avatar.addDropShadow(size: avatarSize)
        button.pin(inside: self)
    }
}
