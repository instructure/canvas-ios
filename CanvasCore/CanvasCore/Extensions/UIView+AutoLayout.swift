//
//  UIView+AutoLayout.swift
//  CanvasCore
//
//  Created by Garrett Richards on 1/10/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import UIKit

extension UIView {
    public func pinToAllSides(ofView: UIView?) {
        guard let view = ofView else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    public func pinToAllSidesOfSuperview() {
        pinToAllSides(ofView: superview)
    }
    
    public func centerInSuperview(xMultiplier: CGFloat = 1, yMultiplier: CGFloat = 1) {
        var yConstant:CGFloat = 0
        var xConstant:CGFloat = 0
        if(xMultiplier != 1) { xConstant = 1 }
        if(yMultiplier != 1) { yConstant = 1 }
        let y = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerY, multiplier: yMultiplier, constant: yConstant)
        let x = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: superview, attribute: NSLayoutAttribute.centerX, multiplier: xMultiplier, constant: xConstant)
        superview?.addConstraints([x,y])
    }
}
