//
// Copyright (C) 2019-present Instructure, Inc.
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

public class ChatBubbleView: UIView {
    public enum Side: String {
        case left, right
    }

    @IBOutlet weak var bgImageView: IconView!
    @IBOutlet public weak var textLabel: DynamicLabel!
    @IBOutlet public weak var contentView: UIView!
    public var side: Side = .right {
        didSet {
            switch side {
            case .left:
                bgImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
                textLabel.textAlignment = .left

            case .right:
                bgImageView.transform = CGAffineTransform.identity
                textLabel.textAlignment = .right
            }
        }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }

    func setupFromNib() {
        contentView = loadFromXib()
    }
}
