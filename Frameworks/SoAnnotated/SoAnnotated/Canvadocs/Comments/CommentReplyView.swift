//
//  CommentReplyView.swift
//  SoAnnotated
//
//  Created by Ben Kraus on 11/2/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit

class CommentReplyView: UIView {
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var replyTextView: UITextView!
    @IBOutlet var replyContainerView: UIView!
    
    var heightConstraint: NSLayoutConstraint?
    
    var sendAction: ()->() = { }
    
    static func instantiate() -> CommentReplyView {
        return NSBundle(forClass: self.classForCoder()).loadNibNamed("CommentReplyView", owner: self, options: nil)!.first! as! CommentReplyView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        replyContainerView.layer.cornerRadius = 5.0
        replyContainerView.layer.borderWidth = 1.0
        replyContainerView.layer.borderColor = UIColor.lightGrayColor().CGColor
        replyContainerView.clipsToBounds = true
        
        replyTextView.scrollEnabled = false
        
        heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 63.0)
        self.addConstraint(heightConstraint!)
    }
    
    @IBAction func sendButtonClicked(sender: UIButton) {
        sendAction()
    }
    
    func clearText() {
        replyTextView.text = ""
        adjustHeight()
    }
    
    func adjustHeight() {
        let fixedWidth = replyTextView.frame.size.width
        let newSize = replyTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        heightConstraint?.constant = min(newSize.height + 30, 148) // 148 is 6 rows of text
        UIView.animateWithDuration(0.3, animations: {
            self.superview?.layoutIfNeeded()
        })
        
        replyTextView.scrollEnabled = heightConstraint?.constant == 148
    }
}

extension CommentReplyView: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        adjustHeight()
    }
}
