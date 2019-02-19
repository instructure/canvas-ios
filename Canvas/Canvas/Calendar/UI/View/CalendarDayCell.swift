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


enum CalendarDayCellState {
    case normal
    case selected
    case today
    case todaySelected
    case off
    case offSelected
    case notMonth
}

open class CalendarDayCell: UICollectionViewCell {
    @objc static let dayOfTheMonthA11yFormatter: (Int)->String = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return { i in formatter.string(from: NSNumber(value: i))! }
    }()

    @objc var day: Int = 1 {
        didSet {
            dateLabel.text = "\(day)"
            dateLabel.sizeToFit()                
            dateLabel.frame = dateLabel.frame.clamp(self.frame.size, inset: 2.0)
            updateA11y()
        }
    }
    private var dateLabel = UILabel()
    @objc var dateCircleImageView = UIImageView()
    @objc var notThisMonth = true
    
    var date: CalendarDate?
    @objc var dayOfWeek: Int = 0 {
        didSet {
            if (day < 8 && dayOfWeek == 7) || dayOfWeek == 1 {
                // Mark the last day of the first week in the month as an accessibility button
                // Mark the first day of each week as an accessiblity button
                // In Switch Control mode, the combination of these two will draw a nice square around the entire month
                dateLabel.accessibilityTraits.insert(.button)
            }
        }
    }
    @objc var eventCount: Int = 0 {
        didSet {
            self.eventCountDot.isHidden = eventCount < 1
            if eventCount > 0 {
                dateLabel.accessibilityTraits.insert(.button)
            }
        }
    }
    var cellState: CalendarDayCellState = .normal {
        didSet {
            updateCellState()
        }
    }
    
    @objc var cellBackgroundColor = UIColor.white
    @objc let eventCountDot = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
    
    // MARK: init
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    @objc func initialize() {
        self.backgroundColor = self.cellBackgroundColor
        
        self.addSubview(self.dateCircleImageView)
        self.addSubview(self.dateLabel)
        
        dateLabel.font = UIFont.preferredFont(forTextStyle: .title3).noLargerThan(32.0)
        dateLabel.textAlignment = NSTextAlignment.center
        dateLabel.adjustsFontSizeToFitWidth = true
        
        self.updateCellState()
        
        eventCountDot.layer.cornerRadius = 4
        eventCountDot.backgroundColor = UIColor.calendarTintColor
        eventCountDot.isHidden = true
        self.addSubview(eventCountDot)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        updateCellState()
        dateLabel.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        eventCountDot.center = CGPoint(x: self.frame.width / 2, y: dateLabel.frame.maxY + 3)
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        eventCountDot.isHidden = true
        dateLabel.accessibilityTraits.remove(.button)
    }
    
    @objc func updateA11y() {
        dateLabel.accessibilityLabel = dateLabel.text
            .flatMap { Int($0) }
            .map(CalendarDayCell.dayOfTheMonthA11yFormatter)
    }
    
    @objc func updateCellState() {
        switch self.cellState {
        case .normal:
            self.dateLabel.textColor = UIColor.black
        case .selected:
            self.dateLabel.textColor = UIColor.contextPink()
        case .today:
            self.dateLabel.textColor = UIColor.calendarTintColor
        case .todaySelected:
            self.dateLabel.textColor = UIColor.white
        case .off:
            self.dateLabel.textColor = UIColor.calendarDayOffTextColor
        case .offSelected:
            self.dateLabel.textColor = UIColor.white
        case .notMonth:
            self.dateLabel.textColor = UIColor.clear
        }
        
        // turn it off as an a11y element
        if case .notMonth = cellState {
            self.dateLabel.isHidden = true
        } else {
            self.dateLabel.isHidden = false
        }
    }
}
