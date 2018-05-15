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


class MatchAnswerCell: UITableViewCell {

    @IBOutlet var answerLabel: UILabel!
    @IBOutlet var matchLabel: UILabel!
    var hiddenTextField: UITextField = UITextField()

    var pickerView: UIPickerView = UIPickerView()
    var pickerItems: [String] = []

    var donePicking: (Int)->() = { _ in }

    class var ReuseID: String {
        return "MatchAnswerCellReuseID"
    }

    class var Nib: UINib {
        return UINib(nibName: "MatchAnswerCell", bundle: Bundle(for: self.classForCoder()))
    }

    class var font: UIFont {
        return UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
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
        self.addSubview(hiddenTextField)
        hiddenTextField.isHidden = true

        pickerView.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: 216.0)
        pickerView.backgroundColor = UIColor.white
        pickerView.showsSelectionIndicator = true
        pickerView.delegate = self
        pickerView.dataSource = self

        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.barTintColor = Brand.current.navBgColor
        toolbar.tintColor = Brand.current.navTextColor
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", tableName: "Localizable", bundle: .core, value: "", comment: "Done button"), style: .plain, target: self, action: #selector(MatchAnswerCell.doneButtonSelected))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", tableName: "Localizable", bundle: .core, value: "", comment: "Cancel button title"), style: .plain, target: self, action: #selector(MatchAnswerCell.cancelButtonSelected))
        toolbar.setItems([cancelButton, spaceItem, doneButton], animated: false)

        hiddenTextField.inputView = pickerView
        hiddenTextField.inputAccessoryView = toolbar
    }

    class func heightWithAnswerText(_ answerText: String, matchText: String, boundsWidth width: CGFloat) -> CGFloat {
        let horizontalPadding: CGFloat = 30.0
        let verticalPadding: CGFloat = 18.0
        let maxLabelWidth = width - (2 * horizontalPadding)
        let answerLabelSize = font.sizeOfString(answerText, constrainedToWidth: maxLabelWidth)
        let matchLabelSize = font.sizeOfString(matchText, constrainedToWidth: maxLabelWidth)
        let height = ceil((2 * verticalPadding) + answerLabelSize.height + 4.0 + matchLabelSize.height)
        return height
    }

    func doneButtonSelected() {
        let row = pickerView.selectedRow(inComponent: 0)
        hiddenTextField.resignFirstResponder()
        donePicking(row)
    }

    func cancelButtonSelected() {
        hiddenTextField.resignFirstResponder()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        pickerItems = []
        pickerView.reloadComponent(0)
    }

}

extension MatchAnswerCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems.count
    }
}

extension MatchAnswerCell: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerView.heightForTitles(titles: pickerItems)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let title = pickerItems[row]
        if let view = view {
            return view
        }
        
        return pickerView.titleView(title: title)
    }
}
