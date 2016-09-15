//
//  BadgeView.swift
//  Parent
//
//  Created by Ben Kraus on 2/25/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

class BadgeView: UIView {
    private let minimumSize: CGFloat = 20.0
    private let padding: CGFloat = 5.0

    var badgeValue: Int = 0 {
        didSet {
            if badgeValue <= 0 {
                self.hidden = true
            } else {
                self.hidden = false
            }

            let string = formatter.stringFromNumber(NSNumber(integer: badgeValue))
            valueLabel.text = string

            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    private let valueLabel: UILabel = UILabel()
    private let formatter = NSNumberFormatter()

    init() {
        super.init(frame: CGRectZero)

        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true

        clipsToBounds = true
        hidden = true
        backgroundColor = UIColor.parentRedColor()

        valueLabel.textAlignment = .Center
        valueLabel.backgroundColor = UIColor.clearColor()
        valueLabel.textColor = UIColor.whiteColor()
        valueLabel.font = UIFont.boldSystemFontOfSize(12.0)
        addSubview(valueLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        valueLabel.sizeToFit()

        let badgeLabelWidth = CGRectGetWidth(valueLabel.frame)
        let badgeLabelHeight = CGRectGetHeight(valueLabel.frame)

        let height = max(minimumSize, badgeLabelHeight + padding)
        let width = max(height, badgeLabelWidth + (2 * padding))

        frame = CGRect(x: CGRectGetWidth(superview?.frame ?? CGRectZero) - (width / 2.0), y: -(height / 2.0), width: width, height: height)
        layer.cornerRadius = height / 2.0

        valueLabel.frame = CGRect(x: (width / 2.0) - (badgeLabelWidth / 2.0), y: (height / 2.0) - (badgeLabelHeight / 2.0), width: badgeLabelWidth, height: badgeLabelHeight)
    }
}