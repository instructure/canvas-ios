//
//  GradientView.swift
//  SoPretty
//
//  Created by Nathan Armstrong on 1/19/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

public class GradientView: UIView {
    public var colors: [UIColor] = [] {
        didSet {
            gradient.colors = colors.map { $0.cgColor }
        }
    }

    public var direction: (start: CGPoint, end: CGPoint) = (.zero, .zero) {
        didSet {
            gradient.startPoint = self.direction.start
            gradient.endPoint = self.direction.end
        }
    }

    fileprivate lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        self.layer.addSublayer(gradient)

        return gradient
    }()

    override public func layoutSubviews() {
        super.layoutSubviews()

        gradient.frame = bounds
    }
}
