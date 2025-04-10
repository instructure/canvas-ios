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
import Core
import Combine

class DashboardViewController: ScreenViewTrackableViewController, ErrorViewController {
    @IBOutlet weak var studentListStack: UIStackView!
    @IBOutlet weak var studentListView: UIView!
    lazy var studentListHiddenHeight = studentListView.heightAnchor.constraint(equalToConstant: 0)
    @IBOutlet weak var tabsContainer: UIView!
    let tabsController = UITabBarController()

    var badgeCount: UInt = 0 {
        didSet { headerViewModel.didUpdateBadgeCount.send(Int(badgeCount)) }
    }
    var currentColor: UIColor {
        currentStudentID.flatMap {
            ColorScheme.observee($0).color
        } ?? ColorScheme.observeeBlue.color
    }
    var currentStudent: Core.User? {
        didSet { updateCurrentStudent(oldValue) }
    }
    let env = AppEnvironment.shared
    var hasStudents: Bool?
    var shownNotAParent = false
    let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/")
    let headerViewModel = StudentHeaderViewModel()
    var subscriptions = Set<AnyCancellable>()

    lazy var addStudentController = AddStudentController(presentingViewController: self, handler: { [weak self] error in
        if error == nil {
            self?.students.exhaust()
        }
    })
    lazy var permissions = env.subscribe(GetContextPermissions(context: .account("self"), permissions: [.becomeUser])) { [weak self] in
        self?.update()
    }
    lazy var students = env.subscribe(GetObservedStudents(observerID: env.currentSession?.userID ??  "")) { [weak self] in
        self?.update()
    }

    static func create() -> DashboardViewController {
        return loadFromStoryboard()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        embedHeaderView()
        studentListHiddenHeight.isActive = true

        tabsController.tabBar.useGlobalNavStyle()
        tabsController.delegate = self
        embed(tabsController, in: tabsContainer)

        permissions.refresh(force: true)
        students.exhaust { [weak self] list in
            // workaround temporary students.isEmpty && !students.pending
            self?.hasStudents = self?.hasStudents == true || !(list?.isEmpty ?? true)
            self?.update()
            return true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(checkForPolicyChanges), name: UIApplication.didBecomeActiveNotification, object: nil)
        reportScreenView(for: 0, viewController: self)
        if env.userDefaults?.interfaceStyle == nil {
            env.userDefaults?.interfaceStyle = .light
        }
        registerForTraitChanges()
    }

    /// When the app was started in light mode and turned to dark the selected color was not updated so we do a force refresh.
    private func registerForTraitChanges() {
        let traits = [UITraitUserInterfaceStyle.self]
        registerForTraitChanges(traits) { (controller: DashboardViewController, _) in
            controller.tabsController.tabBar.useGlobalNavStyle()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(currentColor)
        navigationController?.setNavigationBarHidden(true, animated: true)
        updateBadge()
        checkForPolicyChanges()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @IBAction func showProfile() {
        env.router.route(to: "/profile", from: self, options: .modal())
    }

    func update() {
        guard students.requested, !students.pending, permissions.requested, !permissions.pending else { return }

        currentStudent = students.first {
            $0.id == env.userDefaults?.parentCurrentStudentID
        } ?? students.first
        updateStudentList()

        let isAdmin = (
            permissions.first?.becomeUser == true ||
            env.currentSession?.baseURL.host?.hasPrefix("siteadmin.") == true
        )
        if students.error != nil || hasStudents == false, !isAdmin, !shownNotAParent {
            shownNotAParent = true
            env.router.route(to: "/wrong-app", from: self, options: .modal(isDismissable: false, embedInNav: true))
        }
    }

    func updateBadge() {
        env.api.makeRequest(GetConversationsUnreadCountRequest()) { [weak self] (response, _, _) in
            self?.badgeCount = UInt(response?.unread_count ?? 0)
        }
    }

    func updateCurrentStudent(_ oldValue: Core.User?) {
        guard currentStudent == nil || currentStudent?.id != oldValue?.id else { return }

        currentStudentID = currentStudent?.id
        env.userDefaults?.parentCurrentStudentID = currentStudentID

        view.tintColor = currentColor
        headerViewModel.didSelectStudent.send(currentStudent)
        updateTabs()
    }

    func updateStudentList() {
        studentListStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, student) in students.enumerated() {
            let button = StudentButton(student: student)
            button.tag = index
            button.addTarget(self, action: #selector(didSelectStudent(sender:)), for: .primaryActionTriggered)
            studentListStack.addArrangedSubview(button)
        }
        let addButton = AddStudentButton()
        addButton.addTarget(addStudentController, action: #selector(AddStudentController.addStudent), for: .primaryActionTriggered)
        studentListStack.addArrangedSubview(addButton)
    }

    func didTapDropdownButton() {
        guard !students.isEmpty else { return addStudentController.addStudent() }
        toggleStudentList(studentListHiddenHeight.isActive)
    }

    @objc func didSelectStudent(sender: UIButton) {
        guard sender.tag >= 0, let student = students[sender.tag] else { return }
        headerViewModel.didSelectStudent.send(student)
        toggleStudentList(false, completion: { [weak self] in
            self?.currentStudent = student
        })
    }

    func toggleStudentList(_ show: Bool = true, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.studentListHiddenHeight.isActive = !show
            self.view.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }

    func updateTabs() {
        let courses = currentStudentID.flatMap {
            CourseListViewController.create(studentID: $0)
        } ?? AdminViewController.create()
        courses.tabBarItem.title = String(localized: "Courses", bundle: .parent, comment: "Courses Tab")
        courses.tabBarItem.image = .coursesTab
        courses.tabBarItem.selectedImage = .coursesTabActive
        courses.tabBarItem.accessibilityIdentifier = "TabBar.coursesTab"

        var selectedDate = Clock.now
        if let tabs = tabsController.viewControllers, tabs.count >= 2, let prevCal = tabs[1] as? PlannerViewController {
            selectedDate = prevCal.selectedDate
        }
        let calendar = currentStudentID.flatMap {
            PlannerViewController.create(studentID: $0, selectedDate: selectedDate)
        } ?? AdminViewController.create()
        calendar.tabBarItem.title = String(localized: "Calendar", bundle: .parent, comment: "Calendar Tab")
        calendar.tabBarItem.image = .calendarTab
        calendar.tabBarItem.selectedImage = .calendarTabActive
        calendar.tabBarItem.accessibilityIdentifier = "TabBar.calendarTab"

        let alerts = currentStudentID.flatMap {
            ObserverAlertListViewController.create(studentID: $0)
        } ?? AdminViewController.create()
        alerts.tabBarItem.title = String(localized: "Alerts", bundle: .parent, comment: "Alerts Tab")
        alerts.tabBarItem.image = .alertsTab
        alerts.tabBarItem.selectedImage = .alertsTabActive
        alerts.tabBarItem.accessibilityIdentifier = "TabBar.alertsTab"
        alerts.tabBarItem.badgeColor = currentColor
        alerts.tabBarItem.setBadgeTextAttributes([ .foregroundColor: UIColor.textLightest.variantForLightMode ], for: .normal)
        alerts.loadViewIfNeeded() // Make sure it starts loading data for badge

        tabsController.viewControllers = [ courses, calendar, alerts ]
    }

    private func reportScreenView(for tabIndex: Int, viewController: UIViewController) {
        let map = ["courses", "calendar", "alerts"]
        let event = map[tabIndex]
        RemoteLogger.shared.logBreadcrumb(route: "/tabs/" + event, viewController: viewController)
    }

    @objc private func checkForPolicyChanges() {
        LoginUsePolicy.checkAcceptablePolicy(from: self, cancelled: {
            AppEnvironment.shared.loginDelegate?.changeUser()
        })
    }

    private func embedHeaderView() {
        let headerViewController = CoreHostingController(StudentHeaderView(viewModel: headerViewModel))
        embed(headerViewController, in: view) { [studentListView] header, superview in
            let headerView = header.view!
            headerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headerView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0),
                headerView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0),
                headerView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0),
                headerView.bottomAnchor.constraint(equalTo: studentListView!.topAnchor, constant: 0)
            ])
        }
        headerViewModel
            .didTapStudentView
            .sink { [weak self] in
                self?.didTapDropdownButton()
            }
            .store(in: &subscriptions)
    }
}

extension DashboardViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController), tabBarController.selectedViewController != viewController {
            reportScreenView(for: index, viewController: viewController)
        }

        return true
    }

    func tabBarController(
        _ tabBarController: UITabBarController,
        animationControllerForTransitionFrom fromVC: UIViewController,
        to toVC: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {
        InstUI.TabChangeTransition()
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        headerViewModel.focusStudentPicker.send()
    }
}

class StudentButton: UIButton {
    let avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))

    convenience init(student: Core.User) {
        self.init(type: .system)
        accessibilityIdentifier = "StudentButton.\(student.id)"

        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 16 + 48 + 8, leading: 0, bottom: 16, trailing: 0)
        config.titleLineBreakMode = .byTruncatingTail
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outcoming = incoming
            outcoming.font = UIFont.scaledNamedFont(.semibold12)
            return outcoming
        }
        configuration = config

        setTitle(Core.User.displayName(student.shortName, pronouns: student.pronouns), for: .normal)
        setTitleColor(.textDarkest, for: .normal)
        titleLabel?.numberOfLines = 1

        avatarView.isUserInteractionEnabled = false
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.url = student.avatarURL
        avatarView.name = student.name
        avatarView.layer.addDropShadow()
        addSubview(avatarView)

        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarView.heightAnchor.constraint(equalToConstant: 48),
            avatarView.widthAnchor.constraint(equalToConstant: 48),
            heightAnchor.constraint(equalToConstant: 105),
            widthAnchor.constraint(equalToConstant: 90)
        ])
    }
}

class AddStudentButton: UIButton {
    convenience init() {
        self.init(type: .system)

        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 16 + 48 + 8, leading: 0, bottom: 16, trailing: 0)
        config.titleLineBreakMode = .byTruncatingTail
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outcoming = incoming
            outcoming.font = UIFont.scaledNamedFont(.semibold12)
            return outcoming
        }
        configuration = config

        setTitle(String(localized: "Add Student", bundle: .parent), for: .normal)
        setTitleColor(.textDarkest, for: .normal)
        titleLabel?.numberOfLines = 1

        let circle = UIView()
        circle.backgroundColor = .textLightest.variantForLightMode
        circle.layer.addDropShadow()
        circle.layer.cornerRadius = 24
        circle.layer.borderColor = UIColor.borderMedium.cgColor
        circle.layer.borderWidth = 1 / UIScreen.main.scale
        circle.isUserInteractionEnabled = false
        circle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(circle)

        let icon = UIImageView(image: UIImage.addSolid)
        icon.isUserInteractionEnabled = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)

        NSLayoutConstraint.activate([
            circle.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            circle.centerXAnchor.constraint(equalTo: centerXAnchor),
            circle.heightAnchor.constraint(equalToConstant: 48),
            circle.widthAnchor.constraint(equalToConstant: 48),
            icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            icon.heightAnchor.constraint(equalToConstant: 20),
            icon.widthAnchor.constraint(equalToConstant: 20),
            heightAnchor.constraint(equalToConstant: 105),
            widthAnchor.constraint(equalToConstant: 90)
        ])
    }
}

extension CALayer {
    fileprivate func addDropShadow() {
        shadowOffset = CGSize(width: 0, height: 4.0)
        shadowColor =  UIColor(white: 0, alpha: 1).cgColor
        shadowOpacity = 0.15
        shadowRadius = 8
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
    }
}
