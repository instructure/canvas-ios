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

import Foundation

public class CoreDatePicker: UIDatePicker {
    public weak var datePickerDelegate: DatePickerProtocol?
    public let toolbar = UIToolbar()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame.size.width = frame.width
        preferredDatePickerStyle = .wheels
        datePickerMode = .dateAndTime
        datepickerSetup()
        toolbarSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func toolbarSetup() {
        self.addSubview(toolbar)
        toolbar.sizeToFit()
        toolbar.frame.size.width = frame.width
        let done = UIBarButtonItem(title: NSLocalizedString("Done", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(didPickDate))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([cancel, space, done], animated: false)
    }

    private func datepickerSetup() {
        preferredDatePickerStyle = .wheels
        datePickerMode = .dateAndTime
    }

    public func dateFormatter(selectedDate: Date) -> String {
        return DateFormatter.localizedString(from: selectedDate, dateStyle: .medium, timeStyle: .short)
    }

    @objc func didPickDate() {
        datePickerDelegate?.didSelectDate(selectedDate: self.date)
    }

    @objc func cancelDatePicker() {
        datePickerDelegate?.didCancelSelection()
    }
}

public protocol DatePickerProtocol: AnyObject {
    func didSelectDate(selectedDate: Date)
    func didCancelSelection()
}

public extension DatePickerProtocol {
    func didCancelSelection() {}
}
