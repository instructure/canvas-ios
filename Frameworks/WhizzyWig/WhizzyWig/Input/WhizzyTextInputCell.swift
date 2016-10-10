//
//  WhizzyTextInputCell.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 3/2/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import UIKit

extension String {
    func constraintsForViews(views: [String: AnyObject]) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraintsWithVisualFormat(self, options: [], metrics: nil, views: views)
    }
}


extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: CGFloat) -> CGSize {
        return (string as NSString).boundingRectWithSize(CGSize(width: width, height: CGFloat.max),
            options: unsafeBitCast(NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue | NSStringDrawingOptions.UsesFontLeading.rawValue, NSStringDrawingOptions.self),
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
}

public class WhizzyTextInputCell: UITableViewCell, UITextViewDelegate {
    
    public let placeholder: UILabel
    public let textView: UITextView
    
    public var inputText: String {
        get {
            return textView.text ?? ""
        } set {
            textView.text = newValue
            hidePlaceholderIfNecessary()
            notifyIfHeightDidChange()
        }
    }
    
    public var textDidChange: String->() = {_ in }
    public var heightDidChange: CGFloat->() = {_ in }
    public var doneEditing: String->() = { _ in }
    
    private var cachedTextViewHeight = CGFloat(0.0)
    private var cachedCellWidth = CGFloat(0.0)
    
    private var verticalConstraints: [NSLayoutConstraint] = []
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        placeholder = TIC.createPlaceholder()
        textView = TIC.createTextView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textView)
        contentView.addSubview(placeholder)
        
        preparePlaceholder()
        prepareTextView()
        
        selectionStyle = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WhizzyTextInputCell.didRotate(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func didRotate(note: NSNotification) {
        notifyIfHeightDidChange()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public func notifyIfHeightDidChange() {
        let text = textView.text
        let boundsWidth = bounds.size.width
        
        let height = WhizzyTextInputCell.heightWithText(text, boundsWidth: boundsWidth)
        
        if height != cachedTextViewHeight || boundsWidth != cachedCellWidth {
            
            cachedCellWidth = boundsWidth
            cachedTextViewHeight = height
            
            heightDidChange(height)
        }
    }
    
    private func hidePlaceholderIfNecessary() {
        let weHaveText = inputText != ""
        
        placeholder.hidden = weHaveText
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        hidePlaceholderIfNecessary()
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        hidePlaceholderIfNecessary()
        doneEditing(textView.text ?? "")
    }
    
    public func textViewDidChange(textView: UITextView) {
        hidePlaceholderIfNecessary()
        textDidChange(textView.text ?? "")
        notifyIfHeightDidChange()
    }

    required public init?(coder aDecoder: NSCoder) {
        placeholder = aDecoder.decodeObjectForKey("placeholder") as! UILabel
        textView = aDecoder.decodeObjectForKey("textView") as! UITextView
        
        super.init(coder: aDecoder)
    }
    
    public override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(placeholder, forKey: "placeholder")
        aCoder.encodeObject(textView, forKey: "textView")
    }
    
    public override func prepareForReuse() {
        heightDidChange = {_ in }
        doneEditing = { _ in }
        
        cachedTextViewHeight = 0.0
        cachedCellWidth = 0.0
    }
}

// MARK: textView
public extension WhizzyTextInputCell {
    
    private class func createTextView() -> UITextView {
        let textView = NeverScrollingTextView()
        textView.font = WhizzyTextInputCell.font
        textView.translatesAutoresizingMaskIntoConstraints = false
        let textContainerInsets = WhizzyTextInputCell.textContainerInsets
        textView.textContainerInset = textContainerInsets
        
        return textView
    }
    
    private func prepareTextView() {
        textView.delegate = self

        let textViewMargins = TIC.textViewMargins
        contentView.addConstraints("|-\(textViewMargins.left)-[textView]-\(textViewMargins.right)-|".constraintsForViews(["textView": textView]))
        verticalConstraints = "V:|-\(textViewMargins.top)-[textView]-\(textViewMargins.bottom)-|".constraintsForViews(["textView": textView])
        contentView.addConstraints(verticalConstraints)
        
        hidePlaceholderIfNecessary()
    }
    
    private class var textContainerInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 7, left: 5, bottom: 5, right: 5)
    }
    
    private class var textViewMargins: UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
    }
    
    public class var font: UIFont {
        return UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }
    
    public class func heightWithText(text: String, boundsWidth width: CGFloat) -> CGFloat {
        
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
    
    private class func createPlaceholder() -> UILabel {
        let placeholder = UILabel()
        placeholder.font = WhizzyTextInputCell.font
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.textColor = UIColor.lightGrayColor()
        return placeholder
    }
    
    private func preparePlaceholder() {
        let placeholderOrigin = WhizzyTextInputCell.placeholderOrigin
        contentView.addConstraints("|-\(placeholderOrigin.x)-[placeholder]".constraintsForViews(["placeholder": placeholder]))
        contentView.addConstraints("V:|-\(placeholderOrigin.y)-[placeholder]".constraintsForViews(["placeholder": placeholder]))
    }
    
    private class var placeholderOrigin: CGPoint {
        // some magic numbers for UITextView.
        return CGPoint(x: textViewMargins.left + textContainerInsets.left + 5.0, y: textViewMargins.top + textContainerInsets.top + 0.5)
    }
}


typealias TIC = WhizzyTextInputCell
