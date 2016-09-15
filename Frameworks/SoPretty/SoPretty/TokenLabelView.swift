//
//  TokenLabelView.swift
//  Parent
//
//  Created by Brandon Pluim on 3/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import SoLazy
import Result

public class TokenLabelView: UIView {
    
    private var horizontalConstraints: [NSLayoutConstraint] = []
    private var verticalConstraints: [NSLayoutConstraint] = []
    
    private let label = UILabel()
    
    public var text = MutableProperty("")
    
    var insets = UIEdgeInsets(top: 0, left: 10, bottom: 1, right: 10) {
        didSet {
            updateViewConstraints()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = CGRectGetHeight(frame)/2
    }
    
    func setup() {
        clipsToBounds = true
        
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        label.textColor = UIColor.whiteColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        label.rac_text <~ text
        label.rac_text.signal.observeNext { [weak self] text in
            self?.updateViewConstraints()
            self?.sizeToFit()
        }
        
        updateViewConstraints()
    }
    
    func updateViewConstraints() {
        removeConstraints(horizontalConstraints)
        removeConstraints(verticalConstraints)
        
        if label.text == nil || label.text!.isEmpty {
            horizontalConstraints = []
            verticalConstraints = []
            sizeToFit()
            return
        }
        
        horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leftMargin-[subview]-rightMargin-|", options: .DirectionLeadingToTrailing, metrics: ["leftMargin": insets.left, "rightMargin": insets.right], views: ["subview": label])
        verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-topMargin-[subview]-bottomMargin-|", options: .DirectionLeadingToTrailing, metrics: ["topMargin": insets.top, "bottomMargin": insets.bottom], views: ["subview": label])
        
        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
    }
    
}










