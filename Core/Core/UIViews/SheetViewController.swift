//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import CloudKit

public class SheetViewController: UIViewController, UISheetPresentationControllerDelegate
{
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    public weak var datePickerDelegate: DatePickerProtocol?
    var finished = false

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2, animations: {
            self.fadeView.alpha = 0.5
        })
     }

    public override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.title = "Cancel"
        cancelButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular17),
            NSAttributedString.Key.foregroundColor: Brand.shared.primary],
        for: .normal)
        doneButton.title = "Done"
        doneButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular17),
            NSAttributedString.Key.foregroundColor: Brand.shared.primary],
        for: .normal)
        datePicker.preferredDatePickerStyle = .wheels
    }

    @IBAction func didPressCancel(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.fadeView.alpha = 0
        }, completion: { _ in
            self.datePickerDelegate?.didCancelSelection()
            self.dismiss(animated: true)
        })
    }

    @IBAction func didPressDone(_ sender: Any) {
        viewWillDisappear(true)
        datePickerDelegate?.didSelectDate(selectedDate: datePicker.date)
        self.dismiss(animated: true)
    }
}
