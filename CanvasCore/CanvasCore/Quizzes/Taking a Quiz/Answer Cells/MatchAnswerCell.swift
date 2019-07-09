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


class MatchAnswerCell: UITableViewCell {

    @IBOutlet var answerLabel: UILabel!
    @IBOutlet var matchLabel: UILabel!
    @objc var hiddenTextField: UITextField = UITextField()

    @objc var pickerView: UIPickerView = UIPickerView()
    @objc var pickerItems: [String] = []

    @objc var donePicking: (Int)->() = { _ in }

    @objc class var ReuseID: String {
        return "MatchAnswerCellReuseID"
    }

    @objc class var Nib: UINib {
        return UINib(nibName: "MatchAnswerCell", bundle: Bundle(for: self.classForCoder()))
    }

    @objc class var font: UIFont {
        return UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
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

    @objc class func heightWithAnswerText(_ answerText: String, matchText: String, boundsWidth width: CGFloat) -> CGFloat {
        let horizontalPadding: CGFloat = 30.0
        let verticalPadding: CGFloat = 18.0
        let maxLabelWidth = width - (2 * horizontalPadding)
        let answerLabelSize = font.sizeOfString(answerText, constrainedToWidth: maxLabelWidth)
        let matchLabelSize = font.sizeOfString(matchText, constrainedToWidth: maxLabelWidth)
        let height = ceil((2 * verticalPadding) + answerLabelSize.height + 4.0 + matchLabelSize.height)
        return height
    }

    @objc func doneButtonSelected() {
        let row = pickerView.selectedRow(inComponent: 0)
        hiddenTextField.resignFirstResponder()
        donePicking(row)
    }

    @objc func cancelButtonSelected() {
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
