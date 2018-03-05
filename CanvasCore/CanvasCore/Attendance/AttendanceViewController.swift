//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import CanvasKit

private func attendanceError(message: String) -> Error {
    return NSError(domain: "com.instructure.rollcall", code: 0, userInfo: [
        NSLocalizedDescriptionKey: message,
    ])
}

open class AttendanceViewController: UIViewController {
    fileprivate let client: CKIClient
    fileprivate let courseID: String
    fileprivate let session: RollCallSession
    
    fileprivate var sections: [CKISection] = [] {
        didSet {
            changeSectionButton.isEnabled = sections.count > 0
        }
    }
    fileprivate var sectionID: Int? {
        didSet {
            sectionLabel.text = currentSectionTitle
        }
    }
    
    fileprivate var currentSectionTitle: String {
        get {
            return sectionID.flatMap { id in
                return sections
                    .first { section in Int(section.id) == id }
                    .map { $0.name }
            } ?? ""
        }
    }
    
    fileprivate var date: Date {
        didSet {
            dateLabel?.text = AttendanceViewController.dateFormatter.string(from: date)
            dateLabel?.sizeToFit()
        }
    }

    fileprivate let tableView = UITableView()
    fileprivate var dateLabel: UILabel?
    fileprivate let sectionLabel = UILabel()
    fileprivate let changeSectionButton = UIButton(type: .system)
    fileprivate let header = UIView()
    fileprivate let bigBlueButton = UIButton(type: .custom)
    fileprivate var bigBlueButtonBottom: NSLayoutConstraint!
    
    fileprivate var statii: [AttendanceStatusController] = []
    
    static let dateFormatter: DateFormatter = {
        let d = DateFormatter()
        d.dateStyle = .medium
        d.timeStyle = .none
        return d
    }()
    
    public init(client: CKIClient, launchURL: URL, courseID: String, date: Date) {
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
        view.backgroundColor = .white
        
        
        let titleStuff = self.titleView(with: NSLocalizedString("Attendance", tableName: "Localizable", bundle: .core, value: "", comment: ""), and: AttendanceViewController.dateFormatter.string(from: date))
        titleStuff.titleLabel.textColor = .white
        titleStuff.subtitleLabel.textColor = .white
        navigationItem.titleView = titleStuff.titleView
        dateLabel = titleStuff.subtitleLabel
        
        let datePickerButton = UIBarButtonItem(image: UIImage(named: "attendance-calendar", in: .core, compatibleWith: nil), style: .plain, target: self, action: #selector(showDatePicker(_:)))
        datePickerButton.accessibilityLabel = NSLocalizedString("Date picker", tableName: "Localizable", bundle: .core, value: "", comment: "")
        datePickerButton.accessibilityHint = NSLocalizedString("Select to change the roll call date", tableName: "Localizable", bundle: .core, value: "", comment: "")
        navigationItem.rightBarButtonItem = datePickerButton
        
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .white
        
        let divider = UIView()
        divider.backgroundColor = #colorLiteral(red: 0.7803921569, green: 0.8039215686, blue: 0.8196078431, alpha: 1)
        divider.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(divider)
        
        sectionLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold)
        sectionLabel.textColor = #colorLiteral(red: 0.1764705882, green: 0.231372549, blue: 0.2705882353, alpha: 1)
        sectionLabel.text = NSLocalizedString(currentSectionTitle, comment: "")
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(sectionLabel)
        
        changeSectionButton.translatesAutoresizingMaskIntoConstraints = false
        changeSectionButton.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        changeSectionButton.titleLabel?.font = .preferredFont(forTextStyle: .caption1)
        changeSectionButton.setTitle(NSLocalizedString("Change Section", tableName: "Localizable", bundle: .core, value: "", comment: ""), for: .normal)
        changeSectionButton.sizeToFit()
        changeSectionButton.addTarget(self, action: #selector(changeSection(_:)), for: .touchUpInside)
        header.addSubview(changeSectionButton)
        
        tableView.separatorInset = .zero
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(StatusCell.self, forCellReuseIdentifier: StatusCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshStatuses(sender:)), for: .valueChanged)
        tableView.refreshControl = refresh
        tableView.refreshControl?.beginRefreshing()
        
        bigBlueButton.backgroundColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.8862745098, alpha: 1)
        bigBlueButton.translatesAutoresizingMaskIntoConstraints = false
        bigBlueButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
        bigBlueButton.addTarget(self, action: #selector(markRemainingPresent(_:)), for: .touchUpInside)
        bigBlueButtonBottom = bigBlueButton.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: 50)
        
        view.addSubview(tableView)
        view.addSubview(header)
        view.addSubview(bigBlueButton)
        NSLayoutConstraint.activate([
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
            header.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            header.bottomAnchor.constraint(equalTo: tableView.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: bigBlueButton.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            bigBlueButtonBottom,
            bigBlueButton.heightAnchor.constraint(equalToConstant: 50.0),
            bigBlueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bigBlueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        tableView.setEditing(false, animated: false)
    }
    
    func updateBigBlueButton() {
        // If ALL are unmarked, display "Mark All as Present"
        // Or, if less than all are unmarked, display "Mark Remaining as Present"
        
        let containsNonNull = statii.contains(where: { $0.status.attendance != nil })
        if !containsNonNull {
            bigBlueButton.setTitle(NSLocalizedString("Mark All as Present", tableName: "Localizable", bundle: .core, value: "", comment: ""), for: .normal)
        } else {
            bigBlueButton.setTitle(NSLocalizedString("Mark Remaining as Present", tableName: "Localizable", bundle: .core, value: "", comment: ""), for: .normal)
        }
        
        showOrHideBigBlueButton()
    }
    
    func showOrHideBigBlueButton() {
        let containsNull = statii.contains(where: { $0.status.attendance == nil })
        if containsNull && bigBlueButtonBottom.constant != 0 {
            bigBlueButtonBottom.constant = 0
            view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        } else if !containsNull && bigBlueButtonBottom.constant != 50 {
            // 49 pts for tab bar stupidness, 50 to make itgo back and hide
            bigBlueButtonBottom.constant = 50
            view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func alertError(_ error: Error) {
        let alert = UIAlertController(
            title: NSLocalizedString("Attendance Error", tableName: "Localizable", bundle: .core, value: "", comment: "Error title for attendance app"),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("Dismiss", tableName: "Localizable", bundle: .core, value: "", comment: "Dismiss an error alert"),
            style: .default,
            handler: nil
        ))
        
        present(alert, animated: true, completion: nil)
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
        updateBigBlueButton()
    }
    
    func refreshStatusesForCurrentSection(completed: @escaping () -> Void) {
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
    
    func refreshStatuses(sender: UIRefreshControl?) {
        client.fetchAuthorizedSections(forCourseWithID: courseID) { [weak self] sections, error in
            guard let me = self else { return }
            
            if let error = error {
                me.alertError(error)
                return
            }
            
            guard sections.count > 0 else {
                me.alertError(attendanceError(message:
                    NSLocalizedString("There was a problem fetching the list of course sections.", tableName: "Localizable", bundle: .core, value: "", comment: "")
                ))
                sender?.endRefreshing()
                return
            }
            
            me.sections = sections
            
            // select the 1st Section ID
            if me.sectionID == nil || !sections.contains(where: { Int($0.id) == me.sectionID }) {
                if let firstID = sections.first.flatMap({ Int($0.id) }) {
                    me.sectionID = firstID
                } else {
                    me.alertError(attendanceError(message:
                        NSLocalizedString("No sections available. Please make sure you are enrolled as a teacher or TA in at least on section of this course.", tableName: "Localizable", bundle: .core, value: "", comment: "")
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
    
    private func titleView(with title: String, and subtitle: String) -> (titleView: UIView, titleLabel: UILabel, subtitleLabel: UILabel) {
        let titleLabel = UILabel(frame: CGRect(x:0, y:-2, width:0, height:0))
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textAlignment = .center
        
        titleLabel.text = title
        titleLabel.sizeToFit()
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let maxWidth = max(titleLabel.frame.size.width, subtitleLabel.frame.size.width)
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: maxWidth, height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        // Center title or subtitle on screen (depending on which is larger)
        if titleLabel.frame.width >= subtitleLabel.frame.width {
            var adjustment = subtitleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (subtitleLabel.frame.width/2)
            subtitleLabel.frame = adjustment
        } else {
            var adjustment = titleLabel.frame
            adjustment.origin.x = titleView.frame.origin.x + (titleView.frame.width/2) - (titleLabel.frame.width/2)
            titleLabel.frame = adjustment
        }
        
        return (titleView, titleLabel, subtitleLabel)
    }
    
    func showDatePicker(_ sender: Any?) {
        let datePicker = DatePickerViewController()
        datePicker.initialDate = date
        datePicker.delegate = self
        let nav = UINavigationController(rootViewController: datePicker)
        nav.modalPresentationStyle = .popover
        nav.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(nav, animated: true, completion: nil)
    }
    
    func markRemainingPresent(_ sender: Any?) {
        statii.forEach { statusController in
            if statusController.status.attendance == nil {
                statusController.update(attendance: .present)
            }
        }
    }
}

extension AttendanceViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statii.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatusCell.reuseID) as? StatusCell else {
            fatalError("Expected a StatusCell instance")
        }
        
        cell.status = statii[indexPath.row].status
        return cell
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions: [UITableViewRowAction] = []
        let sc = statii[indexPath.row]
        
        let newStatus: (Attendance?) -> ((UITableViewRowAction, IndexPath) -> Void) = { newStatus in
            return { action, path in
                sc.update(attendance: newStatus)
            }
        }
        
        if sc.status.attendance != .present {
            let action = UITableViewRowAction(style: .normal, title: NSLocalizedString("Present", tableName: "Localizable", bundle: .core, value: "", comment: "Mark student present"), handler: newStatus(.present))
            action.backgroundColor = #colorLiteral(red: 0, green: 0.6745098039, blue: 0.09411764706, alpha: 1)
            actions.append(action)
        }

        if sc.status.attendance != .absent {
            let action = UITableViewRowAction(style: .normal, title: NSLocalizedString("Absent", tableName: "Localizable", bundle: .core, value: "", comment: "Mark student absent"), handler: newStatus(.absent))
            action.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.02352941176, blue: 0.07058823529, alpha: 1)
            actions.append(action)
        }
        
        if sc.status.attendance != .late {
            let action = UITableViewRowAction(style: .normal, title: NSLocalizedString("Late", tableName: "Localizable", bundle: .core, value: "", comment: "Mark student late"), handler: newStatus(.late))
            action.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.368627451, blue: 0.07450980392, alpha: 1)
            actions.append(action)
        }

        if sc.status.attendance != nil {
            let action = UITableViewRowAction(style: .normal, title: NSLocalizedString("Unmark", tableName: "Localizable", bundle: .core, value: "", comment: "Remove attendance status"), handler: newStatus(nil))
            action.backgroundColor = #colorLiteral(red: 0.4509803922, green: 0.5058823529, blue: 0.5490196078, alpha: 1)
            actions.append(action)
        }

        return actions
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sc = statii[indexPath.row]
        
        if let attendance = sc.status.attendance {
            switch attendance {
            case .present: sc.update(attendance: .absent)
            case .absent: sc.update(attendance: .late)
            case .late: sc.update(attendance: nil)
            }
        } else {
            sc.update(attendance: .present)
        }
    }
}


extension AttendanceViewController: DatePickerDelegate {
    func didSelectDate(_ date: Date) {
        self.date = date
        statii = []
        tableView.reloadData()
        updateBigBlueButton()
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
        if let current = self.sectionID, current == Int(sectionID) {
            return
        }
        
        statii = []
        tableView.reloadData()
        updateBigBlueButton()
        self.sectionID = Int(sectionID)
        let refreshControl = tableView.refreshControl
        refreshControl?.beginRefreshing()
        tableView.scrollRectToVisible(CGRect(x: 0, y: -66, width: 1, height: 66), animated: true)
        refreshStatusesForCurrentSection {
            refreshControl?.endRefreshing()
        }
    }
    
    @objc
    fileprivate func changeSection(_ sender: UIButton) {
        let alert = UIAlertController(
            title: NSLocalizedString("Choose a Section", tableName: "Localizable", bundle: .core, value: "", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let changeSection: (String) -> (Any) -> Void = { sectionID in
            return { [weak self] _ in
                guard let me = self else { return }
                me.changeToSection(withID: sectionID)
            }
        }
        
        sections.forEach { section in
            alert.addAction(
                UIAlertAction(title: section.name, style: .default, handler: changeSection(section.id))
            )
        }
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Localizable", bundle: .core, value: "", comment: ""),style: .cancel, handler: nil)
        )

        if let popover = alert.popoverPresentationController {
            popover.sourceRect = changeSectionButton.bounds
            popover.sourceView = changeSectionButton
        }
        
        present(alert, animated: true, completion: nil)
    }
}
