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

import Foundation

public class CreateTodoViewController: UIViewController, ErrorViewController {

    @IBOutlet weak var titleLabel: DynamicTextField!
    @IBOutlet weak var dateTitleLabel: DynamicLabel!
    @IBOutlet weak var dateTextField: DynamicTextField!
    @IBOutlet weak var selectDateButton: UIButton!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var courseTitleLabel: DynamicLabel!
    @IBOutlet weak var courseSelectionLabel: DynamicLabel!
    @IBOutlet weak var courseChevron: IconView!
    @IBOutlet weak var selectCourseButton: UIButton!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!

    let env = AppEnvironment.shared
    let datePicker = UIDatePicker()
    var createPlannerNote: Store<CreatePlannerNote>?
    var selectedDate: Date = Clock.now
    var selectedCourseName: String? {
        guard let c = selectedCourse else { return NSLocalizedString("None", bundle: .core, comment: "")  }
        return c.name
    }
    var selectedCourse: Course?
    var formattedDate: String {
        DateFormatter.localizedString(from: selectedDate, dateStyle: .medium, timeStyle: .short)
    }
    var plannables: Store<GetPlannables>?
    private var keyboardListener: KeyboardTransitioning!

    public static func create() -> CreateTodoViewController {
        let vc = loadFromStoryboard()
        return vc
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("New To Do", bundle: .core, comment: "")
        titleLabel.placeholder = NSLocalizedString("Title...", bundle: .core, comment: "")
        titleLabel.delegate = self
        titleLabel.accessibilityLabel = NSLocalizedString("Title", bundle: .core, comment: "")
        dateTitleLabel.text = NSLocalizedString("Date", bundle: .core, comment: "")
        dateTitleLabel.accessibilityElementsHidden = true
        descTextView.font = UIFont.scaledNamedFont(.regular16)
        descTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        descTextView.placeholder = NSLocalizedString("Description", bundle: .core, comment: "")
        descTextView.accessibilityLabel = NSLocalizedString("Description", bundle: .core, comment: "")
        dateTextField.text = formattedDate
        dateTextField.accessibilityElementsHidden = true
        selectDateButton.accessibilityLabel = NSLocalizedString("Date", bundle: .core, comment: "")
        courseSelectionLabel.text = selectedCourseName
        courseSelectionLabel.textColor = UIColor.textDark
        courseSelectionLabel.accessibilityElementsHidden = true
        courseTitleLabel.accessibilityElementsHidden = true
        courseTitleLabel.text = NSLocalizedString("Course (optional)", bundle: .core, comment: "")
        updateCourseAccessibilityLabel()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(actionCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", bundle: .core, comment: ""), style: .done, target: self, action: #selector(actionDone))
        keyboardListener = KeyboardTransitioning(view: view, space: scrollViewBottomConstraint)
    }

    @objc func actionDone() {
        let u = CreatePlannerNote(title: titleLabel.text, details: descTextView.text, todoDate: selectedDate, courseID: selectedCourse?.id)
        u.fetch(environment: env) { [weak self]  _, _, error in
            if let error = error {
                 self?.showError(error)
            } else {
                self?.refreshPlannables()
            }
        }
    }

    @objc func actionCancel() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func showDatePicker(_ sender: Any) {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .dateAndTime
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: NSLocalizedString("Done", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(didPickDate))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([cancel, space, done], animated: false)

        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
        dateTextField.becomeFirstResponder()
    }

    @objc func didPickDate() {
        dateTextField.resignFirstResponder()
        selectedDate = datePicker.date
        dateTextField.text = formattedDate
    }

    @objc func cancelDatePicker() {
        dateTextField.resignFirstResponder()
    }

    func refreshPlannables() {
        let u = GetPlannables(startDate: Clock.now.startOfDay(), endDate: Clock.now.startOfDay().addDays(1))
        plannables = env.subscribe(u, { [weak self] in self?.plannablesDidUpdate() })
        plannables?.refresh(force: true)
    }

    func plannablesDidUpdate() {
        if plannables?.pending == false {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func actionSelectCourse() {
        let vc = SelectCourseViewController()
        vc.delegate = self
        env.router.show(vc, from: self)
    }

    func updateCourseAccessibilityLabel() {
        let courseLabel = NSLocalizedString("Course (optional)", bundle: .core, comment: "")
        let courseName = selectedCourseName ?? NSLocalizedString("None", bundle: .core, comment: "")
        selectCourseButton.accessibilityLabel = courseLabel + ", " + courseName
    }
}

extension CreateTodoViewController: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension CreateTodoViewController: SelectCourseProtocol {
    func userDidSelect(course: Course) {
        selectedCourse = course
        courseSelectionLabel.text = selectedCourseName
        courseSelectionLabel.textColor = UIColor.textDarkest
        updateCourseAccessibilityLabel()
        env.router.pop(from: self)
    }

    func userDidUnselectCourse() {
        selectedCourse = nil
        courseSelectionLabel.text = selectedCourseName
        courseSelectionLabel.textColor = UIColor.textDark
        updateCourseAccessibilityLabel()
        env.router.pop(from: self)
    }
}

protocol SelectCourseProtocol: AnyObject {
    func userDidSelect(course: Course)
    func userDidUnselectCourse()
}

class SelectCourseViewController: UITableViewController {
    lazy var courses = AppEnvironment.shared.subscribe(GetCourses()) { [weak self] in
        self?.coursesDidUpdate()
    }
    weak var delegate: SelectCourseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Select Course", bundle: .core, comment: "")
        tableView.registerCell(RightDetailTableViewCell.self)
        tableView.separatorColor = .borderMedium
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        courses.exhaust()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Clear Course", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(clearCourse))
    }

    func coursesDidUpdate() {
        if courses.pending == false {
            tableView.reloadData()
        }
    }

    @objc func clearCourse() {
        delegate?.userDidUnselectCourse()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RightDetailTableViewCell = tableView.dequeue(for: indexPath)
        cell.textLabel?.text = courses[indexPath]?.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let c = courses[indexPath] else { return }
        delegate?.userDidSelect(course: c)
    }
}
