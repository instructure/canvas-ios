//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Combine
import UIKit

private extension PlannerViewController {
    var useAddMenu: Bool { ExperimentalFeature.modifyCalendarEvent.isEnabled }

    @objc func addToDoSelector() {
        addToDo()
    }
}

public class PlannerViewController: UIViewController {
    lazy var profileButton = UIBarButtonItem(image: .hamburgerSolid, style: .plain, target: self, action: #selector(openProfile))
    lazy var addButton = UIBarButtonItem(image: .addSolid)
    lazy var todayButton = UIBarButtonItem(image: .calendarTodayLine, style: .plain, target: self, action: #selector(selectToday))
    lazy var addMenu = UIMenu(options: .displayInline, children: [
        UIAction(title: String(localized: "Add To Do", bundle: .core), image: .noteLine) { [weak self] _ in
            self?.addToDo()
        },
        UIAction(title: String(localized: "Add Event", bundle: .core), image: .calendarMonthLine) { [weak self] _ in
            self?.addEvent()
        }
    ])

    lazy var calendar = CalendarViewController.create(delegate: self, selectedDate: selectedDate)
    let listPageController = PagesViewController()
    var list: PlannerListViewController! {
        listPageController.currentPage as? PlannerListViewController
    }

    let env = AppEnvironment.shared
    var listContentOffsetY: CGFloat = 0
    public var selectedDate: Date = Clock.now
    var studentID: String?

    lazy var calendarFilterInteractor: CalendarFilterInteractor = PlannerAssembly.makeFilterInteractor(observedUserId: studentID)
    lazy var offlineModeInteractor: OfflineModeInteractor = OfflineModeAssembly.make()
    private var subscriptions = Set<AnyCancellable>()

    private var currentlyDisplayedToday: Date?

    public static func create(studentID: String? = nil, selectedDate: Date = Clock.now) -> PlannerViewController {
        let controller = PlannerViewController()
        controller.studentID = studentID
        controller.selectedDate = selectedDate
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundLightest
        navigationItem.titleView = Brand.shared.headerImageView()

        profileButton.accessibilityIdentifier = "PlannerCalendar.profileButton"
        profileButton.accessibilityLabel = String(localized: "Profile Menu", bundle: .core)

        addButton.target = self
        addButton.action = useAddMenu ? nil : #selector(addToDoSelector)
        addButton.menu = useAddMenu ? addMenu : nil
        addButton.accessibilityIdentifier = "PlannerCalendar.addButton"
        addButton.accessibilityLabel = useAddMenu
            ? String(localized: "Add Menu", bundle: .core)
            : String(localized: "Add To Do", bundle: .core)

        todayButton.accessibilityIdentifier = "PlannerCalendar.todayButton"
        todayButton.accessibilityLabel = String(localized: "Go to today", bundle: .core)
        updateTodayButton()

        navigationItem.leftBarButtonItem = profileButton
        navigationItem.rightBarButtonItems = ExperimentalFeature.teacherCalendar.isEnabled ? [todayButton] : [addButton, todayButton]

        addChild(calendar)
        view.addSubview(calendar.view)
        calendar.didMove(toParent: self)
        calendar.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendar.view.topAnchor.constraint(equalTo: view.topAnchor),
            calendar.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendar.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let divider = DividerView()
        view.addSubview(divider)
        divider.tintColor = .borderMedium
        divider.isOpaque = false
        divider.pinToLeftAndRightOfSuperview()
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.topAnchor.constraint(equalTo: calendar.view.bottomAnchor).isActive = true

        calendar.view.layoutIfNeeded()

        addChild(listPageController)
        view.addSubview(listPageController.view)
        listPageController.didMove(toParent: self)
        listPageController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            listPageController.view.topAnchor.constraint(equalTo: divider.bottomAnchor),
            listPageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listPageController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            listPageController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        listPageController.dataSource = self
        listPageController.delegate = self
        listPageController.setCurrentPage(PlannerListViewController.create(
            start: selectedDate.startOfDay(),
            end: selectedDate.startOfDay().addDays(1),
            delegate: self
        ))

        view.setNeedsLayout()

        calendarFilterInteractor
            .load(ignoreCache: false)
            .replaceError(with: ())
            .sink { [weak self] _ in
                self?.plannerListWillRefresh()
            }
            .store(in: &subscriptions)

        offlineModeInteractor
            .observeIsOfflineMode()
            .sink { [weak self] isOffline in
                guard let self else { return }
                if useAddMenu {
                    addButton.action = isOffline ? #selector(showOfflineAlert) : nil
                    addButton.menu = isOffline ? nil : addMenu
                } else {
                    addButton.action = isOffline ? #selector(showOfflineAlert) : #selector(addToDoSelector)
                }
                addButton.tintColor = isOffline ? .disabledGray : .textLightest
            }
            .store(in: &subscriptions)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useGlobalNavStyle()
    }

    @objc func openProfile() {
        env.router.route(to: "/profile", from: self, options: .modal())
    }

    private func addToDo() {
        let weakVC = WeakViewController()
        let vc = PlannerAssembly.makeCreateToDoViewController(
            calendarListProviderInteractor: calendarFilterInteractor,
            completion: { [weak self] in
                if $0 == .didUpdate {
                    self?.plannerListWillRefresh()
                }
                self?.env.router.dismiss(weakVC)
            }
        )
        weakVC.setValue(vc)

        env.router.show(
            vc,
            from: self,
            options: .modal(isDismissable: false, embedInNav: true),
            analyticsRoute: "/calendar/new"
        )
    }

    private func addEvent() {
        let weakVC = WeakViewController()
        let vc = PlannerAssembly.makeCreateEventViewController(
            calendarListProviderInteractor: calendarFilterInteractor,
            completion: { [weak self] in
                if $0 == .didUpdate {
                    self?.plannerListWillRefresh()
                }
                self?.env.router.dismiss(weakVC)
            }
        )
        weakVC.setValue(vc)

        env.router.show(
            vc,
            from: self,
            options: .modal(isDismissable: false, embedInNav: true),
            analyticsRoute: "/calendar/new"
        )
    }

    @objc private func showOfflineAlert() {
        UIAlertController.showItemNotAvailableInOfflineAlert()
    }

    @objc func selectToday() {
        let date = Clock.now.startOfDay()
        calendar.showDate(date)
        updateList(date)
    }

    private func updateTodayButton() {
        let date = Clock.now.startOfDay()
        guard currentlyDisplayedToday != date else { return }

        currentlyDisplayedToday = date
        todayButton.image = makeTodayIcon(text: date.dayString)
    }

    private func makeTodayIcon(text: String) -> UIImage {
        let size = CGSize(width: 24, height: 24) // matches original image size
        // fixed as the rest of the navBar buttons
        let font: UIFont = .applicationFont(ofSize: 10, weight: .regular) // somehow this matches `scaledNamedFont(.regular12)`
        let textY: CGFloat = 8 // centers text vertically for the size & font above

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .paragraphStyle: paragraphStyle
            ]

            let attributedString = NSAttributedString(string: text, attributes: attributes)
            attributedString.draw(
                with: CGRect(x: 0, y: textY, width: size.width, height: size.height),
                options: .usesLineFragmentOrigin,
                context: nil
            )

            let bgImage = UIImage.calendarEmptyLine
            bgImage.draw(at: .zero)
        }
    }

    func updateList(_ date: Date) {
        guard !calendar.calendar.isDate(date, inSameDayAs: list.start) else { return }
        let newList = PlannerListViewController.create(
            start: date.startOfDay(),
            end: date.startOfDay().addDays(1),
            delegate: self
        )
        newList.loadViewIfNeeded()
        newList.tableView.contentInset = list.tableView.contentInset
        listPageController.setCurrentPage(newList, direction: date < list.start ? .reverse : .forward)

        // update Today button if needed alongside list update
        updateTodayButton()
    }
}

extension PlannerViewController: CalendarViewControllerDelegate {
    func calendarDidSelectDate(_ date: Date) {
        selectedDate = date
        calendar.showDate(date)
        updateList(date)
    }

    func calendarDidTransitionToDate(_ date: Date) {
        selectedDate = date
        calendar.updateSelectedDate(date)
        updateList(date)
    }

    func calendarDidResize(height: CGFloat, animated: Bool) {
        view.layoutIfNeeded()
    }

    func calendarWillFilter() {
        let filter = PlannerAssembly.makeFilterViewController(observedUserId: studentID) { [weak self] in
            self?.plannerListWillRefresh()
        }
        env.router.show(
            filter,
            from: self,
            options: .modal(.formSheet, isDismissable: false, embedInNav: true),
            analyticsRoute: "/calendar/filter"
        )
    }

    func getPlannables(from: Date, to: Date) -> GetPlannables {
        let contextCodes = calendarFilterInteractor.contextsForAPIFiltering().map(\.canvasContextID)
        return GetPlannables(userID: studentID, startDate: from, endDate: to, contextCodes: contextCodes)
    }
}

extension PlannerViewController: PlannerListDelegate {
    func plannerListWillRefresh() {
        calendar.refresh(force: true)
        list.refresh(force: true)
    }
}

extension PlannerViewController: PagesViewControllerDataSource, PagesViewControllerDelegate {
    public func pagesViewController(_ pages: PagesViewController, pageBefore page: UIViewController) -> UIViewController? {
        return listPageDelta(-1, from: (page as? PlannerListViewController)!)
    }

    public func pagesViewController(_ pages: PagesViewController, pageAfter page: UIViewController) -> UIViewController? {
        return listPageDelta(1, from: (page as? PlannerListViewController)!)
    }

    func listPageDelta(_ delta: Int, from list: PlannerListViewController) -> PlannerListViewController {
        let newList = PlannerListViewController.create(
            start: list.start.addDays(delta),
            end: list.end.addDays(delta),
            delegate: self
        )
        newList.loadViewIfNeeded()
        newList.tableView.verticalScrollIndicatorInsets = list.tableView.verticalScrollIndicatorInsets
        newList.tableView.contentInset = list.tableView.contentInset
        newList.title = DateFormatter.localizedString(from: newList.start, dateStyle: .long, timeStyle: .none)
        return newList
    }

    public func pagesViewController(_ pages: PagesViewController, didTransitionTo page: UIViewController) {
        selectedDate = list.start
        calendar.showDate(list.start)
    }
}
