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
import CanvasKit
import Core

private func attendanceError(message: String) -> Error {
    return NSError(domain: "com.instructure.rollcall", code: 0, userInfo: [
        NSLocalizedDescriptionKey: message,
    ])
}

class AttendanceViewController: UIViewController {
    private let client: CKIClient
    private let courseID: String
    private let session: RollCallSession

    private var sections: [CKISection] = [] {
        didSet {
            changeSectionButton.isEnabled = sections.count > 0
        }
    }
    private var sectionID: String? {
        didSet {
            sectionLabel.text = currentSectionTitle
        }
    }

    private var currentSectionTitle: String {
        return sectionID.flatMap { id in
            return sections
                .first { section in section.id == id }
                .map { $0.name }
        } ?? ""
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private var date: Date {
        didSet {
            calendarDayIconView.setDate(date)
            dateLabel?.text = AttendanceViewController.dateFormatter.string(from: date)
            dateLabel?.sizeToFit()
        }
    }

    private let tableView = UITableView()
    private var dateLabel: UILabel?
    private lazy var calendarDayIconView = CalendarDayIconView.create(date: date)
    private let sectionLabel = UILabel()
    private let changeSectionButton = UIButton(type: .system)
    private let header = UIView()
    private let markAllButton = UIButton(type: .custom)
    private var markAllButtonBottom: NSLayoutConstraint!

    private var statii: [AttendanceStatusController] = []

    @objc static let dateFormatter: DateFormatter = {
        let d = DateFormatter()
        d.dateStyle = .medium
        d.timeStyle = .none
        return d
    }()

    @objc let courseColor: UIColor

    @objc init(courseName: String, courseColor: UIColor, launchURL: URL, courseID: String, date: Date) throws {
        guard let client = CKIClient.current else { throw NSError(subdomain: "com.instructure.Teacher", description: "CKIClient client is nil") }
        self.courseColor = courseColor
        self.session = RollCallSession(client: client, initialLaunchURL: launchURL)
        self.date = date
        self.client = client
        self.courseID = courseID
        self.changeSectionButton.isEnabled = false

        super.init(nibName: nil, bundle: nil)
        session.delegate = self
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)

        let titleView = TitleSubtitleView.create()
        titleView.title = NSLocalizedString("Attendance", comment: "")
        titleView.subtitle = AttendanceViewController.dateFormatter.string(from: date)
        navigationItem.titleView = titleView
        dateLabel = titleView.subtitleLabel

        let datePickerButton = UIButton(type: .custom)
        datePickerButton.accessibilityIdentifier = "Attendance.selectDateButton"
        datePickerButton.accessibilityLabel = NSLocalizedString("Date picker", comment: "")
        datePickerButton.accessibilityHint = NSLocalizedString("Select to change the roll call date", comment: "")
        datePickerButton.addSubview(calendarDayIconView)
        calendarDayIconView.isUserInteractionEnabled = false
        datePickerButton.addTarget(self, action: #selector(showDatePicker(_:)), for: .primaryActionTriggered)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePickerButton)

        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .named(.backgroundLightest)

        let divider = UIView()
        divider.backgroundColor = .named(.borderMedium)
        divider.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(divider)

        sectionLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        sectionLabel.textColor = .named(.textDarkest)
        sectionLabel.text = NSLocalizedString(currentSectionTitle, comment: "")
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(sectionLabel)

        changeSectionButton.translatesAutoresizingMaskIntoConstraints = false
        changeSectionButton.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        changeSectionButton.titleLabel?.font = .preferredFont(forTextStyle: .caption1)
        changeSectionButton.setTitle(NSLocalizedString("Change Section", comment: ""), for: .normal)
        changeSectionButton.sizeToFit()
        changeSectionButton.addTarget(self, action: #selector(changeSection(_:)), for: .touchUpInside)
        changeSectionButton.tintColor = Core.Brand.shared.linkColor
        header.addSubview(changeSectionButton)

        tableView.backgroundColor = .named(.backgroundLightest)
        tableView.separatorInset = .zero
        tableView.separatorColor = .named(.borderMedium)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.registerCell(StatusCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()

        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshStatuses(sender:)), for: .valueChanged)
        tableView.refreshControl = refresh
        tableView.refreshControl?.beginRefreshing()

        markAllButton.backgroundColor = Brand.shared.buttonPrimaryBackground
        markAllButton.tintColor = Brand.shared.buttonPrimaryText
        markAllButton.translatesAutoresizingMaskIntoConstraints = false
        markAllButton.titleLabel?.font = .scaledNamedFont(.semibold16)
        markAllButton.addTarget(self, action: #selector(markRemainingPresent(_:)), for: .touchUpInside)
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useContextColor(courseColor)
    }

    func updateMarkAllButton() {
        let hasUnmarked = statii.contains(where: { $0.status.attendance == nil })
        let hasMarked = statii.contains(where: { $0.status.attendance != nil })

        let title = hasMarked
            ? NSLocalizedString("Mark Remaining as Present", comment: "")
            : NSLocalizedString("Mark All as Present", comment: "")
        markAllButton.setTitle(title, for: .normal)

        if hasUnmarked, markAllButtonBottom.constant != 0 {
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
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
            })
        }
    }

    func alertError(_ error: Error) {
        let alert = UIAlertController(
            title: NSLocalizedString("Attendance Error", comment: ""),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .default))
        present(alert, animated: true)
    }

    func prepareStatusControllers(for statuses: [Status]) {
        let existingControllers = statii
        statii = statuses.enumerated().map { index, status in
            let controller: AttendanceStatusController

            if let existing = existingControllers.first(where: { existing in
                return status.studentID == existing.status.studentID
            }) {
                controller  = existing
            } else {
                controller = AttendanceStatusController(status: status, in: session)
            }
            controller.statusDidChange = { [weak self] in
                if let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? StatusCell {
                    cell.status = self?.statii[index].status
                }
            }
            controller.statusUpdateDidFail = { [weak self] e in self?.alertError(e) }
            return controller
        }
        if isViewLoaded {
            tableView.reloadData()
        }
        updateMarkAllButton()
    }

    @objc func refreshStatusesForCurrentSection(completed: @escaping () -> Void) {
        guard let sectionID = self.sectionID else {
            completed()
            return
        }

        session.fetchStatuses(section: sectionID, date: date) { [weak self] (statii, error) in
            guard let me = self else { return }
            if let error = error {
                me.alertError(error)
            } else {
                me.prepareStatusControllers(for: statii)
            }
            completed()
        }
    }

    @objc func refreshStatuses(sender: UIRefreshControl?) {
        client.fetchAuthorizedSections(forCourseWithID: courseID) { [weak self] sections, error in
            guard let me = self else { return }

            if let error = error {
                me.alertError(error)
                return
            }

            guard sections.count > 0 else {
                me.alertError(attendanceError(message:
                    NSLocalizedString("There was a problem fetching the list of course sections.", comment: "")
                ))
                sender?.endRefreshing()
                return
            }

            me.sections = sections

            // select the 1st Section ID
            if me.sectionID == nil || !sections.contains(where: { $0.id == me.sectionID }) {
                if let firstID = sections.first?.id {
                    me.sectionID = firstID
                } else {
                    me.alertError(attendanceError(message:
                        NSLocalizedString("No sections available. Please make sure you are enrolled as a teacher or TA in at least on section of this course.", comment: "")
                    ))
                    return
                }
            }

            me.refreshStatusesForCurrentSection {
                sender?.endRefreshing()
            }
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func showDatePicker(_ sender: Any?) {
        let datePicker = DatePickerViewController()
        datePicker.initialDate = date
        datePicker.delegate = self
        let nav = UINavigationController(rootViewController: datePicker)
        nav.navigationBar.useModalStyle()
        nav.modalPresentationStyle = .popover
        nav.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(nav, animated: true, completion: nil)
    }

    @objc func markRemainingPresent(_ sender: Any?) {
        for statusController in statii where statusController.status.attendance == nil {
            statusController.update(attendance: .present)
        }
        updateMarkAllButton()
    }
}

extension AttendanceViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statii.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: StatusCell = tableView.dequeue(for: indexPath)
        cell.status = statii[indexPath.row].status
        return cell
    }

    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }

    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let sc = statii[indexPath.row]
        return [ Attendance.present, Attendance.absent, Attendance.late, nil ].compactMap { (value: Attendance?) -> UITableViewRowAction? in
            guard sc.status.attendance != value else { return nil }
            let action = UITableViewRowAction(style: .normal, title: value?.label ?? NSLocalizedString("Unmark", comment: "")) { [weak self] _, _ in
                sc.update(attendance: value)
                self?.updateMarkAllButton()
            }
            action.backgroundColor = value?.tintColor ?? .named(.oxford)
            return action
        }
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sc = statii[indexPath.row]
        switch sc.status.attendance {
        case .present: sc.update(attendance: .absent)
        case .absent: sc.update(attendance: .late)
        case .late: sc.update(attendance: nil)
        case .none: sc.update(attendance: .present)
        }
        updateMarkAllButton()
    }
}

extension AttendanceViewController: DatePickerDelegate {
    @objc func didSelectDate(_ date: Date) {
        self.date = date
        statii = []
        tableView.reloadData()
        updateMarkAllButton()
        let refreshControl = tableView.refreshControl
        refreshControl?.beginRefreshing()
        tableView.setContentOffset(CGPoint(x: 0, y: -(refreshControl?.frame.size.height ?? 0)), animated: true)
        refreshStatusesForCurrentSection {
            refreshControl?.endRefreshing()
        }
    }
}

extension AttendanceViewController: RollCallSessionDelegate {
    public func sessionDidBecomeActive(_ session: RollCallSession) {
        tableView.refreshControl?.beginRefreshing()
        refreshStatuses(sender: tableView.refreshControl)
    }

    public func session(_ session: RollCallSession, didFailWithError error: Error) {
        tableView.refreshControl?.endRefreshing()
        alertError(error)
    }

    public func session(_ session: RollCallSession, beganLaunchingToolInView view: UIWebView) {
        loadViewIfNeeded()
        tableView.backgroundView?.addSubview(view)
    }
}

extension AttendanceViewController {
    func changeToSection(withID sectionID: String) {
        guard self.sectionID != sectionID else { return }

        statii = []
        tableView.reloadData()
        updateMarkAllButton()
        self.sectionID = sectionID
        let refreshControl = tableView.refreshControl
        refreshControl?.beginRefreshing()
        tableView.scrollRectToVisible(CGRect(x: 0, y: -66, width: 1, height: 66), animated: true)
        refreshStatusesForCurrentSection {
            refreshControl?.endRefreshing()
        }
    }

    @objc
    private func changeSection(_ sender: UIButton) {
        let alert = UIAlertController(
            title: NSLocalizedString("Choose a Section", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )

        for section in sections {
            alert.addAction(UIAlertAction(title: section.name, style: .default) { [weak self] _ in
                self?.changeToSection(withID: section.id)
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceRect = changeSectionButton.bounds
            popover.sourceView = changeSectionButton
        }
        present(alert, animated: true)
    }
}
