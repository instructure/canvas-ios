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

class CommentReplyView: UIView {
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var replyTextView: UITextView!
    @IBOutlet var replyContainerView: UIView!
    
    @objc var heightConstraint: NSLayoutConstraint?
    
    @objc var sendAction: ()->() = { }
    
    @objc static func instantiate() -> CommentReplyView {
        return Bundle(for: self.classForCoder()).loadNibNamed("CommentReplyView", owner: self, options: nil)!.first! as! CommentReplyView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        replyContainerView.layer.cornerRadius = 33.0/2
        replyContainerView.layer.borderWidth = 0.5
        replyContainerView.layer.borderColor = UIColor.lightGray.cgColor
        replyContainerView.clipsToBounds = true
        
        replyTextView.isScrollEnabled = false
        replyTextView.placeholder = NSLocalizedString("Reply", comment: "")
        replyTextView.placeholderColor = .lightGray
        
        heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: 49.0)
        self.addConstraint(heightConstraint!)
    }
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        sendAction()
    }
    
    @objc func clearText() {
        replyTextView.text = ""
        adjustHeight()
    }
    
    @objc func adjustHeight() {
        let fixedWidth = replyTextView.frame.size.width
        let newSize = replyTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        heightConstraint?.constant = min(newSize.height + 16, 148) // 148 is 6 rows of text
        UIView.animate(withDuration: 0.3, animations: {
            self.superview?.layoutIfNeeded()
        })
        
        replyTextView.isScrollEnabled = heightConstraint?.constant == 148
    }
}

extension CommentReplyView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        adjustHeight()
    }
    
    
}
