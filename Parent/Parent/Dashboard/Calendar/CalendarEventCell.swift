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

class CalendarEventCell: UITableViewCell {

    @objc static let iconImageDiameter: CGFloat = 36.0
    @objc static let iconSubtrator: CGFloat = 15.0
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var statusLabel: TokenLabelView!

    @objc var highlightColor = UIColor.white

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        typeImageView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        typeImageView.layer.cornerRadius = typeImageView.frame.height/2
        statusLabel.layer.cornerRadius = statusLabel.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        contentView.backgroundColor = selected ? highlightColor : UIColor.white
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        contentView.backgroundColor = highlighted ? highlightColor : UIColor.white
    }
    
}
