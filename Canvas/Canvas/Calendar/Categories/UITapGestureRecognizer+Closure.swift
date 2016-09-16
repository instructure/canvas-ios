//
//  UITapGestureRecognizer+Closure.swift
//  Calendar
//
//  Created by Brandon Pluim on 5/12/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

private var target = [Target]()

extension UITapGestureRecognizer {
    convenience init(trailingClosure closure: (() -> ())) {
        self.init()
        
        target.append(Target(closure))
        self.addTarget(target.last!, action: "invoke")
    }
}

private class Target {
    private var closure: (() -> ())
    
    init(_ closure:(() -> ())) {
        self.closure = closure
    }
    
    /* Note: Note sure why @IBAction is needed here */
    @IBAction func invoke() {
        closure()
    }
}