//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation
import CanvasCore

class DatePickerViewController: UIViewController {

    let datePicker: UIDatePicker = UIDatePicker()
    let datePickerHeight: CGFloat = 216.0

    var cancelAction: ()->() = { }
    var doneAction: (Date)->() = { _ in }

    convenience init() {
        self.init(nibName: nil, bundle: nil)

        let width: CGFloat = min(UIScreen.main.bounds.size.width - 30.0, 400.0)
        preferredContentSize = CGSize(width: width, height: datePickerHeight)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        datePicker.minimumDate = Date() + 1.minutesComponents
        datePicker.maximumDate = Date() + 1.yearsComponents
        datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        view.addSubview(datePicker)

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.accessibilityIdentifier = "assignment_date_picker"

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[picker]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["picker": datePicker]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[top][picker(216)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["top": self.topLayoutGuide, "picker": datePicker]))

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DatePickerViewController.cancel(_:)))
        cancelButton.accessibilityIdentifier = "date_picker_cancel_button"

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DatePickerViewController.done(_:)))
        doneButton.accessibilityIdentifier = "date_picker_done_button"

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    func cancel(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: { [unowned self] _ in
            self.cancelAction()
        })
    }

    func done(_ button: UIBarButtonItem) {
        dismiss(animated: true, completion: { [unowned self] _ in
            self.doneAction(self.datePicker.date)
        })
    }
}
