//
//  UIViewController+TriangleBackgroundView.swift
//  SoPretty
//
//  Created by Brandon Pluim on 2/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

public extension UIViewController {
    public func insertTriangleBackgroundView() -> TriangleBackgroundGradientView {
        let backgroundView = TriangleBackgroundGradientView(frame: CGRectZero)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(backgroundView, atIndex: 0)
        backgroundView.clipsToBounds = true
        let horizontalAccountsConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["subview": backgroundView])
        let verticalAccountsConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[subview]-0-|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: ["subview": backgroundView])
        self.view.addConstraints(horizontalAccountsConstraints)
        self.view.addConstraints(verticalAccountsConstraints)
        return backgroundView
    }
}