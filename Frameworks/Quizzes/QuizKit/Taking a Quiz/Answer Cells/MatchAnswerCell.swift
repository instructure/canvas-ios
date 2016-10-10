//
//  MatchAnswerCell.swift
//  iCanvas
//
//  Created by Ben Kraus on 5/29/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import SoPretty

class MatchAnswerCell: UITableViewCell {

    @IBOutlet var answerLabel: UILabel!
    @IBOutlet var matchLabel: UILabel!
    var hiddenTextField: UITextField = UITextField()

    var pickerView: UIPickerView = UIPickerView()
    var pickerItems: [String] = []

    var donePicking: Int->() = { _ in }

    class var ReuseID: String {
        return "MatchAnswerCellReuseID"
    }

    class var Nib: UINib {
        return UINib(nibName: "MatchAnswerCell", bundle: NSBundle(forClass: self.classForCoder()))
    }

    class var font: UIFont {
        return UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
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
        self.addSubview(hiddenTextField)
        hiddenTextField.hidden = true

        pickerView.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: 216.0)
        pickerView.backgroundColor = UIColor.whiteColor()
        pickerView.showsSelectionIndicator = true
        pickerView.delegate = self
        pickerView.dataSource = self

        let toolbar = UIToolbar()
        toolbar.barStyle = .Default
        toolbar.translucent = true
        toolbar.barTintColor = Brand.current().navBarTintColor
        toolbar.tintColor = UIColor.whiteColor()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Done button"), style: .Plain, target: self, action: #selector(MatchAnswerCell.doneButtonSelected))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "Cancel button"), style: .Plain, target: self, action: #selector(MatchAnswerCell.cancelButtonSelected))
        toolbar.setItems([cancelButton, spaceItem, doneButton], animated: false)

        hiddenTextField.inputView = pickerView
        hiddenTextField.inputAccessoryView = toolbar
    }

    class func heightWithAnswerText(answerText: String, matchText: String, boundsWidth width: CGFloat) -> CGFloat {
        let horizontalPadding: CGFloat = 30.0
        let verticalPadding: CGFloat = 18.0
        let maxLabelWidth = width - (2 * horizontalPadding)
        let answerLabelSize = font.sizeOfString(answerText, constrainedToWidth: maxLabelWidth)
        let matchLabelSize = font.sizeOfString(matchText, constrainedToWidth: maxLabelWidth)
        let height = ceil((2 * verticalPadding) + answerLabelSize.height + 4.0 + matchLabelSize.height)
        return height
    }

    func doneButtonSelected() {
        let row = pickerView.selectedRowInComponent(0)
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
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems.count
    }
}

extension MatchAnswerCell: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerItems[row]
    }
}
