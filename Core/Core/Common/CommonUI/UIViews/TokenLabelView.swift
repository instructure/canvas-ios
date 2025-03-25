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

import UIKit

public class TokenView: UILabel {

    private static let xInset = CGFloat(7)
    private static let yInset = CGFloat(1)

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    @objc func setup() {
        clipsToBounds = true
        font = UIFont.scaledNamedFont(.bold11)
        textColor = .textLightest.variantForLightMode

        setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height/2
    }

    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: TokenView.xInset, dy: TokenView.yInset))
    }

    public override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize

        size.width += TokenView.xInset + TokenView.xInset
        size.height += TokenView.yInset + TokenView.yInset

        return size
    }

    public override var text: String? {
        get {
            return super.text
        }
        set {
            super.text = newValue?.localizedUppercase
            invalidateIntrinsicContentSize()
        }
    }
}
