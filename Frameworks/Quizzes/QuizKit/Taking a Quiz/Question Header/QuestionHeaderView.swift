//
//  QuestionHeaderView.swift
//  Quizzes
//
//  Created by Ben Kraus on 2/24/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import SoPretty

class QuestionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet private var flagButton: UIButton!
    @IBOutlet private var numberLabel: UILabel!
    
    var flagged: Bool {
        get {
            return flagButton?.selected ?? false
        } set {
            flagButton?.selected = newValue
            updateAccessibilityLabel()
        }
    }
    
    var questionNumber: Int = 0 {
        didSet {
            numberLabel?.text = "\(questionNumber)."
            updateAccessibilityLabel()
        }
    }
    
    var questionFlagged: ()->() = {}
    
    class var ReuseID: String {
        return "QuestionHeaderViewReuseID"
    }
    
    class var Nib: UINib {
        return UINib(nibName: "QuestionHeaderView", bundle: NSBundle(forClass: self.classForCoder()))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        flagButton?.tintColor = Brand.current().secondaryTintColor
        
        isAccessibilityElement = true
        accessibilityTraits |= UIAccessibilityTraitHeader
        accessibilityElements = []
        
        let toggleName = NSLocalizedString("Toggle Flag", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Toggle flag accessiblity action")
        let toggleFlagAction = UIAccessibilityCustomAction(name: toggleName, target: self, selector: #selector(flagAction(_:)))
        
        accessibilityCustomActions = [toggleFlagAction]
    }
    
    
    override func prepareForReuse() {
        numberLabel.text = ""
    }
    
    // MARK: Actions
    
    @IBAction func flagAction(button: UIButton?) {
        flagButton.selected = !flagButton.selected
        
        updateAccessibilityLabel()
        postFlagChangedA11yNotification()
        questionFlagged()
    }
}


// MARK: Accessibility
extension QuestionHeaderView {
    
    func updateAccessibilityLabel() {
        let question = NSLocalizedString("Question ", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "accessibility label for a quiz question")
        var label = question + "\(questionNumber)."
        
        if flagged {
            label += " " + NSLocalizedString("Flagged", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "State of the flagged question")
        }
        accessibilityLabel = label
    }
    
    func postFlagChangedA11yNotification() {
        let notification: String
        if flagged {
            notification = NSLocalizedString("Question \(questionNumber) Flagged", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "state for a question that has been flagged")
        } else {
            notification = NSLocalizedString("Question \(questionNumber) Unflagged", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "state for unflagged question")
        }
        
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, notification)
    }
}
