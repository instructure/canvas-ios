//
//  DetailsReminderCell.swift
//  Parent
//
//  Created by Ben Kraus on 3/1/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import SoLazy

class DetailsReminderCell: UITableViewCell {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var toggle: UISwitch!
    @IBOutlet var dateLabel: UILabel!

    @IBOutlet var bottomLabelConstraint: NSLayoutConstraint!
    private let expandedBottomConstraintValue: CGFloat = 46.0
    private let contractedBottomConstraintValue: CGFloat = 14.0

    var cellSizeUpdated: ()->() = { }
    var toggleAction: (on: Bool)->() = { _ in }

    static var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
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

    @IBAction func toggledReminder(sender: UISwitch) {
        toggleAction(on: sender.on)
    }

    override func prepareForReuse() {
        cellSizeUpdated = { }
    }

    func setExpanded(expanded: Bool) {
        if expanded {
            bottomLabelConstraint.constant = expandedBottomConstraintValue
        } else {
            bottomLabelConstraint.constant = contractedBottomConstraintValue
        }
    }
}
