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

import Result

extension UIFont {
    // Attribution: http://stackoverflow.com/a/37926738/1518561
    fileprivate static var tokenFont: UIFont {
        let font = UIFont.preferredFont(forTextStyle: .caption2)
        
        let settings = [[UIFontFeatureTypeIdentifierKey: kLowerCaseType, UIFontFeatureSelectorIdentifierKey: kLowerCaseSmallCapsSelector]]
        
        let attributes: [String: Any] = [UIFontDescriptorFeatureSettingsAttribute: settings, UIFontDescriptorNameAttribute: font.fontName]
        
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
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
    
    func setup() {
        clipsToBounds = true
        font = .tokenFont
        textColor = UIColor.white
        
        setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
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
