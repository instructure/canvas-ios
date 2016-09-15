//
//  TokenLabel.swift
//  Parent
//
//  Created by Ben Kraus on 3/10/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
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
