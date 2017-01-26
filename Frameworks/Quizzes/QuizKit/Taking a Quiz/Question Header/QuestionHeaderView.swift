//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import SoPretty

class QuestionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet fileprivate var flagButton: UIButton!
    @IBOutlet fileprivate var numberLabel: UILabel!

    static var questionNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    var flagged: Bool {
        get {
            return flagButton?.isSelected ?? false
        } set {
            flagButton?.isSelected = newValue
            updateAccessibilityLabel()
        }
    }
    
    var questionNumber: Int? {
        didSet {
            if let questionNumber = questionNumber {
                numberLabel?.text = String(format: NSLocalizedString("%@.", comment: "Question number in a quiz"), QuestionHeaderView.questionNumberFormatter.string(from: NSNumber(value: questionNumber)) ?? "")
            } else {
                numberLabel?.text = ""
            }
            updateAccessibilityLabel()
        }
    }
    
    var questionFlagged: ()->() = {}
    
    class var ReuseID: String {
        return "QuestionHeaderViewReuseID"
    }
    
    class var Nib: UINib {
        return UINib(nibName: "QuestionHeaderView", bundle: Bundle(for: self.classForCoder()))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        flagButton?.tintColor = Brand.current().secondaryTintColor
        
        isAccessibilityElement = true
        accessibilityTraits |= UIAccessibilityTraitHeader
        accessibilityElements = []
        
        let toggleName = NSLocalizedString("Toggle Flag", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Toggle flag accessiblity action")
        let toggleFlagAction = UIAccessibilityCustomAction(name: toggleName, target: self, selector: #selector(flagAction(_:)))
        
        accessibilityCustomActions = [toggleFlagAction]
    }
    
    
    override func prepareForReuse() {
        numberLabel.text = ""
    }
    
    // MARK: Actions
    
    @IBAction func flagAction(_ button: UIButton?) {
        flagButton.isSelected = !flagButton.isSelected
        
        updateAccessibilityLabel()
        postFlagChangedA11yNotification()
        questionFlagged()
    }
}


// MARK: Accessibility
extension QuestionHeaderView {
    
    func updateAccessibilityLabel() {
        let question = NSLocalizedString("Question", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "accessibility label for a quiz question")
        var label = question + " \(questionNumber)."
        
        if flagged {
            label += " " + NSLocalizedString("Flagged", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "State of the flagged question")
        }
        accessibilityLabel = label
    }
    
    func postFlagChangedA11yNotification() {
        let notification: String
        if flagged {
            notification = NSLocalizedString("Question \(questionNumber) Flagged", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "state for a question that has been flagged")
        } else {
            notification = NSLocalizedString("Question \(questionNumber) Unflagged", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "state for unflagged question")
        }
        
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, notification)
    }
}
