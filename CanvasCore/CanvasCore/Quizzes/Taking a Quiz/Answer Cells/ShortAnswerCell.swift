//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import UIKit


class ShortAnswerCell: UITableViewCell {
    
    @IBOutlet fileprivate var textFieldBox: UIView!
    @IBOutlet var textField: UITextField!
    
    var doneEditing: (String)->() = { _ in }
    
    class var ReuseID: String {
        return "ShortAnswerCellReuseID"
    }
    
    class var Nib: UINib {
        return UINib(nibName: "ShortAnswerCell", bundle: Bundle(for: self.classForCoder()))
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
    
    fileprivate func setup() {
        textFieldBox.layer.borderColor = UIColor.prettyLightGray().cgColor
        textFieldBox.layer.borderWidth = 2.0
        
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
        doneEditing(textField.text ?? "")
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
