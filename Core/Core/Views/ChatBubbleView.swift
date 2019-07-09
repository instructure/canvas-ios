//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
            case .right:
                bgImageView.transform = CGAffineTransform.identity
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }

    func setupFromNib() {
        contentView = loadFromXib()
    }
}
