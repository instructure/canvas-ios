//
//  Adjustable.swift
//  CanvasCore
//
//  Created by Matt Sessions on 4/17/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation
import React

public class Adjustable: RCTView {
    public var onAccessibilityIncrement: RCTDirectEventBlock?
    public var onAccessibilityDecrement: RCTDirectEventBlock?
    
    public override func accessibilityIncrement() {
        if let onAccessibilityIncrement = self.onAccessibilityIncrement {
            onAccessibilityIncrement([:])
        }
    }
    
    public override func accessibilityDecrement() {
        if let onAccessibilityDecrement = self.onAccessibilityDecrement {
            onAccessibilityDecrement([:])
        }
    }
    
}
