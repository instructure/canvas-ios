//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit


class QuestionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet fileprivate var flagButton: UIButton!
    @IBOutlet fileprivate var numberLabel: UILabel!

    @objc static var questionNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    @objc var flagged: Bool {
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
    
    @objc var questionFlagged: ()->() = {}
    
    @objc class var ReuseID: String {
        return "QuestionHeaderViewReuseID"
    }
    
    @objc class var Nib: UINib {
        return UINib(nibName: "QuestionHeaderView", bundle: Bundle(for: self.classForCoder()))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        flagButton?.tintColor = Brand.current.secondaryTintColor
        
        isAccessibilityElement = true
        accessibilityTraits = [ accessibilityTraits, UIAccessibilityTraits.header ]
        accessibilityElements = []
        
        let toggleName = NSLocalizedString("Toggle Flag", tableName: "Localizable", bundle: .core, value: "", comment: "Toggle flag accessiblity action")
        let toggleFlagAction = UIAccessibilityCustomAction(name: toggleName, target: self, selector: #selector(flagAction(_:)))
        
        accessibilityCustomActions = [toggleFlagAction]
        
        numberLabel.font = UIFont.preferredFont(forTextStyle: .body)
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
    
    @objc func heightWithText(width: CGFloat) -> CGFloat {
        let insets = UIEdgeInsets(top: 15.0, left: 40.0, bottom: 15.0, right: 40.0)
        let labelBoundsWidth = width - insets.left - insets.right
        let text = numberLabel.text ?? ""
        let textSize = numberLabel.font.sizeOfString(text, constrainedToWidth: labelBoundsWidth)
        return ceil(textSize.height + insets.top + insets.bottom)
    }
    
    @objc func updateAccessibilityLabel() {
        var label = ""
        if let number = questionNumber {
            let question = NSLocalizedString("Question", tableName: "Localizable", bundle: .core, value: "", comment: "accessibility label for a quiz question")
            label = question + " \(number)."
        }
        
        if flagged {
            label += " " + NSLocalizedString("Flagged", tableName: "Localizable", bundle: .core, value: "", comment: "State of the flagged question")
        }
        accessibilityLabel = label.trimmingCharacters(in: .whitespaces)
    }
    
    @objc func postFlagChangedA11yNotification() {
        guard let number = questionNumber else { return }
        let notification: String
        if flagged {
            notification = NSLocalizedString("Question \(number) Flagged", tableName: "Localizable", bundle: .core, value: "", comment: "state for a question that has been flagged")
        } else {
            notification = NSLocalizedString("Question \(number) Unflagged", tableName: "Localizable", bundle: .core, value: "", comment: "state for unflagged question")
        }
        
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: notification)
    }
}
