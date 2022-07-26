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

import SwiftUI

public class SheetViewController: UIViewController, UISheetPresentationControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    public weak var datePickerDelegate: DatePickerProtocol?
    let attributes = [NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular17), NSAttributedString.Key.foregroundColor: Brand.shared.primary]

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2, animations: {
            self.fadeView.alpha = 0.5
            self.cancelButton.customView?.isHidden = false
            self.doneButton.customView?.isHidden = false
            self.datePicker.isHidden = false
            self.view.isHidden = false
        })
     }

    public override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.title = NSLocalizedString("Cancel", bundle: .core, comment: "")
        cancelButton.setTitleTextAttributes(attributes, for: .normal)
        cancelButton.customView?.isHidden = true
        doneButton.title = NSLocalizedString("Done", bundle: .core, comment: "")
        doneButton.setTitleTextAttributes(attributes, for: .normal)
        doneButton.customView?.isHidden = true
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.isHidden = true
        view.isHidden = true
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first
        if touch?.view != self.view {
            self.dismiss(animated: true, completion: nil)
        }
    }

    public static func create() -> SheetViewController {
        let vc = loadFromStoryboard()
        return vc
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
