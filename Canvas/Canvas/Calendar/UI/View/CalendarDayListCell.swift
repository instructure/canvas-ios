//
//  CalendarDayListCell.swift
//  Calendar
//
//  Created by Brandon Pluim on 3/12/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

class CalendarDayListCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.contentView.backgroundColor = UIColor.calendarDayDetailBackgroundColor
    }
    
    class var Nib: UINib {
        return UINib(nibName: "CalendarDayListCell", bundle: CalendarDayCell.bundle)
    }
    
    class var ReuseID: String {
        return "CalendarDayListCell"
    }
}