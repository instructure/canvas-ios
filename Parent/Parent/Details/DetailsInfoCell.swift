//
//  DetailsInfoCell.swift
//  Parent
//
//  Created by Ben Kraus on 3/2/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

class DetailsInfoCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var submissionLabel: TokenLabelView!

    @IBOutlet var submissionInfoVisibilityConstraint: NSLayoutConstraint!
    private let showingSubmissionInfoConstraintValue: CGFloat = 56.0
    private let hidingSubmissionInfoConstraintValue: CGFloat = 20.0

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.accessibilityIdentifier = "event_detail_title"
        submissionLabel.accessibilityIdentifier = "event_detail_submission"
    }

    func setShowsSubmissionInfo(showsInfo: Bool) {
        if showsInfo {
            submissionInfoVisibilityConstraint.constant = showingSubmissionInfoConstraintValue
            submissionLabel.hidden = false
        } else {
            submissionInfoVisibilityConstraint.constant = hidingSubmissionInfoConstraintValue
            submissionLabel.hidden = true
        }
    }
}
