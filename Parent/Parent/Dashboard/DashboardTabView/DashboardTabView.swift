//
//  DashboardTabView.swift
//  Parent
//
//  Created by Brandon Pluim on 1/12/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

class DashboardTabView: UIView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    private let selectedAlpha: CGFloat = 1.0
    private let unselectedAlpha: CGFloat = 0.6
    
    var normalImage: UIImage?
    var selectedImage: UIImage?
    var title: String? {
        didSet {
            guard let title = title else {
                titleLabel.attributedText = NSMutableAttributedString(string: "")
                return
            }

            accessibilityLabel = title

            let attributedString = NSMutableAttributedString(string: title)
            attributedString.addAttribute(NSKernAttributeName, value: CGFloat(3), range: NSRange(location: 0, length: attributedString.length))

            titleLabel.attributedText = attributedString
        }
    }

    let badgeView: BadgeView = BadgeView()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        isAccessibilityElement = true
        iconImageView.tintColor = UIColor.whiteColor()
        titleLabel.textColor = UIColor.whiteColor()

        iconImageView.addSubview(badgeView)
    }
    
    func setSelected(selected: Bool) {
        titleLabel.alpha = selected ? selectedAlpha : unselectedAlpha

        iconImageView.alpha = selected ? selectedAlpha : unselectedAlpha
        iconImageView.image = selected ? selectedImage : normalImage
        if selected {
            accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitHeader | UIAccessibilityTraitSelected
        } else {
            accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitHeader
        }
    }
}
