//
//  WhizzyNeverScrollingTextView.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 3/3/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit


class NeverScrollingTextView: UITextView {
    
    convenience init() {
        self.init(frame: CGRectZero, textContainer: nil)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        clipsToBounds = false
        scrollEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var bounds: CGRect {
        set {
            var myBounds = newValue
            myBounds.origin = CGPointZero
            super.bounds = myBounds
        }
        get {
            return super.bounds
        }
    }
}

