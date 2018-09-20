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

import UIKit

class CardView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 4.0
        layer.borderWidth = 1.0 / UIScreen.main.nativeScale
        layer.borderColor = UIColor(white: 0.89, alpha: 1.0).cgColor
        clipsToBounds = true
    }
}
