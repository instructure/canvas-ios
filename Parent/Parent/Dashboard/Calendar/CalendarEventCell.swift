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

class CalendarEventCell: UITableViewCell {

    static let iconImageDiameter: CGFloat = 36.0
    static let iconSubtrator: CGFloat = 15.0
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var statusLabel: TokenLabelView!

    var highlightColor = UIColor.whiteColor()

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .None
        typeImageView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        typeImageView.layer.cornerRadius = CGRectGetHeight(typeImageView.frame)/2
        statusLabel.layer.cornerRadius = CGRectGetHeight(statusLabel.frame)/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentView.backgroundColor = selected ? highlightColor : UIColor.whiteColor()
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        contentView.backgroundColor = highlighted ? highlightColor : UIColor.whiteColor()
    }
    
}