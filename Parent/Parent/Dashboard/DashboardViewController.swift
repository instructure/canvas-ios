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

class DashboardViewController: ScreenViewTrackableViewController, ErrorViewController {
    @IBOutlet weak var addStudentView: UIView!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var studentListStack: UIStackView!
    @IBOutlet weak var studentListView: UIView!
    lazy var studentListHiddenHeight = studentListView.heightAnchor.constraint(equalToConstant: 0)
    @IBOutlet weak var dropdownButton: UIButton!
    @IBOutlet weak var dropdownView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var tabsContainer: UIView!
    let tabsController = UITabBarController()
    @IBOutlet weak var titleLabel: UILabel!

    var badgeCount: UInt = 0 {
        didSet { updateBadgeCount() }
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

        addStudentView.layer.addDropShadow()
        addStudentView.isHidden = true
        avatarView.isHidden = true
        dropdownView.isHidden = true
        titleLabel.text = nil

        studentListHiddenHeight.isActive = true

        tabsController.tabBar.useGlobalNavStyle()
        tabsController.tabBar.isTranslucent = false
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
        env.api.makeRequest(GetConversationsUnreadCountRequest()) { [weak self] (response, _, _) in performUIUpdate {
            self?.badgeCount = UInt(response?.unread_count ?? 0)
        } }
    }

    func updateBadgeCount() {
        profileButton.addBadge(number: badgeCount, color: currentColor)
        profileButton.accessibilityLabel = NSLocalizedString("Settings", comment: "")
        if badgeCount > 0 {
            profileButton.accessibilityHint = String.localizedStringWithFormat(
                NSLocalizedString("conversation_unread_messages", bundle: .core, comment: ""),
                badgeCount
            )
        }
    }

    func updateCurrentStudent(_ oldValue: Core.User?) {
        guard currentStudent == nil || currentStudent?.id != oldValue?.id else { return }

        currentStudentID = currentStudent?.id
        env.userDefaults?.parentCurrentStudentID = currentStudentID

        view.tintColor = currentColor
        updateHeader()
        updateTabs()
    }

    func updateHeader() {
        headerView.backgroundColor = currentColor.darkenToEnsureContrast(against: .white)
        profileButton.addBadge(number: badgeCount, color: currentColor)
        addStudentView.isHidden = false // provides shadow even when avatar covers it

        if let student = currentStudent {
            avatarView.name = student.name
            avatarView.url = student.avatarURL
            avatarView.isHidden = false
            let displayName = Core.User.displayName(student.shortName, pronouns: student.pronouns)
            titleLabel.text = displayName
            dropdownButton.accessibilityLabel = String.localizedStringWithFormat(
                NSLocalizedString("Current student: %@. Tap to switch students", comment: ""),
                displayName
            )
        } else {
            avatarView.isHidden = true
            titleLabel.text = NSLocalizedString("Add Student", comment: "")
            dropdownButton.accessibilityLabel = NSLocalizedString("Add Student", comment: "")
        }
    }

    func updateStudentList() {
        studentListStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dropdownView.isHidden = students.isEmpty
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

    @IBAction func didTapDropdownButton() {
        guard !students.isEmpty else { return addStudentController.addStudent() }
        toggleStudentList(studentListHiddenHeight.isActive)
    }

    @objc func didSelectStudent(sender: UIButton) {
        guard sender.tag >= 0, let student = students[sender.tag] else { return }
        headerView.backgroundColor = ColorScheme.observee(student.id).color
        toggleStudentList(false, completion: { [weak self] in
            self?.currentStudent = student
        })
    }

    func toggleStudentList(_ show: Bool = true, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.studentListHiddenHeight.isActive = !show
            self.dropdownView.transform = CGAffineTransform(rotationAngle: show ? .pi : 0)
            self.view.layoutIfNeeded()
        }, completion: { _ in
            completion?()
        })
    }

    func updateTabs() {
        let courses = currentStudentID.flatMap {
            CourseListViewController.create(studentID: $0)
        } ?? AdminViewController.create()
        courses.tabBarItem.title = NSLocalizedString("Courses", comment: "Courses Tab")
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
        calendar.tabBarItem.title = NSLocalizedString("Calendar", comment: "Calendar Tab")
        calendar.tabBarItem.image = .calendarTab
        calendar.tabBarItem.selectedImage = .calendarTabActive
        calendar.tabBarItem.accessibilityIdentifier = "TabBar.calendarTab"

        let alerts = currentStudentID.flatMap {
            ObserverAlertListViewController.create(studentID: $0)
        } ?? AdminViewController.create()
        alerts.tabBarItem.title = NSLocalizedString("Alerts", comment: "Alerts Tab")
        alerts.tabBarItem.image = .alertsTab
        alerts.tabBarItem.selectedImage = .alertsTabActive
        alerts.tabBarItem.accessibilityIdentifier = "TabBar.alertsTab"
        alerts.tabBarItem.badgeColor = currentColor
        alerts.tabBarItem.setBadgeTextAttributes([ .foregroundColor: UIColor.white ], for: .normal)
        alerts.loadViewIfNeeded() // Make sure it starts loading data for badge

        tabsController.viewControllers = [ courses, calendar, alerts ]
    }

    private func reportScreenView(for tabIndex: Int, viewController: UIViewController) {
        let map = ["courses", "calendar", "alerts"]
        let event = map[tabIndex]
        Analytics.shared.logScreenView(route: "/tabs/" + event, viewController: viewController)
    }

    @objc private func checkForPolicyChanges() {
        LoginUsePolicy.checkAcceptablePolicy(from: self, cancelled: {
            AppEnvironment.shared.loginDelegate?.changeUser()
        })
    }
}

extension DashboardViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController), tabBarController.selectedViewController != viewController {
            reportScreenView(for: index, viewController: viewController)
        }

        return true
    }
}

class StudentButton: UIButton {
    let avatarView = AvatarView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))

    convenience init(student: Core.User) {
        self.init(type: .system)
        accessibilityIdentifier = "StudentButton.\(student.id)"

        contentEdgeInsets.top = 16 + 48 + 8
        contentEdgeInsets.bottom = 16
        setTitle(Core.User.displayName(student.shortName, pronouns: student.pronouns), for: .normal)
        setTitleColor(.textDarkest, for: .normal)
        titleLabel?.font = UIFont.scaledNamedFont(.semibold12)
        titleLabel?.lineBreakMode = .byTruncatingTail
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
            widthAnchor.constraint(equalToConstant: 90),
        ])
    }
}

class AddStudentButton: UIButton {
    convenience init() {
        self.init(type: .system)
        contentEdgeInsets.top = 16 + 48 + 8
        contentEdgeInsets.bottom = 16
        setTitle(NSLocalizedString("Add Student", comment: ""), for: .normal)
        setTitleColor(.textDarkest, for: .normal)
        titleLabel?.font = UIFont.scaledNamedFont(.semibold12)
        titleLabel?.lineBreakMode = .byTruncatingTail
        titleLabel?.numberOfLines = 1

        let circle = UIView()
        circle.backgroundColor = .white
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
            widthAnchor.constraint(equalToConstant: 90),
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
