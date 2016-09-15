//
//  UIView+RoundCorners.swift
//  Keymaster
//
//  Created by Brandon Pluim on 1/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
}