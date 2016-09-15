//
//  TableSectionHeaderView.swift
//  Parent
//
//  Created by Brandon Pluim on 3/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation

class TableSectionHeaderView: UIView {
    private let label = UILabel()

    private var horizontalConstraints: [NSLayoutConstraint] = []
    private var verticalConstraints: [NSLayoutConstraint] = []

    var text = "" {
        didSet {
            label.text = text
            accessibilityLabel = text
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    func setup() {
        backgroundColor = UIColor(r: 232, g: 232, b: 232)

        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        label.font = UIFont.systemFontOfSize(13.0)
        updateViewConstraints()

        isAccessibilityElement = true
    }

    func updateViewConstraints() {
        removeConstraints(horizontalConstraints)
        removeConstraints(verticalConstraints)

        horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[subview]-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": label])
        verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[subview]-|", options: .DirectionLeadingToTrailing, metrics: nil, views: ["subview": label])

        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
    }
}