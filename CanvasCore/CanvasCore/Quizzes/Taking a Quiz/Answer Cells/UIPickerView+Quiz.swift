//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation

let sizingLabel = UILabel()

extension UIPickerView {
    
    // Measures all of the titles and returns the height of the tallest one
    func heightForTitles(titles: [String]) -> CGFloat {
        sizingLabel.numberOfLines = 0
        let width = self.frame.width
        return titles.reduce(0.0, { (memo, value) -> CGFloat in
            sizingLabel.text = value
            let height = sizingLabel.sizeThatFits(CGSize(width: width, height: CGFloat(Int.max))).height
            if (height > memo) {
                return height
            }
            
            return memo
        })
    }
    
    func titleView(title: String) -> UIView {
        let label = UILabel()
        label.text = title
        label.numberOfLines = 0
        label.textAlignment = .left
        let size = label.sizeThatFits(CGSize(width: self.frame.width, height: CGFloat(Int.max)))
        label.frame.size = CGSize(width: self.frame.width - 20.0, height: size.height)
        return label
    }
}
