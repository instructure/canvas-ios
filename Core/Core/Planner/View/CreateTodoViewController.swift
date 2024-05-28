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
import Foundation
import UIKit
import SwiftUI

public class CreateTodoViewController: ScreenViewTrackableViewController, ErrorViewController {

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
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/calendar/new")

    var createPlannerNote: Store<CreatePlannerNote>?
    var selectedDate: Date? {
        didSet {
            self.dateTextField.text = selectedDate?.dateTimeString
        }
    }
    var selectedCourseName: String? {
        guard let c = selectedCourse else { return String(localized: "None", bundle: .core)  }
        return c.name
    }
    var selectedCourse: Course?
    var plannables: Store<GetPlannables>?
    var completion: (() -> Void)?
    private var keyboardListener: KeyboardTransitioning!

    public static func create(completion: @escaping () -> Void) -> CreateTodoViewController {
        let vc = loadFromStoryboard()
        vc.completion = completion
        return vc
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = String(localized: "New To Do", bundle: .core)
        titleLabel.placeholder = String(localized: "Title...", bundle: .core)
        titleLabel.delegate = self
        titleLabel.accessibilityLabel = String(localized: "Title", bundle: .core)
        dateTitleLabel.text = String(localized: "Date", bundle: .core)
        dateTitleLabel.accessibilityElementsHidden = true
        descTextView.font(.scaledNamedFont(.regular16), lineHeight: .body)
        descTextView.textColor = UIColor.textDarkest
        descTextView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        descTextView.placeholder = String(localized: "Description", bundle: .core)
        descTextView.accessibilityLabel = String(localized: "Description", bundle: .core)
        dateTextField.text = selectedDate?.dateTimeString
        dateTextField.accessibilityElementsHidden = true
        dateTextField.textColor = .textDark
        selectDateButton.accessibilityLabel = String(localized: "Date", bundle: .core)
        courseSelectionLabel.text = selectedCourseName
        courseSelectionLabel.textColor = UIColor.textDark
        courseSelectionLabel.accessibilityElementsHidden = true
        courseTitleLabel.accessibilityElementsHidden = true
        courseTitleLabel.text = String(localized: "Course (optional)", bundle: .core)
        updateCourseAccessibilityLabel()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: String(localized: "Cancel", bundle: .core), style: .plain, target: self, action: #selector(actionCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "Done", bundle: .core), style: .done, target: self, action: #selector(actionDone))
        keyboardListener = KeyboardTransitioning(view: view, space: scrollViewBottomConstraint)
    }

    @objc func actionDone() {
        let u = CreatePlannerNote(title: titleLabel.text, details: descTextView.text, todoDate: selectedDate ?? Clock.now, courseID: selectedCourse?.id)
        u.fetch(environment: env) { [weak self]  _, _, error in performUIUpdate {
            if let error = error {
                self?.showError(error)
            } else {
                self?.completion?()
                self?.dismiss(animated: true, completion: nil)
            }
        }}
    }

    @objc func actionCancel() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func showDatePicker(_ sender: Any) {
        let dateBinding = Binding(get: { self.selectedDate },
                                  set: { self.selectedDate = $0 })
        CoreDatePicker.showDatePicker(for: dateBinding, from: self)
    }

    @IBAction func actionSelectCourse() {
        let vc = SelectCourseViewController()
        vc.delegate = self
        env.router.show(vc, from: self)
    }

    func updateCourseAccessibilityLabel() {
        let courseLabel = String(localized: "Course (optional)", bundle: .core)
        let courseName = selectedCourseName ?? String(localized: "None", bundle: .core)
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
        title = String(localized: "Select Course", bundle: .core)
        tableView.registerCell(RightDetailTableViewCell.self)
        tableView.separatorColor = .borderMedium
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        courses.exhaust()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "Clear Course", bundle: .core), style: .plain, target: self, action: #selector(clearCourse))
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
