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

import Foundation
import ReactiveSwift
import CanvasCore
import Core

class StudentSettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let activityIndicator = UIActivityIndicatorView(style: .white)
    private var session: Session!
    private var env: AppEnvironment!
    private var studentID: String = ""

    var studentObserver: ManagedObjectObserver<Student>?

    fileprivate var observeUpdatesDisposable: Disposable?

    private let formatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()
    private let settingsSection = 1
    private var currentlySelectedIndexPath: IndexPath?
    private var presenter: StudentSettingsPresenter!

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------

    static func create(_ session: Session, studentID: String) -> StudentSettingsViewController {
        let controller = StudentSettingsViewController.loadFromStoryboard()
        controller.presenter = StudentSettingsPresenter(view: controller, studentID: studentID)
        controller.session = session
        controller.studentID = studentID
        //  swiftlint:disable:next force_try
        controller.studentObserver = try! Student.observer(session, studentID: studentID)

        return controller
    }

    // ---------------------------------------------
    // MARK: - UIViewController LifeCycle
    // ---------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()

        _ = studentObserver?.signal.observe(on: UIScheduler()).observeValues { [unowned self] (change, _) in
            switch change {
            case .insert, .update:
                self.tableView?.reloadData()
            case .delete:
                if let count = try? Student.countOfObservedStudents(self.session), count == 0 {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }

        self.refresh(nil)
    }

    func setupTableView() {
        tableView.keyboardDismissMode = .onDrag
        let nib = UINib(nibName: String(describing: StudentSettingsHeaderView.self), bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: String(describing: StudentSettingsHeaderView.self))
        tableView.registerCell(UITableViewCell.self)

        for (i, alert) in AlertThresholdType.validThresholdTypes.enumerated() {
            switch alert {
            case .courseAnnouncement, .assignmentMissing, .institutionAnnouncement:
                tableView.register(SwitchCell.self, forCellReuseIdentifier: "cell_\(i)")
            default:
                tableView.register(IntCell.self, forCellReuseIdentifier: "cell_\(i)")
            }
        }

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    func reload() {
        tableView.reloadData()
    }

    func validateValueForRow(_ type: AlertThresholdType) -> Bool {
        guard let row = cellForType(type) as? IntCell else { fatalError("Could not find CourseGradeLow to compare.") }

        let value: Int? = row.value

        if let value = value, value > 100 {
            notifyUserOfInvalidInput(NSLocalizedString("Cannot use percent that is higher than 100", comment: "Percent value is over 100"))
            return false
        }
        if let value = value, value < 0 {
            notifyUserOfInvalidInput(NSLocalizedString("Cannot use percent that is less than 0", comment: "Percent value is under 0"))
            return false
        }

        switch type {
        case .courseAnnouncement, .assignmentMissing:
            fatalError("IntRow should never be used for this Alert Threshold Type")
        case .courseGradeHigh:
            guard let comparisonRow = cellForType(.courseGradeLow) as? IntCell else {
                fatalError("Could not find CourseGradeLow to compare.")
            }

            if let comparisonValue = comparisonRow.value, let value = value, value < comparisonValue {
                row.valueTextField.text = "\(comparisonValue)"
                notifyUserOfInvalidInput(NSLocalizedString("High course grade cannot be lower than low course grade", comment: "High Course Grade too Low"))
                return false
            }
        case .courseGradeLow:
            guard let comparisonRow = cellForType(.courseGradeHigh) as? IntCell else {
                fatalError("Could not find CourseGradeHigh to compare.")
            }

            if let comparisonValue = comparisonRow.value, let value = value, value > comparisonValue {
                row.valueTextField.text = "\(comparisonValue)"
                notifyUserOfInvalidInput(NSLocalizedString("Low course grade cannot be higher than high course grade", comment: "Low Course Grade too High"))
                return false
            }
        case .assignmentGradeHigh:
            guard let comparisonRow = cellForType(.assignmentGradeLow) as? IntCell else {
                fatalError("Could not find CourseGradeLow to compare.")
            }

            if let comparisonValue = comparisonRow.value, let value = value, value < comparisonValue {
                row.valueTextField.text = "\(comparisonValue)"
                notifyUserOfInvalidInput(NSLocalizedString("High assignment grade cannot be lower than low assignment grade", comment: "High Assignment Grade too Low"))
                return false
            }
        case .assignmentGradeLow:
            guard let comparisonRow = cellForType(.assignmentGradeHigh) as? IntCell else {
                fatalError("Could not find CourseGradeLow to compare.")
            }

            if let comparisonValue = comparisonRow.value, let value = value, value > comparisonValue {
                row.valueTextField.text = "\(comparisonValue)"
                notifyUserOfInvalidInput(NSLocalizedString("Low assignment grade cannot be higher than high assignment grade", comment: "Low Assignment Grade too High"))
                return false
            }
        default:
            fatalError("IntRow should never be used for this Alert Threshold Type")
        }
        return true
    }

    @objc func notifyUserOfInvalidInput(_ message: String) {
        let title = NSLocalizedString("Invalid Input", comment: "Title for an alert view")

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button Title"), style: .default, handler: { _ in
        }))

        present(alert, animated: true, completion: nil)
    }

    @objc func refresh(_ refreshControl: UIRefreshControl?) {
        presenter.viewIsReady()
    }

    // ---------------------------------------------
    // MARK: - View Setup
    // ---------------------------------------------
    @objc func setupNavigationBar() {
        guard let navBar = self.navigationController?.navigationBar else { return }

        let scheme = ColorScheme.observee(studentID)
        navBar.backgroundColor = scheme.color
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.hidesWhenStopped = true
    }

    func descriptionForType(_ type: AlertThresholdType) -> String {
        switch type {
        case .courseGradeLow:
            return NSLocalizedString("Course grade below", comment: "Course Grade Low On Description")
        case .courseGradeHigh:
            return NSLocalizedString("Course grade above", comment: "Course Grade High On Description")
        case .assignmentMissing:
            return NSLocalizedString("Assignment missing", comment: "Assignment Missing Description")
        case .assignmentGradeLow:
            return NSLocalizedString("Assignment grade below", comment: "Assignment Grade Low On Description")
        case .assignmentGradeHigh:
            return NSLocalizedString("Assignment grade above", comment: "Assignment Grade High On Description")
        case .institutionAnnouncement:
            return NSLocalizedString("Institution announcements", comment: "Institution Announcement Description")
        case .courseAnnouncement:
            return NSLocalizedString("Course announcements", comment: "Course Announcement Description")
        }
    }

    @objc func displayError(error: NSError) {
        let title = NSLocalizedString("An Error Occurred", comment: "")
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.present(alert, animated: true)
        }
    }
}

extension StudentSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == settingsSection {
            return AlertThresholdType.validThresholdTypes.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell_\(indexPath.row)"
        let alert = AlertThresholdType.validThresholdTypes[indexPath.row]

        switch alert {
        case .courseAnnouncement, .assignmentMissing, .institutionAnnouncement:
            guard let cell: SwitchCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? SwitchCell else { fatalError("invalid cell") }
            cell.selectionStyle = .none
            cell.textLabel?.text = descriptionForType(alert)
            if presenter.thresholdForType(alert) != nil {
                cell.toggle.isOn = true
            }
            cell.type = alert
            cell.toggle.tag = indexPath.row
            cell.toggle.isEnabled = true
            cell.toggle.addTarget(self, action: #selector(switchCellDidToggleValue(_:)), for: UIControl.Event.valueChanged)
            return cell
        default:
            guard let cell: IntCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? IntCell else { fatalError("invalid cell") }
            cell.type = alert
            cell.selectionStyle = .none
            cell.valueTextField.delegate = self
            cell.valueTextField.tag = indexPath.row
            cell.textLabel?.text = descriptionForType(alert)
            cell.textLabel?.accessibilityLabel = descriptionForType(alert)
            cell.valueTextField.accessibilityLabel = descriptionForType(alert)
            cell.valueTextField.placeholder = NSLocalizedString("1-100%", comment: "Percentage field placeholder")
            if let threshold = presenter.thresholdForType(alert), let value = threshold.threshold, let formattedValue = formatter.number(from: value)?.intValue {
                cell.valueTextField.text = "\(formattedValue)"
            }
            cell.valueTextField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: UIControl.Event.editingDidEnd)
            if indexPath == currentlySelectedIndexPath {
                cell.textLabel?.textColor = .named(.electric)
            } else {
                cell.textLabel?.textColor = .named(.textDarkest)
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == settingsSection {
            return NSLocalizedString("Alert me when:", comment: "Alert Section Header")
        }
        return nil
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: StudentSettingsHeaderView.self)) as? StudentSettingsHeaderView
            let student = studentObserver?.object
            header?.nameLabel.text = student.flatMap { Core.User.displayName($0.shortName, pronouns: $0.pronouns) }
            header?.avatarView.name = student?.name ?? ""
            header?.avatarView.url = student?.avatarURL
            return header
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 75
        }
        return 40
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deselectCurrentlySelected()

        let cell = tableView.cellForRow(at: indexPath)
        if let valueCell = cell as? IntCell {
            currentlySelectedIndexPath = indexPath
            cell?.textLabel?.textColor = .named(.electric)
            valueCell.valueTextField.becomeFirstResponder()
        }
    }

    func cellForTag<T: UITableViewCell>(_ tag: Int) -> T? {
        return tableView.cellForRow(at: IndexPath(row: tag, section: settingsSection)) as? T
    }

    func cellForType<T: UITableViewCell>(_ type: AlertThresholdType) -> T? {
        if let index = AlertThresholdType.validThresholdTypes.firstIndex(of: type) {
            return cellForTag(index)
        }
        return nil
    }

    @objc func switchCellDidToggleValue(_ sender: UISwitch) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: settingsSection)) as? SwitchCell, let type = cell.type else { return }

        activityIndicator.startAnimating()
        sender.isEnabled = false

        guard let threshold = presenter.thresholdForType(type) else {
            presenter.createAlert(value: nil, alertType: type)
            return
        }

        presenter.removeAlert(alertID: threshold.id)
        activityIndicator.stopAnimating()
        sender.isEnabled = true
    }

    func didUpdateValueOnTextField(_ type: AlertThresholdType, thresholdValue: String?) {
        if let threshold = presenter.thresholdForType(type), threshold.threshold == thresholdValue {
            return
        }

        if (thresholdValue ?? "").isEmpty && presenter.thresholdForType(type) == nil {
            return
        }

        activityIndicator.startAnimating()

        guard let threshold = presenter.thresholdForType(type) else {
            presenter.createAlert(value: thresholdValue, alertType: type)
            return
        }

        if let value = thresholdValue, !value.isEmpty {
            presenter.updateAlert(value: value, alertType: type, thresholdID: threshold.id)
        } else {
            presenter.removeAlert(alertID: threshold.id)
            activityIndicator.stopAnimating()
            deselectCurrentlySelected()
        }
    }

    func deselectCurrentlySelected() {
        view.endEditing(true)
        if let current = currentlySelectedIndexPath {
            let cell = tableView.cellForRow(at: current)
            cell?.textLabel?.textColor = .named(.textDarkest)
            currentlySelectedIndexPath = nil
        }
    }

    class IntCell: UITableViewCell {
        var valueTextField: UITextField
        var value: Int? {
            if let text = valueTextField.text, let val = Int(text) {
                return val
            }
            return nil
        }
        var type: AlertThresholdType?
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            valueTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 76, height: 21))
            valueTextField.keyboardType = .numberPad
            super.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: reuseIdentifier)
            accessoryView = valueTextField
            valueTextField.textAlignment = .right
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class SwitchCell: UITableViewCell {
        var toggle: UISwitch
        var type: AlertThresholdType?

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            toggle = UISwitch(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            accessoryView = toggle
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension StudentSettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let cell = tableView.cellForRow(at: IndexPath(row: textField.tag, section: settingsSection)) as? IntCell, let type = cell.type else { return true }
        let isValid = validateValueForRow(type)
        return isValid
    }

    func textFieldDidEndEditing(_ sender: UITextField) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(persistChangesToTextField(_:)), object: sender)
        perform(#selector(persistChangesToTextField(_:)), with: sender, afterDelay: 0.6)
    }

    @objc func persistChangesToTextField(_ textField: UITextField) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: textField.tag, section: settingsSection)) as? IntCell, let type = cell.type else { return }
        didUpdateValueOnTextField(type, thresholdValue: textField.text)
    }
}

extension AlertThresholdType {
    public static var validThresholdTypes: [AlertThresholdType] {
        return [
            .courseGradeHigh,
            .courseGradeLow,
            .assignmentMissing,
            .assignmentGradeHigh,
            .assignmentGradeLow,
            .courseAnnouncement,
            .institutionAnnouncement,
        ]
    }

    public var allowsThresholdValue: Bool {
        switch self {
        case .courseGradeLow:
            return true
        case .courseGradeHigh:
            return true
        case .assignmentMissing:
            return false
        case .assignmentGradeLow:
            return true
        case .assignmentGradeHigh:
            return true
        case .institutionAnnouncement:
            return false
        case .courseAnnouncement:
            return false
        }
    }
}

extension StudentSettingsViewController: StudentSettingsViewProtocol {
    func update() {
        tableView.reloadData()
        activityIndicator.stopAnimating()
        tableView.refreshControl?.endRefreshing()
    }

    func didUpdateAlert() {
        activityIndicator.stopAnimating()
        deselectCurrentlySelected()
    }
}
