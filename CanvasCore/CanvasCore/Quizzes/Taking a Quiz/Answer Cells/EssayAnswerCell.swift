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

import Foundation

import Cartography



class EssayAnswerCell: WhizzyTextInputCell {
    @objc class var ReuseID: String {
        return "EssayAnswerCellReuseID"
    }
    
    @objc override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        placeholder.text = "Enter answer..."
        
        textView.layer.borderColor = UIColor.prettyLightGray().cgColor
        textView.layer.borderWidth = 2.0
        
        tintColor = Brand.current.tintColor
        
        accessibilityElements = [textView]
        isAccessibilityElement = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        inputText = ""
    }
}
