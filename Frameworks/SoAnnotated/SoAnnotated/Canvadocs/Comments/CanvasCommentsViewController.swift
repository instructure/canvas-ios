
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
import PSPDFKit

class CanvadocsCommentsViewController: UIViewController {
    
    var rootComment: PSPDFAnnotation?
    var templateAnnotation: PSPDFAnnotation?
    var comments = [PSPDFAnnotation]()
    var pdfDocument: PSPDFDocument!
    var newThread: Bool = false
    
    var tableView: UITableView!
    var replyToolbar: CommentReplyView!
    var replyToolbarBottom: NSLayoutConstraint?
    
    static func new(rootComment: PSPDFAnnotation? = nil, pdfDocument: PSPDFDocument) -> CanvadocsCommentsViewController {
        let vc = CanvadocsCommentsViewController(nibName: nil, bundle: nil)
        vc.rootComment = rootComment
        vc.pdfDocument = pdfDocument
        vc.tableView = UITableView(frame: CGRectZero, style: .Plain)
        vc.replyToolbar = CommentReplyView.instantiate()
        return vc
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        view.addSubview(replyToolbar)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tableView": tableView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]-0-[replyToolbar]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tableView": tableView, "replyToolbar": replyToolbar]))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48.0
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "CommentTableViewCell", bundle: NSBundle(forClass: self.classForCoder)), forCellReuseIdentifier: "CommentCell")
        tableView.contentInset = UIEdgeInsets(top: tableView.contentInset.top + 10, left: tableView.contentInset.left, bottom: tableView.contentInset.bottom + 10, right: tableView.contentInset.right)
        tableView.dataSource = self
        
        replyToolbar.sendAction = { [unowned self] in
            if self.replyToolbar.replyTextView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 { // make sure they actually entered something
                // Cases to handle:
                // 1. Contents string on a non note type like a box or highlight
                // 2. New note
                // 3. Reply
                
                // If we can just set the contents in place, without adding a new annotation
                if self.rootComment != nil && (self.rootComment?.contents == nil || self.rootComment?.contents == "") && self.rootComment?.dynamicType !== PSPDFNoteAnnotation.self {
                    self.rootComment?.contents = self.replyToolbar.replyTextView.text
                    self.comments.append(self.rootComment!)
                    NSNotificationCenter.defaultCenter().postNotificationName(PSPDFAnnotationChangedNotification, object: self.rootComment!, userInfo: [PSPDFAnnotationChangedNotificationKeyPathKey: ["contents"]])
                    do {
                        try self.pdfDocument.saveAnnotations()
                    } catch {}
                } else if self.rootComment == nil {
                    self.rootComment = PSPDFNoteAnnotation(contents: self.replyToolbar.replyTextView.text)
                    self.rootComment?.boundingBox = self.templateAnnotation?.boundingBox ?? CGRectZero
                    self.rootComment?.page = self.templateAnnotation?.page ?? 0
                    self.rootComment?.user = self.templateAnnotation?.user
                    self.rootComment?.editable = self.templateAnnotation?.editable ?? true
                    self.comments.append(self.rootComment!)
                    self.pdfDocument.addAnnotations([self.rootComment!], options: [PSPDFAnnotationOptionUserCreatedKey:true])
                    self.newThread = false
                } else {
                    if let firstComment = self.comments.first {
                        // There must be some text on it already, so this must be a reply
                        let newAnnotation = CanvadocsCommentReplyAnnotation(contents: self.replyToolbar.replyTextView.text)
                        newAnnotation.page = firstComment.page ?? 0
                        newAnnotation.boundingBox = firstComment.boundingBox ?? CGRectZero
                        newAnnotation.inReplyTo = firstComment.name
                        self.comments.append(newAnnotation)
                        self.pdfDocument.addAnnotations([newAnnotation], options: [PSPDFAnnotationOptionUserCreatedKey:true])
                    }
                    
                }
                self.replyToolbar.clearText()
                self.tableView.reloadData()
            }
        }
        replyToolbar.translatesAutoresizingMaskIntoConstraints = false
        replyToolbarBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: replyToolbar, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
        view.addConstraint(replyToolbarBottom!)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[replyToolbar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["replyToolbar": replyToolbar]))
        
        navigationItem.title = NSLocalizedString("Comments", tableName: "Localizable", bundle: NSBundle(forClass: self.dynamicType), value: "", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(CanvadocsCommentsViewController.close(_:)))
        if rootComment?.editable ?? true {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(CanvadocsCommentsViewController.trash(_:)))
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CanvadocsCommentsViewController.showingKeyboard(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CanvadocsCommentsViewController.hidingKeyboard(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        if rootComment?.contents == nil || rootComment?.contents == "" {
            replyToolbar.replyTextView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func close(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func trash(sender: UIBarButtonItem) {
        if let rootComment = rootComment {
            pdfDocument.removeAnnotations([rootComment], options: [:])
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CanvadocsCommentsViewController: UITableViewDataSource {
    func annotationForIndex(index: NSInteger) -> PSPDFAnnotation? {
        return comments[index]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell") as! CommentTableViewCell
        
        if let annotation = annotationForIndex(indexPath.row) {
            cell.userLabel.text = annotation.user
            cell.commentLabel.text = annotation.contents
        }
        
        return cell
    }
}

// ---------------------------------------------
// MARK: - Keyboard Handling
// ---------------------------------------------
extension CanvadocsCommentsViewController {
    func showingKeyboard(notification: NSNotification) {
        let info = notification.userInfo as! [String: AnyObject]
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let animationCurve = UIViewAnimationOptions(rawValue: (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber) as UInt)
        let animationDuration: NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardHeight = keyboardFrame.height
        
        // We do this before the animation and again during the animation, which forces the tableView to first figure out how big it is (cuz esimatedRowHeight)
        // and then again to do the animation once it actually knows
        if self.tableView(self.tableView, numberOfRowsInSection: 0) > 0 {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: max(self.tableView(tableView, numberOfRowsInSection: 0)-1, 0), inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        }
        
        self.replyToolbarBottom?.constant = keyboardHeight
        UIView.animateWithDuration(animationDuration, delay: 0, options: animationCurve, animations: {
            self.view.layoutIfNeeded()
            if self.tableView(self.tableView, numberOfRowsInSection: 0) > 0 {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.tableView(self.tableView, numberOfRowsInSection: 0)-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
            }
        }, completion: nil)
    }
    
    func hidingKeyboard(notification: NSNotification) {
        let info = notification.userInfo as! [String: AnyObject]
        let animationCurve = UIViewAnimationOptions(rawValue: (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber) as UInt)
        let animationDuration: NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        self.replyToolbarBottom?.constant = 0.0
        UIView.animateWithDuration(animationDuration, delay: 0, options: animationCurve, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

