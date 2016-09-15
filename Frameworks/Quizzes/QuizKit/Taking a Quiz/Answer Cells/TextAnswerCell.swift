//
//  TextAnswerCell.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 2/18/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit
import SoPretty

class TextAnswerCell: UITableViewCell {
    @IBOutlet var textAnswerLabel: UILabel!
    @IBOutlet var selectionStatusImageView: UIImageView!
    
    class var ReuseID: String {
        return "TextAnswerCellReuseID"
    }
    
    class var Nib: UINib {
        return UINib(nibName: "TextAnswerCell", bundle: NSBundle(forClass: self.classForCoder()))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStatusImageView.tintColor = Brand.current().secondaryTintColor
    }
    
    class var font: UIFont {
        return UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }
    
    class func heightWithText(text: String, boundsWidth width: CGFloat) -> CGFloat {
        let insets = UIEdgeInsets(top: 15.0, left: 40.0, bottom: 15.0, right: 40.0)
        let labelBoundsWidth = width - insets.left - insets.right
        let textSize = font.sizeOfString(text, constrainedToWidth: labelBoundsWidth)
        
        return ceil(textSize.height + insets.top + insets.bottom)
    }
    
    override func prepareForReuse() {
        self.selectionStatusImageView.hidden = true
        self.textAnswerLabel.text = ""
    }
}

extension TextAnswerCell: SelectableAnswerCell {
    func configureForState(selected selected: Bool) {
        selectionStatusImageView.hidden = !selected
    }
}