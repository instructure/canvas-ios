//
//  ShortAnswerCell.swift
//  Quizzes
//
//  Created by Ben Kraus on 5/29/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import SoPretty

class ShortAnswerCell: UITableViewCell {
    
    @IBOutlet private var textFieldBox: UIView!
    @IBOutlet var textField: UITextField!
    
    var doneEditing: String->() = { _ in }
    
    class var ReuseID: String {
        return "ShortAnswerCellReuseID"
    }
    
    class var Nib: UINib {
        return UINib(nibName: "ShortAnswerCell", bundle: NSBundle(forClass: self.classForCoder()))
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        textFieldBox.layer.borderColor = UIColor.prettyLightGray().CGColor
        textFieldBox.layer.borderWidth = 2.0
        
        tintColor = Brand.current().tintColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}

extension ShortAnswerCell: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        doneEditing(textField.text ?? "")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            return true
        }
        
        // This makes the text field smart, and if we intend for only decimal input, then only allow decimal input for things like custom keyboards or external keyboards
        if (textField.keyboardType == .NumbersAndPunctuation) {
            let characterSet = NSCharacterSet(charactersInString: "0123456789.-^").invertedSet // couldn't use the decimal set because it doesn't contain the "."
            let range = string.rangeOfCharacterFromSet(characterSet)
            if range != nil {
                return false
            }
        }
        
        return true
    }
}