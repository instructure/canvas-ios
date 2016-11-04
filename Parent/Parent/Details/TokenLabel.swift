
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

class TokenLabel: UILabel {

    let insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }

    override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        size.height = size.height + insets.top + insets.bottom
        size.width = size.width + insets.left + insets.right
        return size
    }
}
