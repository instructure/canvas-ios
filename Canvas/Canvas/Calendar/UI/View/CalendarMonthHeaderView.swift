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

class CalendarMonthHeaderView: UICollectionReusableView {
    
    var dateLabel = UILabel()
    var date = CalendarDate()
    var currentMonth: Bool? {
        didSet {
            if let currMonth = currentMonth {
                self.dateLabel.textColor = currMonth ? UIColor.calendarTintColor : UIColor.black
            }
            
            sizeLabel()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sizeLabel()
    }
    
    func sizeLabel() {
        dateLabel.sizeToFit()
        dateLabel.frame = dateLabel.frame.clamp(self.frame.size, inset: 2.0)
        dateLabel.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
    }
    
    func initialize() {
        backgroundColor = UIColor.clear
        dateLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        dateLabel.isOpaque = false
        dateLabel.textAlignment = NSTextAlignment.center
        dateLabel.sizeToFit()
        addSubview(dateLabel)
    }
}
