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


class ShortAnswerCell: UITableViewCell {
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 4
        formatter.roundingMode = .down
        return formatter
    }()
    
    @IBOutlet fileprivate var textFieldBox: UIView!
    @IBOutlet var textField: UITextField!
    
    @objc var doneEditing: (String)->() = { _ in }
    
    @objc class var ReuseID: String {
        return "ShortAnswerCellReuseID"
    }
    
    @objc class var Nib: UINib {
        return UINib(nibName: "ShortAnswerCell", bundle: Bundle(for: self.classForCoder()))
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
    
    fileprivate func setup() {
        textFieldBox.layer.borderColor = UIColor.prettyLightGray().cgColor
        textFieldBox.layer.borderWidth = 2.0
        textField.accessibilityIdentifier = "ShortAnswerCell.textField"
        
        tintColor = Brand.current.tintColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}

extension ShortAnswerCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var text = textField.text ?? ""
        if textField.keyboardType == .numbersAndPunctuation {
            while text.last == "." { text = String(text.dropLast()) }
            if let number = NumberFormatter().number(from: text) {
                text = Self.numberFormatter.string(from: number) ?? text
            }
        }
        textField.text = text
        doneEditing(text)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.lengthOfBytes(using: String.Encoding.utf8) == 0 {
            return true
        }
        
        // This makes the text field smart, and if we intend for only decimal input, then only allow decimal input for things like custom keyboards or external keyboards
        if (textField.keyboardType == .numbersAndPunctuation) {
            let characterSet = CharacterSet(charactersIn: "0123456789.-^").inverted // couldn't use the decimal set because it doesn't contain the "."
            let range = string.rangeOfCharacter(from: characterSet)
            if range != nil {
                return false
            }
        }
        
        return true
    }
}
