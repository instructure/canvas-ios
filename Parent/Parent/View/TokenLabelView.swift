//
//  TokenLabelView.swift
//  Parent
//
//  Created by Brandon Pluim on 3/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation

class TokenLabelView: UIView {
    
    private var horizontalConstraints: [NSLayoutConstraint] = []
    private var verticalConstraints: [NSLayoutConstraint] = []

    private let label = UILabel()

    var text = ""  {
        didSet {
            guard !text.isEmpty else {
                removeConstraints(horizontalConstraints)
                removeConstraints(verticalConstraints)

                horizontalConstraints = []
                verticalConstraints = []
                sizeToFit()
                return
            }

            label.text = text
            updateViewConstraints()
            sizeToFit()
        }
    }

    var insets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10) {
        didSet {
            updateViewConstraints()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = CGRectGetHeight(frame)/2
    }

    func setup() {
        clipsToBounds = true

        label.font = UIFont.systemFontOfSize(13.0)
        label.textColor = UIColor.whiteColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        updateViewConstraints()
    }

    func updateViewConstraints() {
        removeConstraints(horizontalConstraints)
        removeConstraints(verticalConstraints)

        horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leftMargin-[subview]-rightMargin-|", options: .DirectionLeadingToTrailing, metrics: ["leftMargin": insets.left, "rightMargin": insets.right], views: ["subview": label])
        verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-topMargin-[subview]-bottomMargin-|", options: .DirectionLeadingToTrailing, metrics: ["topMargin": insets.top, "bottomMargin": insets.bottom], views: ["subview": label])

        addConstraints(horizontalConstraints)
        addConstraints(verticalConstraints)
    }

}