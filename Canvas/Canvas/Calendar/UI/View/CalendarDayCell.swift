//
//  CalendarDayCell.swift
//  Calendar
//
//  Created by Brandon Pluim on 2/9/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

enum CalendarDayCellState {
    case Normal
    case Selected
    case Today
    case TodaySelected
    case Off
    case OffSelected
    case NotMonth
}

public class CalendarDayCell: UICollectionViewCell {
    var dateLabel = UILabel()
    var dateCircleImageView = UIImageView()
    var notThisMonth = true
    
    var date: CalendarDate?
    var cellState: CalendarDayCellState = CalendarDayCellState.Normal {
        didSet {
            updateCellState()
        }
    }
    
    var cellBackgroundColor = UIColor.whiteColor()

    // MARK: Style colors
    // Normal Case
    var normalLabelFont = UIFont.systemFontOfSize(18.0)
    var normalLabelTextColor = UIColor.blackColor()
    var normalCircleColor = UIColor.whiteColor()
    
    // Selected Case
    var selectedLabelFont = UIFont.systemFontOfSize(18.0)
    var selectedLabelTextColor = UIColor.whiteColor()
    var selectedCircleColor = UIColor.calendarHighlightTintColor
    
    // Today Case
    var todayLabelFont = UIFont.systemFontOfSize(18.0)
    var todayLabelTextColor = UIColor.calendarTintColor
    var todayCircleColor = UIColor.whiteColor()
    
    // Today Selected Case
    var todaySelectedLabelFont = UIFont.systemFontOfSize(18.0)
    var todaySelectedLabelTextColor = UIColor.whiteColor()
    var todaySelectedCircleColor = UIColor.calendarHighlightTintColor
    
    // Off Case
    var offLabelFont = UIFont.systemFontOfSize(18.0)
    var offLabelTextColor = UIColor.lightGrayColor()
    var offCircleColor = UIColor.whiteColor()
    
    // Off Selected Case
    var offSelectedLabelFont = UIFont.systemFontOfSize(18.0)
    var offSelectedLabelTextColor = UIColor.whiteColor()
    var offSelectedCircleColor = UIColor.calendarHighlightTintColor
    
    // Not Month Case
    var notMonthLabelFont = UIFont.systemFontOfSize(18.0)
    var notMonthLabelTextColor = UIColor.clearColor()
    var notMonthCircleColor = UIColor.clearColor()
    
    var colorsToIndicate: [UIColor]? {
        didSet {
            updateCircleViews()
        }
    }
    
    var circleBorderColor = UIColor.calendarDayCircleColor
    var circleBorderWidth: CGFloat = 2.0
    var circleRadius: CGFloat = 18.0
    var circleBorderAnimationDuration: NSTimeInterval = 0.5
    
    
    var smallCirclePopAnimationDuration: NSTimeInterval = 0.5
    var smallCirclePopAnimationDelay: NSTimeInterval = 0.25
    var maximumSmallCircles = 10
    var smallCircleDiameter: CGFloat = 7.0
    
    private var circleViews: [UIView] = [UIView]()
    private var circleBorderView = UIView()
    
    // MARK: init
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    func initialize() {
        self.backgroundColor = self.cellBackgroundColor
        
        self.addSubview(self.dateCircleImageView)
        self.addSubview(self.dateLabel)
        
        self.updateCellState()
        self.initializeCircleViews()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        dateLabel.frame = self.bounds
        dateLabel.textAlignment = NSTextAlignment.Center
        updateCircleViews()
        updateCellState()
    }
    
    func updateCellState() {
        switch self.cellState {
        case CalendarDayCellState.Normal:
            self.dateLabel.font = self.normalLabelFont
            self.dateLabel.textColor = self.normalLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.normalCircleColor, diameter: 60.0)
        case CalendarDayCellState.Selected:
            self.dateLabel.font = self.selectedLabelFont
            self.dateLabel.textColor = self.selectedLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.selectedCircleColor, diameter: 60.0)
        case CalendarDayCellState.Today:
            self.dateLabel.font = self.todayLabelFont
            self.dateLabel.textColor = self.todayLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.todayCircleColor, diameter: 60.0)
        case CalendarDayCellState.TodaySelected:
            self.dateLabel.font = self.todaySelectedLabelFont
            self.dateLabel.textColor = self.todaySelectedLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.todaySelectedCircleColor, diameter: 60.0)
        case CalendarDayCellState.Off:
            self.dateLabel.font = self.offLabelFont
            self.dateLabel.textColor = self.offLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.offCircleColor, diameter: 60.0)
        case CalendarDayCellState.OffSelected:
            self.dateLabel.font = self.offSelectedLabelFont
            self.dateLabel.textColor = self.offSelectedLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.offSelectedCircleColor, diameter: 60.0)
        case CalendarDayCellState.NotMonth:
            self.dateLabel.font = self.notMonthLabelFont
            self.dateLabel.textColor = self.notMonthLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.notMonthCircleColor, diameter: 60.0)
        }
    }
    
    func initializeCircleViews() {
        for view in circleViews {
            view.removeFromSuperview()
        }
        
        circleViews.removeAll(keepCapacity: false)
        
        if let _ = circleBorderView.superview {
            circleBorderView.removeFromSuperview()
        }
        // add one to the radius to make the border hit the middle of the circle
        let circleViewRadius = circleRadius + 1
        circleBorderView.frame = CGRectMake(0, 0, circleViewRadius * 2, circleViewRadius * 2)
        circleBorderView.layer.cornerRadius = circleViewRadius
        circleBorderView.layer.borderColor = circleBorderColor.CGColor
        circleBorderView.layer.borderWidth = circleBorderWidth
        circleBorderView.alpha = 0.0
        circleBorderView.center = dateLabel.center
        addSubview(circleBorderView)
        
        dateCircleImageView.frame = circleBorderView.frame
        
        let size = CGSizeMake(smallCircleDiameter, smallCircleDiameter)
        for index in 1...10 {
            let circleView = UIView(frame: CGRectMake(0, 0, size.width/2, size.height/2))
            circleView.layer.cornerRadius = size.width/2
            let percentage = Double(index) * M_PI/Double(maximumSmallCircles)
            let theta: Double = Double(2 * percentage)
            let xDelta: CGFloat = circleRadius * CGFloat(cos(theta))
            let yDelta: CGFloat = circleRadius * CGFloat(sin(theta))
            circleView.center = CGPointMake(dateLabel.center.x + xDelta, dateLabel.center.y + yDelta)
            circleView.backgroundColor = UIColor.lightGrayColor()
            circleView.alpha = 0.0
            addSubview(circleView)
            circleViews.append(circleView)
        }
    }
    
    func updateCircleViews() {
        circleBorderView.alpha = 0.0
        circleBorderView.center = dateLabel.center
        dateCircleImageView.center = circleBorderView.center
        
        if colorsToIndicate == nil || colorsToIndicate!.count == 0 {
            for circleView in circleViews {
                circleView.alpha = 0.0
            }
            return
        }
        
        let colors = colorsToIndicate!
        UIView.animateWithDuration(circleBorderAnimationDuration, animations: {
            self.circleBorderView.alpha = 1.0;
        })

        let size = CGSizeMake(smallCircleDiameter, smallCircleDiameter)
        for (index, circleView) in circleViews.enumerate() {
            let percentage = Double(index) * M_PI/Double(maximumSmallCircles)
            let theta: Double = Double(2 * percentage)
            let xDelta: CGFloat = circleRadius * CGFloat(cos(theta))
            let yDelta: CGFloat = circleRadius * CGFloat(sin(theta))
            circleView.center = CGPointMake(dateLabel.center.x + xDelta, dateLabel.center.y + yDelta)
            circleView.alpha = 0.0
            
            if index < colors.count {
                circleView.backgroundColor = colors[index]
//                UIView.animateWithDuration(smallCirclePopAnimationDuration, delay: (smallCirclePopAnimationDelay + (0.1 * Double(index))), usingSpringWithDamping: 0.3, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    circleView.alpha = 1.0
                    circleView.frame = CGRectMake(circleView.frame.origin.x, circleView.frame.origin.y, size.width, size.height)
                    circleView.center = CGPointMake(self.dateLabel.center.x + xDelta, self.dateLabel.center.y + yDelta)
//                    }, completion:nil);
            }
        }
    }
    
    func circleImageWithColor(color: UIColor, diameter: CGFloat) -> UIImage {
        let size = CGSizeMake(diameter, diameter)
        return UIImage.circleImage(frame: CGRectMake(0, 0, size.width, size.height), color: color, scale:2.0)
    }
}
