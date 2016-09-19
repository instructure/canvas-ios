//
//  CircularGradeView.swift
//  SoPretty
//
//  Created by Derrick Hathaway on 11/23/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit
import SoPretty
import AssignmentKit

public class CircularGradeView: UIView {
    public var viewRubricButtonPressedHandler: (() -> Void)!
    
    static let numberFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    internal let grayBackground = CAShapeLayer.layerForCircleView(color: UIColor.prettyLightGray())
    internal let gradeLayer = CAShapeLayer.layerForCircleView(color: Brand.current().secondaryTintColor)
    
    internal lazy var gradeLabelOffsetConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: self.gradeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: -10)
        self.addConstraint(constraint)
        
        return constraint
    }()
    internal lazy var gradeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline).fontWithSize(36)
        label.textColor = UIColor.darkTextColor()
        label.textAlignment = .Center
        label.text = ""
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.333
        
        self.addSubview(label)
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        label.addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 90))

        return label
    }()
    internal lazy var gradeDetailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1).fontWithSize(20)
        label.textColor = UIColor.darkGrayColor()
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.333
        
        self.addSubview(label)
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: self.gradeLabel, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        label.addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        
        return label
    }()
    
    private (set) public var grade = GradeViewModel.None
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupCircleLayers()
        
        setGrade(.None, animated: false)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupCircleLayers() {
        layer.addSublayer(grayBackground)
        layer.addSublayer(gradeLayer)
    }
    
    func viewRubricButtonPressed(sender: UIButton!) {
        guard viewRubricButtonPressedHandler != nil else { return }
        
        viewRubricButtonPressedHandler()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let center = CGPoint(x:CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
        grayBackground.position = center
        gradeLayer.position = center
        CATransaction.commit()
    }
    
    public func setGrade(grade: GradeViewModel, animated: Bool) {
        self.grade = grade
        
        grade.updateGradeView(self, animated: animated)
    }
    
    public func setupRubricButton(hasRubric: Bool, buttonPressHandler: () -> Void) {
        viewRubricButtonPressedHandler = buttonPressHandler
        
        if hasRubric {
            showRubricButton()
        }
    }
    
    public func showRubricButton() {
        let viewRubricButton = UIButton(type: UIButtonType.System) as UIButton
        viewRubricButton.translatesAutoresizingMaskIntoConstraints = false
        
        let localizedTitle = NSLocalizedString("View Rubric", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Title for button to see rubric from assignment detail")
        
        viewRubricButton.setTitle(localizedTitle, forState: .Normal)
        viewRubricButton.addTarget(self, action: #selector(CircularGradeView.viewRubricButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        addSubview(viewRubricButton)
        addConstraint(NSLayoutConstraint(item: viewRubricButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: viewRubricButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
    }
}


