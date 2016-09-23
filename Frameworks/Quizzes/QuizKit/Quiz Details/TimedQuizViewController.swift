//
//  TimedQuizViewController.swift
//  Quizzes
//
//  Created by Ben Kraus on 3/5/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

class TimedQuizViewController: UIViewController {
    
    var minuteLimit: Int = 0 {
        didSet {
            timeLimitLabel?.text = NSLocalizedString("You have \(minuteLimit) minutes.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Shows time limit on a quiz")
        }
    }
    
    @IBOutlet var timeLimitLabel: UILabel?
}