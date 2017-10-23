//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
