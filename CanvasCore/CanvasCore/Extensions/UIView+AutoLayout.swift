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
}
