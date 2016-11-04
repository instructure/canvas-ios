
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