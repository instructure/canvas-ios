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
    
    

import UIKit

class DetailsInfoCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var submissionLabel: TokenLabelView!

    @IBOutlet var submissionInfoVisibilityConstraint: NSLayoutConstraint!
    fileprivate let showingSubmissionInfoConstraintValue: CGFloat = 56.0
    fileprivate let hidingSubmissionInfoConstraintValue: CGFloat = 20.0

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.accessibilityIdentifier = "event_detail_title"
        submissionLabel.accessibilityIdentifier = "event_detail_submission"
    }

    func setShowsSubmissionInfo(_ showsInfo: Bool) {
        if showsInfo {
            submissionInfoVisibilityConstraint.constant = showingSubmissionInfoConstraintValue
            submissionLabel.isHidden = false
        } else {
            submissionInfoVisibilityConstraint.constant = hidingSubmissionInfoConstraintValue
            submissionLabel.isHidden = true
        }
    }
}
