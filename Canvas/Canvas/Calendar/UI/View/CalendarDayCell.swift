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
    static let dayOfTheMonthA11yFormatter: (Int)->String = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return { i in formatter.string(from: NSNumber(value: i))! }
    }()

    var day: Int = 1 {
        didSet {
            dateLabel.text = "\(day)"
            updateA11y()
        }
    }
    private var dateLabel = UILabel()
    var dateCircleImageView = UIImageView()
    var notThisMonth = true
    
    var date: CalendarDate?
    var cellState: CalendarDayCellState = .normal {
        didSet {
            updateCellState()
        }
    }
    
    var cellBackgroundColor = UIColor.white

    // MARK: Style colors
    // Normal Case
    var normalLabelFont = UIFont.systemFont(ofSize: 18.0)
    var normalLabelTextColor = UIColor.black
    var normalCircleColor = UIColor.white
    
    // Selected Case
    var selectedLabelFont = UIFont.systemFont(ofSize: 18.0)
    var selectedLabelTextColor = UIColor.white
    var selectedCircleColor = UIColor.calendarHighlightTintColor
    
    // Today Case
    var todayLabelFont = UIFont.systemFont(ofSize: 18.0)
    var todayLabelTextColor = UIColor.calendarTintColor
    var todayCircleColor = UIColor.white
    
    // Today Selected Case
    var todaySelectedLabelFont = UIFont.systemFont(ofSize: 18.0)
    var todaySelectedLabelTextColor = UIColor.white
    var todaySelectedCircleColor = UIColor.calendarHighlightTintColor
    
    // Off Case
    var offLabelFont = UIFont.systemFont(ofSize: 18.0)
    var offLabelTextColor = UIColor.lightGray
    var offCircleColor = UIColor.white
    
    // Off Selected Case
    var offSelectedLabelFont = UIFont.systemFont(ofSize: 18.0)
    var offSelectedLabelTextColor = UIColor.white
    var offSelectedCircleColor = UIColor.calendarHighlightTintColor
    
    // Not Month Case
    var notMonthLabelFont = UIFont.systemFont(ofSize: 18.0)
    var notMonthLabelTextColor = UIColor.clear
    var notMonthCircleColor = UIColor.clear
    
    var colorsToIndicate: [UIColor]? {
        didSet {
            updateCircleViews()
        }
    }
    
    var circleBorderColor = UIColor.calendarDayCircleColor
    var circleBorderWidth: CGFloat = 2.0
    var circleRadius: CGFloat = 18.0
    var circleBorderAnimationDuration: TimeInterval = 0.5
    
    
    var smallCirclePopAnimationDuration: TimeInterval = 0.5
    var smallCirclePopAnimationDelay: TimeInterval = 0.25
    var maximumSmallCircles = 10
    var smallCircleDiameter: CGFloat = 7.0
    
    fileprivate var circleViews: [UIView] = [UIView]()
    fileprivate var circleBorderView = UIView()
    
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
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        dateLabel.frame = self.bounds
        dateLabel.textAlignment = NSTextAlignment.center
        updateCircleViews()
        updateCellState()
    }
    
    func updateA11y() {
        dateLabel.accessibilityLabel = dateLabel.text
            .flatMap { Int($0) }
            .map(CalendarDayCell.dayOfTheMonthA11yFormatter)
    }
    
    func updateCellState() {
        switch self.cellState {
        case .normal:
            self.dateLabel.font = self.normalLabelFont
            self.dateLabel.textColor = self.normalLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.normalCircleColor, diameter: 60.0)
        case .selected:
            self.dateLabel.font = self.selectedLabelFont
            self.dateLabel.textColor = self.selectedLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.selectedCircleColor, diameter: 60.0)
        case .today:
            self.dateLabel.font = self.todayLabelFont
            self.dateLabel.textColor = self.todayLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.todayCircleColor, diameter: 60.0)
        case .todaySelected:
            self.dateLabel.font = self.todaySelectedLabelFont
            self.dateLabel.textColor = self.todaySelectedLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.todaySelectedCircleColor, diameter: 60.0)
        case .off:
            self.dateLabel.font = self.offLabelFont
            self.dateLabel.textColor = self.offLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.offCircleColor, diameter: 60.0)
        case .offSelected:
            self.dateLabel.font = self.offSelectedLabelFont
            self.dateLabel.textColor = self.offSelectedLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.offSelectedCircleColor, diameter: 60.0)
        case .notMonth:
            self.dateLabel.font = self.notMonthLabelFont
            self.dateLabel.textColor = self.notMonthLabelTextColor
            self.dateCircleImageView.image = self.circleImageWithColor(self.notMonthCircleColor, diameter: 60.0)
        }
        
        // turn it off as an a11y element
        if case .notMonth = cellState {
            self.dateLabel.isHidden = true
        } else {
            self.dateLabel.isHidden = false
        }
    }
    
    func initializeCircleViews() {
        for view in circleViews {
            view.removeFromSuperview()
        }
        
        circleViews.removeAll(keepingCapacity: false)
        
        if let _ = circleBorderView.superview {
            circleBorderView.removeFromSuperview()
        }
        // add one to the radius to make the border hit the middle of the circle
        let circleViewRadius = circleRadius + 1
        circleBorderView.frame = CGRect(x: 0, y: 0, width: circleViewRadius * 2, height: circleViewRadius * 2)
        circleBorderView.layer.cornerRadius = circleViewRadius
        circleBorderView.layer.borderColor = circleBorderColor.cgColor
        circleBorderView.layer.borderWidth = circleBorderWidth
        circleBorderView.alpha = 0.0
        circleBorderView.center = dateLabel.center
        addSubview(circleBorderView)
        
        dateCircleImageView.frame = circleBorderView.frame
        
        let size = CGSize(width: smallCircleDiameter, height: smallCircleDiameter)
        for index in 1...10 {
            let circleView = UIView(frame: CGRect(x: 0, y: 0, width: size.width/2, height: size.height/2))
            circleView.layer.cornerRadius = size.width/2
            let percentage = Double(index) * M_PI/Double(maximumSmallCircles)
            let theta: Double = Double(2 * percentage)
            let xDelta: CGFloat = circleRadius * CGFloat(cos(theta))
            let yDelta: CGFloat = circleRadius * CGFloat(sin(theta))
            circleView.center = CGPoint(x: dateLabel.center.x + xDelta, y: dateLabel.center.y + yDelta)
            circleView.backgroundColor = UIColor.lightGray
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
        UIView.animate(withDuration: circleBorderAnimationDuration, animations: {
            self.circleBorderView.alpha = 1.0;
        })

        let size = CGSize(width: smallCircleDiameter, height: smallCircleDiameter)
        for (index, circleView) in circleViews.enumerated() {
            let percentage = Double(index) * M_PI/Double(maximumSmallCircles)
            let theta: Double = Double(2 * percentage)
            let xDelta: CGFloat = circleRadius * CGFloat(cos(theta))
            let yDelta: CGFloat = circleRadius * CGFloat(sin(theta))
            circleView.center = CGPoint(x: dateLabel.center.x + xDelta, y: dateLabel.center.y + yDelta)
            circleView.alpha = 0.0
            
            if index < colors.count {
                circleView.backgroundColor = colors[index]
//                UIView.animateWithDuration(smallCirclePopAnimationDuration, delay: (smallCirclePopAnimationDelay + (0.1 * Double(index))), usingSpringWithDamping: 0.3, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    circleView.alpha = 1.0
                    circleView.frame = CGRect(x: circleView.frame.origin.x, y: circleView.frame.origin.y, width: size.width, height: size.height)
                    circleView.center = CGPoint(x: self.dateLabel.center.x + xDelta, y: self.dateLabel.center.y + yDelta)
//                    }, completion:nil);
            }
        }
    }
    
    func circleImageWithColor(_ color: UIColor, diameter: CGFloat) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        return UIImage.circleImage(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height), color: color, scale:2.0)
    }
}
