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

class CalendarDayListCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.contentView.backgroundColor = UIColor.calendarDayDetailBackgroundColor
    }
    
    @objc class var Nib: UINib {
        return UINib(nibName: "CalendarDayListCell", bundle: CalendarDayCell.bundle)
    }
    
    @objc class var ReuseID: String {
        return "CalendarDayListCell"
    }
}
