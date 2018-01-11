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
import CanvasCore

class CalendarDaysOfWeekView : UIView {
    let stack = UIStackView()
    
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
        fatalError("Not supported")
    }
    
    func initialize() {
        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .white
        borderView.layer.borderWidth = 1/UIScreen.main.scale
        borderView.layer.borderColor = UIColor.lightGray.cgColor
        addSubview(borderView)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .white
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.spacing = 2.0
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            borderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -1),
            borderView.topAnchor.constraint(equalTo: topAnchor, constant: -1),
            borderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 1),
            borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
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
            stack.addArrangedSubview(weekdayLabel)
        }
    }
    
}
