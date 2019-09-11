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

import UIKit
import CanvasCore

class DetailsReminderCell: UITableViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var toggle: UISwitch!
    @IBOutlet var dateLabel: UILabel!

    @IBOutlet var bottomLabelConstraint: NSLayoutConstraint!
    fileprivate let expandedBottomConstraintValue: CGFloat = 46.0
    fileprivate let contractedBottomConstraintValue: CGFloat = 14.0

    @objc var cellSizeUpdated: () -> Void = { }
    @objc var toggleAction: (_ on: Bool) -> Void = { _ in }

    @objc static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        // Because Xcode is being dumb and isn't picking it up from what it is set in the nib
        iconImageView.tintColor = UIColor(r: 180.0, g: 180.0, b: 180.0)

        dateLabel.text = ""
        dateLabel.accessibilityIdentifier = "reminder_date_label"
        toggle.accessibilityIdentifier = "reminder_toggle"
    }

    @IBAction func toggledReminder(_ sender: UISwitch) {
        toggleAction(sender.isOn)
    }

    override func prepareForReuse() {
        cellSizeUpdated = { }
    }

    @objc func setExpanded(_ expanded: Bool) {
        if expanded {
            bottomLabelConstraint.constant = expandedBottomConstraintValue
        } else {
            bottomLabelConstraint.constant = contractedBottomConstraintValue
        }
    }
}
