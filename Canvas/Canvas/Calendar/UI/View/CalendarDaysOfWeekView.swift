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

class CalendarDaysOfWeekView : UIStackView {
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Calendar.current.locale
        return formatter
    }()
    
    fileprivate lazy var symbols: [String] = {
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) &&
            UIDevice.current.userInterfaceIdiom == .phone {
            return self.dateFormatter.veryShortStandaloneWeekdaySymbols
        }
        
        return self.dateFormatter.shortStandaloneWeekdaySymbols
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        backgroundColor = UIColor.calendarDaysOfWeekBackgroundColor
        self.distribution = .fillEqually
        self.axis = .horizontal
        self.spacing = 2.0
        initLabels()
    }
    
    func initLabels() {
        
        for (index, weekdaySymbol) in symbols.enumerated() {
            let weekdayLabel = UILabel()
            weekdayLabel.textAlignment = NSTextAlignment.center
            weekdayLabel.backgroundColor = UIColor.clear
            weekdayLabel.font = UIFont.preferredFont(forTextStyle: .title3).noLargerThan(32.0)
            weekdayLabel.text = weekdaySymbol
            weekdayLabel.adjustsFontSizeToFitWidth = true
            if index != 0 && index != 6 {
                weekdayLabel.textColor = UIColor.black
            } else {
                weekdayLabel.textColor = UIColor.calendarDayOffTextColor
            }
            addArrangedSubview(weekdayLabel)
        }
    }
}
