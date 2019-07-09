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

import Result

extension UIFont {
    // Attribution: http://stackoverflow.com/a/37926738/1518561
    fileprivate static var tokenFont: UIFont {
        let font = UIFont.preferredFont(forTextStyle: .caption2)
        
        let settings = [[convertFromUIFontDescriptorFeatureKey(UIFontDescriptor.FeatureKey.featureIdentifier): kLowerCaseType, convertFromUIFontDescriptorFeatureKey(UIFontDescriptor.FeatureKey.typeIdentifier): kLowerCaseSmallCapsSelector]]
        
        let attributes: [String: Any] = [convertFromUIFontDescriptorAttributeName(UIFontDescriptor.AttributeName.featureSettings): settings, convertFromUIFontDescriptorAttributeName(UIFontDescriptor.AttributeName.name): font.fontName]
        
        let descriptor = UIFontDescriptor(fontAttributes: convertToUIFontDescriptorAttributeNameDictionary(attributes))
            .withSymbolicTraits([.traitBold])
        return UIFont(descriptor: descriptor!, size: font.pointSize)
    }
}

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
        font = .tokenFont
        textColor = UIColor.white
        
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
        set {
            super.text = newValue?.lowercased()
            invalidateIntrinsicContentSize()
        } get {
            return super.text
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIFontDescriptorFeatureKey(_ input: UIFontDescriptor.FeatureKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIFontDescriptorAttributeName(_ input: UIFontDescriptor.AttributeName) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIFontDescriptorAttributeNameDictionary(_ input: [String: Any]) -> [UIFontDescriptor.AttributeName: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIFontDescriptor.AttributeName(rawValue: key), value)})
}
