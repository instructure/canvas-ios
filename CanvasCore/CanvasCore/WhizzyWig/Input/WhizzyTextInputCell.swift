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

extension String {
    func constraintsForViews(_ views: [String: AnyObject]) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: self, options: [], metrics: nil, views: views)
    }
}

open class WhizzyTextInputCell: UITableViewCell, UITextViewDelegate {
    
    @objc public let placeholder: UILabel
    @objc public let textView: UITextView
    
    @objc open var inputText: String {
        get {
            return textView.text ?? ""
        } set {
            textView.text = newValue
            hidePlaceholderIfNecessary()
            notifyIfHeightDidChange()
        }
    }
    
    @objc open var textDidChange: (String)->() = {_ in }
    @objc open var heightDidChange: (CGFloat)->() = {_ in }
    @objc open var doneEditing: (String)->() = { _ in }
    
    fileprivate var cachedTextViewHeight = CGFloat(0.0)
    fileprivate var cachedCellWidth = CGFloat(0.0)
    
    fileprivate var verticalConstraints: [NSLayoutConstraint] = []
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        placeholder = TIC.createPlaceholder()
        textView = TIC.createTextView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textView)
        contentView.addSubview(placeholder)
        
        preparePlaceholder()
        prepareTextView()
        
        selectionStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(WhizzyTextInputCell.didRotate(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func didRotate(_ note: Notification) {
        notifyIfHeightDidChange()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc open func notifyIfHeightDidChange() {
        let text = textView.text
        let boundsWidth = bounds.size.width
        
        let height = WhizzyTextInputCell.heightWithText(text!, boundsWidth: boundsWidth)
        
        if height != cachedTextViewHeight || boundsWidth != cachedCellWidth {
            
            cachedCellWidth = boundsWidth
            cachedTextViewHeight = height
            
            heightDidChange(height)
        }
    }
    
    fileprivate func hidePlaceholderIfNecessary() {
        let weHaveText = inputText != ""
        
        placeholder.isHidden = weHaveText
    }
    
    open func textViewDidBeginEditing(_ textView: UITextView) {
        hidePlaceholderIfNecessary()
    }
    
    open func textViewDidEndEditing(_ textView: UITextView) {
        hidePlaceholderIfNecessary()
        doneEditing(textView.text ?? "")
    }
    
    open func textViewDidChange(_ textView: UITextView) {
        hidePlaceholderIfNecessary()
        textDidChange(textView.text ?? "")
        notifyIfHeightDidChange()
    }

    required public init?(coder aDecoder: NSCoder) {
        placeholder = aDecoder.decodeObject(forKey: "placeholder") as! UILabel
        textView = aDecoder.decodeObject(forKey: "textView") as! UITextView
        
        super.init(coder: aDecoder)
    }
    
    open override func encode(with aCoder: NSCoder) {
        aCoder.encode(placeholder, forKey: "placeholder")
        aCoder.encode(textView, forKey: "textView")
    }
    
    open override func prepareForReuse() {
        heightDidChange = {_ in }
        doneEditing = { _ in }
        
        cachedTextViewHeight = 0.0
        cachedCellWidth = 0.0
    }
}

// MARK: textView
public extension WhizzyTextInputCell {
    
    fileprivate class func createTextView() -> UITextView {
        let textView = NeverScrollingTextView()
        textView.font = WhizzyTextInputCell.font
        textView.translatesAutoresizingMaskIntoConstraints = false
        let textContainerInsets = WhizzyTextInputCell.textContainerInsets
        textView.textContainerInset = textContainerInsets
        
        return textView
    }
    
    fileprivate func prepareTextView() {
        textView.delegate = self

        let textViewMargins = TIC.textViewMargins
        contentView.addConstraints("|-\(textViewMargins.left)-[textView]-\(textViewMargins.right)-|".constraintsForViews(["textView": textView]))
        verticalConstraints = "V:|-\(textViewMargins.top)-[textView]-\(textViewMargins.bottom)-|".constraintsForViews(["textView": textView])
        contentView.addConstraints(verticalConstraints)
        
        hidePlaceholderIfNecessary()
    }
    
    fileprivate class var textContainerInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 7, left: 5, bottom: 5, right: 5)
    }
    
    fileprivate class var textViewMargins: UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
    }
    
    @objc class var font: UIFont {
        return UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
    }
    
    @objc class func heightWithText(_ text: String, boundsWidth width: CGFloat) -> CGFloat {
        
        let textViewBoundsWidth = width - textViewMargins.left - textViewMargins.right
        
        // so there appears to be about 10 pts here unaccounted for by the textview's insets (5 on each side).
        // /me shrugs
        let textBounds = font.sizeOfString(text, constrainedToWidth: textViewBoundsWidth - textContainerInsets.left - textContainerInsets.right - 10.0)
        let textHeight = textBounds.height + textContainerInsets.top + textContainerInsets.bottom + 5.0
        
        let marginHeight = textViewMargins.top + textViewMargins.bottom
        
        
        return ceil(textHeight + marginHeight)
    }
}


// MARK: placeholder
public extension WhizzyTextInputCell {
    
    fileprivate class func createPlaceholder() -> UILabel {
        let placeholder = UILabel()
        placeholder.font = WhizzyTextInputCell.font
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.textColor = UIColor.lightGray
        return placeholder
    }
    
    fileprivate func preparePlaceholder() {
        let placeholderOrigin = WhizzyTextInputCell.placeholderOrigin
        contentView.addConstraints("|-\(placeholderOrigin.x)-[placeholder]".constraintsForViews(["placeholder": placeholder]))
        contentView.addConstraints("V:|-\(placeholderOrigin.y)-[placeholder]".constraintsForViews(["placeholder": placeholder]))
    }
    
    fileprivate class var placeholderOrigin: CGPoint {
        // some magic numbers for UITextView.
        return CGPoint(x: textViewMargins.left + textContainerInsets.left + 5.0, y: textViewMargins.top + textContainerInsets.top + 0.5)
    }
}


typealias TIC = WhizzyTextInputCell
