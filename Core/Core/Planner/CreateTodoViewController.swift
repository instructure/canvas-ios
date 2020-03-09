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
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var courseTitleLabel: DynamicLabel!
    @IBOutlet weak var courseSelectionLabel: DynamicLabel!
    @IBOutlet weak var courseChevron: IconView!
    @IBOutlet weak var selectCourseButton: UIButton!

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

    public static func create() -> CreateTodoViewController {
        let vc = loadFromStoryboard()
        return vc
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("New To Do", bundle: .core, comment: "")
        titleLabel.placeholder = NSLocalizedString("Title...", bundle: .core, comment: "")
        dateTitleLabel.text = NSLocalizedString("Date", bundle: .core, comment: "")
        if descTextView.responds(to: #selector(setter: UITextField.placeholder)) {  // without this check, it fails unit tests
            descTextView.setValue(NSLocalizedString("Description", bundle: .core, comment: ""), forKey: "placeholder")
        }
        descTextView.font = UIFont.scaledNamedFont(.regular16)
        dateTextField.text = formattedDate
        courseSelectionLabel.text = selectedCourseName
        courseSelectionLabel.textColor = UIColor.named(.textDark)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(actionCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(actionDone))
    }

    @objc func actionDone() {
        let u = CreatePlannerNote(title: titleLabel.text, details: descTextView.text, todoDate: selectedDate, courseID: selectedCourse?.id)
        u.fetch(environment: env) { [weak self]  _, _, error in
            if let error = error {
                 self?.showError(error)
            } else {
                 self?.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc func actionCancel() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func showDatePicker(_ sender: Any) {
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

    func createPlannerNoteDidUpdate() {
        if createPlannerNote?.pending == false && createPlannerNote?.error == nil {
            dismiss(animated: true, completion: nil)
        } else if let error = createPlannerNote?.error {
            showError(error)
        }
    }

    @IBAction func actionSelectCourse() {
        let vc = SelectCourseViewController()
        vc.delegate = self
        env.router.show(vc, from: self)
    }
}

extension CreateTodoViewController: SelectCourseProtocol {
    func userDidSelect(course: Course) {
        selectedCourse = course
        courseSelectionLabel.text = selectedCourseName
        courseSelectionLabel.textColor = UIColor.named(.textDarkest)
        env.router.pop(from: self)
    }

    func userDidUnselectCourse() {
        selectedCourse = nil
        courseSelectionLabel.text = selectedCourseName
        courseSelectionLabel.textColor = UIColor.named(.textDark)
        env.router.pop(from: self)
    }
}

protocol SelectCourseProtocol: class {
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
        tableView.registerCell(UITableViewCell.self)
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
        let cell: UITableViewCell = tableView.dequeue(for: indexPath)
        cell.textLabel?.text = courses[indexPath]?.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let c = courses[indexPath] else { return }
        delegate?.userDidSelect(course: c)
    }
}
