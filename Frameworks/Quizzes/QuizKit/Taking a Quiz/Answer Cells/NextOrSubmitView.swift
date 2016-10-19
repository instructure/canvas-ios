//
//  NextOrSubmitView.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 3/6/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import Cartography

class NextOrSubmitView: UIView {
    
    @IBOutlet var submitButton: UIButton!
    
    enum NextOrSubmit: Int {
        case Next, Submit
        
        var labelText: String {
            switch self {
            case .Next:
                return NSLocalizedString("Next", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Next button for advancing a quiz")
            case .Submit:
                return NSLocalizedString("Submit", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Submit button title")
            }
        }
    }
    
    var onNextOrSubmit: ()->() = {}
    
    func doNextOrSubmit(button: UIButton) {
        onNextOrSubmit()
    }
    
    class func createWithNextOrSubmit(nextOrSubmit: NextOrSubmit, target: AnyObject?, action: Selector) -> NextOrSubmitView {
        let nib = UINib(nibName: "NextOrSubmitView", bundle: NSBundle(forClass: NextOrSubmitView.classForCoder()))
        
        let me = nib.instantiateWithOwner(nil, options: nil).first as! NextOrSubmitView
        
        me.submitButton.setTitle(nextOrSubmit.labelText, forState: .Normal)
        me.submitButton.makeItBlue()
        me.submitButton.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        
        return me
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
