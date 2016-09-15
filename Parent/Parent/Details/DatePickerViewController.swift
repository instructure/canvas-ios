//
//  DatePickerViewController.swift
//  Parent
//
//  Created by Ben Kraus on 3/16/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import SoLazy

class DatePickerViewController: UIViewController {

    let datePicker: UIDatePicker = UIDatePicker()
    let datePickerHeight: CGFloat = 216.0

    var cancelAction: ()->() = { }
    var doneAction: (NSDate)->() = { _ in }

    convenience init() {
        self.init(nibName: nil, bundle: nil)

        let width: CGFloat = min(UIScreen.mainScreen().bounds.size.width - 30.0, 400.0)
        preferredContentSize = CGSize(width: width, height: datePickerHeight)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()

        datePicker.minimumDate = NSDate() + 1.minutesComponents
        datePicker.maximumDate = NSDate() + 1.yearsComponents
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        view.addSubview(datePicker)

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.accessibilityIdentifier = "assignment_date_picker"

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[picker]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["picker": datePicker]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[top][picker(216)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["top": self.topLayoutGuide, "picker": datePicker]))

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(DatePickerViewController.cancel(_:)))
        cancelButton.accessibilityIdentifier = "date_picker_cancel_button"

        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(DatePickerViewController.done(_:)))
        doneButton.accessibilityIdentifier = "date_picker_done_button"

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    func cancel(button: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: { [unowned self] _ in
            self.cancelAction()
        })
    }

    func done(button: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: { [unowned self] _ in
            self.doneAction(self.datePicker.date)
        })
    }
}