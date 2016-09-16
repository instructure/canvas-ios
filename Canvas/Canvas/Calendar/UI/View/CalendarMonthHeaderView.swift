//
//  CalendarMonthHeader.swift
//  Calendar
//
//  Created by Brandon Pluim on 2/9/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
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
    var monthLabelTextColor = UIColor.blackColor()
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
        
        backgroundColor = UIColor.clearColor()
        dateLabel.font = monthLabelFont
        dateLabel.opaque = false
        dateLabel.textAlignment = NSTextAlignment.Center
        addSubview(dateLabel)
    }
    
    func isPad() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
    
}