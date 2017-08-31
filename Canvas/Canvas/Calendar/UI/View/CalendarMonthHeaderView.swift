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
                self.dateLabel.textColor = currMonth ? currentMonthLabelTextColor : monthLabelTextColor
            }
        }
    }
    
    var monthLabelFont: UIFont = UIFont(name:"HelveticaNeue-Thin", size: 20.0)!
    var monthLabelTextColor = UIColor.black
    var currentMonthLabelTextColor = UIColor.calendarTintColor
    
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
        dateLabel.frame = self.bounds
    }
    
    func initialize() {
        monthLabelFont = isPad() ? UIFont(name:"HelveticaNeue-Thin", size: 32.0)! : UIFont(name:"HelveticaNeue-Thin", size: 20.0)!
        
        backgroundColor = UIColor.clear
        dateLabel.font = monthLabelFont
        dateLabel.isOpaque = false
        dateLabel.textAlignment = NSTextAlignment.center
        addSubview(dateLabel)
    }
    
    func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
}
