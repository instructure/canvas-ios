//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import SoPretty
import AssignmentKit

open class CircularGradeView: UIView {
    open var viewRubricButtonPressedHandler: (() -> Void)!
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }()
    internal let grayBackground = CAShapeLayer.layerForCircleView(color: UIColor.prettyLightGray())
    internal let gradeLayer = CAShapeLayer.layerForCircleView(color: Brand.current().secondaryTintColor)
    
    internal lazy var gradeLabelOffsetConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: self.gradeLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -10)
        self.addConstraint(constraint)
        
        return constraint
    }()
    internal lazy var gradeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline).withSize(36)
        label.textColor = UIColor.darkText
        label.textAlignment = .center
        label.text = ""
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.333
        
        self.addSubview(label)
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        label.addConstraint(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 90))

        return label
    }()
    internal lazy var gradeDetailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.caption1).withSize(20)
        label.textColor = UIColor.darkGray
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.333
        
        self.addSubview(label)
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self.gradeLabel, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        label.addConstraint(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100))
        
        return label
    }()
    
    fileprivate (set) open var grade = GradeViewModel.none
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupCircleLayers()
        
        setGrade(.none, animated: false)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setupCircleLayers() {
        layer.addSublayer(grayBackground)
        layer.addSublayer(gradeLayer)
    }
    
    func viewRubricButtonPressed(_ sender: UIButton!) {
        guard viewRubricButtonPressedHandler != nil else { return }
        
        viewRubricButtonPressedHandler()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let center = CGPoint(x:bounds.midX, y: bounds.midY)
        grayBackground.position = center
        gradeLayer.position = center
        CATransaction.commit()
    }
    
    open func setGrade(_ grade: GradeViewModel, animated: Bool) {
        self.grade = grade
        
        grade.updateGradeView(self, animated: animated)
    }
    
    open func setupRubricButton(_ hasRubric: Bool, buttonPressHandler: @escaping () -> Void) {
        viewRubricButtonPressedHandler = buttonPressHandler
        
        if hasRubric {
            showRubricButton()
        }
    }
    
    open func showRubricButton() {
        let viewRubricButton = UIButton(type: UIButtonType.system) as UIButton
        viewRubricButton.translatesAutoresizingMaskIntoConstraints = false
        
        let localizedTitle = NSLocalizedString("View Rubric", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.AssignmentKit")!, value: "", comment: "Title for button to see rubric from assignment detail")
        
        viewRubricButton.setTitle(localizedTitle, for: UIControlState())
        viewRubricButton.addTarget(self, action: #selector(CircularGradeView.viewRubricButtonPressed(_:)), for: .touchUpInside)
        
        addSubview(viewRubricButton)
        addConstraint(NSLayoutConstraint(item: viewRubricButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: viewRubricButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
    }
}


