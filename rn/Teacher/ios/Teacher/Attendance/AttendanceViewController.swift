//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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
import Core

class AttendanceViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol {
    let calendarDayIconView = CalendarDayIconView.create(date: Clock.now)
    let changeSectionButton = UIButton(type: .system)
    let header = UIView()
    let markAllButton = UIButton(type: .custom)
    var markAllButtonBottom: NSLayoutConstraint!
    let sectionLabel = UILabel()
    let tableView = UITableView()
    let titleSubtitleView = TitleSubtitleView.create()

    var color: UIColor?
    let context: Context
    var currentSection: CourseSection?
    var date = Clock.now
    let env = AppEnvironment.shared
    let session: RollCallSession
    var statuses: [AttendanceStatusController] = []

    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "/\(context.pathComponent)/attendence"
    )
    static let dateFormatter: DateFormatter = {
        let d = DateFormatter()
        d.dateStyle = .medium
        d.timeStyle = .none
        return d
    }()

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.update()
    }
    lazy var sections = env.subscribe(GetCourseSections(courseID: context.id)) { [weak self] in
        self?.update()
    }

    init(context: Context, toolID: String) {
        self.context = context
        session = RollCallSession(context: context, toolID: toolID)
        super.init(nibName: nil, bundle: nil)
        session.delegate = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        setupTitleViewInNavbar(title: NSLocalizedString("Attendance", comment: ""))
        titleSubtitleView.subtitle = AttendanceViewController.dateFormatter.string(from: date)

        let datePickerButton = UIButton(type: .custom)
        datePickerButton.accessibilityIdentifier = "Attendance.selectDateButton"
        datePickerButton.accessibilityLabel = NSLocalizedString("Date picker", comment: "")
        datePickerButton.accessibilityHint = NSLocalizedString("Select to change the roll call date", comment: "")
        datePickerButton.addSubview(calendarDayIconView)
        datePickerButton.addTarget(self, action: #selector(showDatePicker(_:)), for: .primaryActionTriggered)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePickerButton)

        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .backgroundLightest

        let divider = UIView()
        divider.backgroundColor = .borderMedium
        divider.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(divider)

        sectionLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        sectionLabel.textColor = .textDarkest
        sectionLabel.text = currentSection?.name
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(sectionLabel)

        changeSectionButton.isEnabled = false
        changeSectionButton.translatesAutoresizingMaskIntoConstraints = false
        changeSectionButton.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        changeSectionButton.titleLabel?.font = .preferredFont(forTextStyle: .caption1)
        changeSectionButton.setTitle(NSLocalizedString("Change Section", comment: ""), for: .normal)
        changeSectionButton.sizeToFit()
        changeSectionButton.addTarget(self, action: #selector(changeSection(_:)), for: .primaryActionTriggered)
        changeSectionButton.tintColor = Core.Brand.shared.linkColor
        header.addSubview(changeSectionButton)

        tableView.backgroundColor = .backgroundLightest
        tableView.separatorInset = .zero
        tableView.separatorColor = .borderMedium
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.registerCell(StatusCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()

        tableView.refreshControl = CircleRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl?.beginRefreshing()

        markAllButton.backgroundColor = Brand.shared.buttonPrimaryBackground
        markAllButton.tintColor = Brand.shared.buttonPrimaryText
        markAllButton.translatesAutoresizingMaskIntoConstraints = false
        markAllButton.titleLabel?.font = .scaledNamedFont(.semibold16)
        markAllButton.addTarget(self, action: #selector(markRemainingPresent(_:)), for: .primaryActionTriggered)
        markAllButtonBottom = markAllButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 50)

        view.addSubview(tableView)
        view.addSubview(header)
        view.addSubview(markAllButton)
        NSLayoutConstraint.activate([
            datePickerButton.heightAnchor.constraint(equalTo: datePickerButton.widthAnchor),
            datePickerButton.widthAnchor.constraint(equalToConstant: 24),

            divider.heightAnchor.constraint(equalToConstant: 0.5),
            divider.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: header.bottomAnchor),

            sectionLabel.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            sectionLabel.trailingAnchor.constraint(equalTo: changeSectionButton.leadingAnchor, constant: -8),
            sectionLabel.bottomAnchor.constraint(equalTo: divider.bottomAnchor, constant: -12.0),
            sectionLabel.topAnchor.constraint(equalTo: header.topAnchor, constant: 16),

            changeSectionButton.heightAnchor.constraint(equalToConstant: 40),
            changeSectionButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            changeSectionButton.lastBaselineAnchor.constraint(equalTo: sectionLabel.lastBaselineAnchor),

            header.heightAnchor.constraint(greaterThanOrEqualToConstant: 50.0),
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.bottomAnchor.constraint(equalTo: tableView.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.bottomAnchor.constraint(equalTo: markAllButton.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            markAllButtonBottom,
            markAllButton.heightAnchor.constraint(equalToConstant: 50.0),
            markAllButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            markAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tableView.setEditing(false, animated: false)

        session.start()
        colors.refresh()
        course.refresh()
        sections.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(color)
    }

    @objc func markRemainingPresent(_ sender: Any?) {
        for sc in statuses where sc.status.attendance == nil {
            sc.update(attendance: .present)
        }
        updateMarkAllButton()
    }

    func updateMarkAllButton() {
        let hasUnmarked = statuses.contains(where: { $0.status.attendance == nil })
        let hasMarked = statuses.contains(where: { $0.status.attendance != nil })

        let title = hasMarked
            ? NSLocalizedString("Mark Remaining as Present", comment: "")
            : NSLocalizedString("Mark All as Present", comment: "")
        markAllButton.setTitle(title, for: .normal)

        if hasUnmarked, markAllButtonBottom.constant != 0 {
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                self.markAllButton.isHidden = false
                self.markAllButtonBottom.constant = 0
                self.view.setNeedsUpdateConstraints()
                self.view.layoutIfNeeded()
            })
        } else if !hasUnmarked, markAllButtonBottom.constant != markAllButton.frame.height {
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                self.markAllButtonBottom.constant = self.markAllButton.frame.height
                self.view.setNeedsUpdateConstraints()
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.markAllButton.isHidden = true
            })
        }
    }

    func alertError(_ error: Error) {
        print(error)
        let alert = UIAlertController(
            title: NSLocalizedString("Attendance Error", comment: ""),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .default))
        env.router.show(alert, from: self, options: .modal())
    }

    @objc func refresh() {
        tableView.refreshControl?.beginRefreshing()
        colors.refresh(force: true)
        course.refresh(force: true)
        sections.refresh(force: true)
        refreshStatusesForCurrentSection()
    }

    func update() {
        if !colors.pending, let course = course.first {
            color = course.color
            navigationController?.navigationBar.useContextColor(color)
        }
        if !sections.pending {
            changeSectionButton.isEnabled = !sections.isEmpty
            changeToSection(currentSection ?? sections.first)
        }
        if let error = course.error ?? sections.error {
            alertError(error)
            tableView.refreshControl?.endRefreshing()
        }
    }

    func refreshStatusesForCurrentSection() {
        guard let section = currentSection?.id, !section.isEmpty, case .active = session.state else { return }
        tableView.refreshControl?.beginRefreshing()
        session.fetchStatuses(section: section, date: date) { [weak self] (statuses, error) in performUIUpdate {
            if let error = error {
                self?.alertError(error)
            } else {
                self?.prepareStatusControllers(for: statuses)
            }
            self?.tableView.refreshControl?.endRefreshing()
        } }
    }

    func prepareStatusControllers(for statuses: [Status]) {
        let existingControllers = self.statuses
        self.statuses = statuses.enumerated().map { index, status in
            let controller = existingControllers.first { status.studentID == $0.status.studentID }
                ?? AttendanceStatusController(status: status, in: session)
            controller.statusDidChange = { [weak self] in
                guard let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? StatusCell else { return }
                cell.status = self?.statuses[index].status
            }
            controller.statusUpdateDidFail = { [weak self] e in self?.alertError(e) }
            return controller
        }
        tableView.reloadData()
        updateMarkAllButton()
    }
}

extension AttendanceViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StatusCell = tableView.dequeue(for: indexPath)
        cell.status = statuses[indexPath.row].status
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let sc = statuses[indexPath.row]
        return UISwipeActionsConfiguration(actions: [ Attendance.present, Attendance.absent, Attendance.late, nil ].compactMap { (value: Attendance?) -> UIContextualAction? in
            guard sc.status.attendance != value else { return nil }
            let action = UIContextualAction(style: .normal, title: value?.label ?? NSLocalizedString("Unmark", comment: "")) { [weak self] _, _, done in
                sc.update(attendance: value)
                self?.updateMarkAllButton()
                done(true)
            }
            action.backgroundColor = value?.tintColor ?? .oxford
            return action
        })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sc = statuses[indexPath.row]
        switch sc.status.attendance {
        case .present: sc.update(attendance: .absent)
        case .absent: sc.update(attendance: .late)
        case .late: sc.update(attendance: nil)
        case .none: sc.update(attendance: .present)
        }
        updateMarkAllButton()
    }
}

extension AttendanceViewController: RollCallSessionDelegate {
    func sessionDidBecomeActive(_ session: RollCallSession) {
        refreshStatusesForCurrentSection()
    }

    func session(_ session: RollCallSession, didFailWithError error: Error) {
        alertError(error)
        tableView.refreshControl?.endRefreshing()
    }
}

extension AttendanceViewController: DatePickerDelegate {
    @objc func showDatePicker(_ sender: Any?) {
        let datePicker = DatePickerViewController(selected: date, delegate: self)
        let nav = UINavigationController(rootViewController: datePicker)
        nav.navigationBar.useModalStyle()
        nav.modalPresentationStyle = .popover
        nav.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        env.router.show(nav, from: self, options: .modal())
    }

    func didSelectDate(_ date: Date) {
        self.date = date
        calendarDayIconView.setDate(date)
        titleSubtitleView.subtitle = AttendanceViewController.dateFormatter.string(from: date)
        statuses = []
        tableView.reloadData()
        updateMarkAllButton()
        refreshStatusesForCurrentSection()
    }
}

extension AttendanceViewController {
    @objc func changeSection(_ sender: UIButton) {
        let alert = UIAlertController(
            title: NSLocalizedString("Choose a Section", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )

        for section in sections {
            alert.addAction(UIAlertAction(title: section.name, style: .default) { [weak self] _ in
                self?.changeToSection(section)
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        alert.popoverPresentationController?.sourceRect = changeSectionButton.bounds
        alert.popoverPresentationController?.sourceView = changeSectionButton
        env.router.show(alert, from: self, options: .modal())
    }

    func changeToSection(_ section: CourseSection?) {
        guard currentSection?.id != section?.id else { return }
        currentSection = section

        sectionLabel.text = section?.name
        statuses = []
        tableView.reloadData()
        updateMarkAllButton()
        refreshStatusesForCurrentSection()
    }
}
