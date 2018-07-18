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


class TextAnswerCell: UITableViewCell {
    @IBOutlet var textAnswerLabel: UILabel!
    @IBOutlet var selectionStatusImageView: UIImageView!
    
    class var ReuseID: String {
        return "TextAnswerCellReuseID"
    }
    
    class var Nib: UINib {
        return UINib(nibName: "TextAnswerCell", bundle: Bundle(for: self.classForCoder()))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStatusImageView.tintColor = Brand.current.secondaryTintColor
    }
    
    class var font: UIFont {
        return UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    }
    
    class func heightWithText(_ text: String, boundsWidth width: CGFloat) -> CGFloat {
        let insets = UIEdgeInsets(top: 15.0, left: 40.0, bottom: 15.0, right: 40.0)
        let labelBoundsWidth = width - insets.left - insets.right
        let textSize = font.sizeOfString(text, constrainedToWidth: labelBoundsWidth)
        
        return ceil(textSize.height + insets.top + insets.bottom)
    }
    
    override func prepareForReuse() {
        self.selectionStatusImageView.isHidden = true
        self.textAnswerLabel.text = ""
    }
}

extension TextAnswerCell: SelectableAnswerCell {
    func configureForState(selected: Bool) {
        selectionStatusImageView.isHidden = !selected
    }
}
