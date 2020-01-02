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
import CanvasCore

class CalendarDaysOfWeekView : UIView {
    @objc let stack = UIStackView()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Calendar.current.locale
        return formatter
    }()
    
    fileprivate lazy var symbols: [String] = {
        return dateFormatter.shortStandaloneWeekdaySymbols
    }()

    lazy var a11ySymbols: [String] = {
        return dateFormatter.standaloneWeekdaySymbols
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("Not supported")
    }
    
    @objc func initialize() {
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
    
    @objc func initLabels() {
        for (index, weekdaySymbol) in symbols.enumerated() {
            let weekdayLabel = UILabel()
            weekdayLabel.textAlignment = NSTextAlignment.center
            weekdayLabel.backgroundColor = UIColor.clear
            weekdayLabel.font = UIFont.preferredFont(forTextStyle: .title3).noLargerThan(32.0)
            weekdayLabel.text = weekdaySymbol
            weekdayLabel.accessibilityLabel = a11ySymbols[index]
            weekdayLabel.adjustsFontSizeToFitWidth = true
            if index != 0 && index != 6 {
                weekdayLabel.textColor = UIColor.black
            } else {
                weekdayLabel.textColor = UIColor.calendarDayOffTextColor
            }
            stack.addArrangedSubview(weekdayLabel)
            setNeedsLayout()
        }
    }
    
}
