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

class CommentReplyView: UIView {
    
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var replyTextView: UITextView!
    @IBOutlet var replyContainerView: UIView!
    
    var heightConstraint: NSLayoutConstraint?
    
    var sendAction: ()->() = { }
    
    static func instantiate() -> CommentReplyView {
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
        
        heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 49.0)
        self.addConstraint(heightConstraint!)
    }
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        sendAction()
    }
    
    func clearText() {
        replyTextView.text = ""
        adjustHeight()
    }
    
    func adjustHeight() {
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
