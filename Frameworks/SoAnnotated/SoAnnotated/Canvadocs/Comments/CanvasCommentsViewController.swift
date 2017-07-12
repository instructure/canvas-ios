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
    
    static func new(_ rootComment: PSPDFAnnotation? = nil, pdfDocument: PSPDFDocument) -> CanvadocsCommentsViewController {
        let vc = CanvadocsCommentsViewController(nibName: nil, bundle: nil)
        vc.rootComment = rootComment
        vc.pdfDocument = pdfDocument
        vc.tableView = UITableView(frame: CGRect.zero, style: .plain)
        vc.replyToolbar = CommentReplyView.instantiate()
        return vc
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        view.addSubview(replyToolbar)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tableView": tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]-0-[replyToolbar]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tableView": tableView, "replyToolbar": replyToolbar]))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48.0
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: Bundle(for: self.classForCoder)), forCellReuseIdentifier: "CommentCell")
        tableView.contentInset = UIEdgeInsets(top: tableView.contentInset.top + 10, left: tableView.contentInset.left, bottom: tableView.contentInset.bottom + 10, right: tableView.contentInset.right)
        tableView.dataSource = self
        
        replyToolbar.sendAction = { [unowned self] in
            if self.replyToolbar.replyTextView.text.lengthOfBytes(using: String.Encoding.utf8) > 0 { // make sure they actually entered something
                // Cases to handle:
                // 1. Contents string on a non note type like a box or highlight
                // 2. New note
                // 3. Reply
                
                // If we can just set the contents in place, without adding a new annotation
                if let root = self.rootComment, (root.contents == nil || root.contents == "") && type(of: root) !== PSPDFNoteAnnotation.self {
                    self.rootComment?.contents = self.replyToolbar.replyTextView.text
                    self.comments.append(self.rootComment!)
                    NotificationCenter.default.post(name: NSNotification.Name.PSPDFAnnotationChanged, object: self.rootComment!, userInfo: [PSPDFAnnotationChangedNotificationKeyPathKey: ["contents"]])
                    do {
                        try self.pdfDocument.save()
                    } catch {}
                } else if self.rootComment == nil {
                    self.rootComment = PSPDFNoteAnnotation(contents: self.replyToolbar.replyTextView.text)
                    self.rootComment?.boundingBox = self.templateAnnotation?.boundingBox ?? CGRect.zero
                    self.rootComment?.pageIndex = self.templateAnnotation?.pageIndex ?? 0
                    self.rootComment?.user = self.templateAnnotation?.user
                    self.rootComment?.isEditable = self.templateAnnotation?.isEditable ?? true
                    self.comments.append(self.rootComment!)
                    self.pdfDocument.add([self.rootComment!], options: [:])
                    self.newThread = false
                } else {
                    if let firstComment = self.comments.first {
                        // There must be some text on it already, so this must be a reply
                        let newAnnotation = CanvadocsCommentReplyAnnotation(contents: self.replyToolbar.replyTextView.text)
                        newAnnotation.pageIndex = firstComment.pageIndex
                        newAnnotation.boundingBox = firstComment.boundingBox
                        newAnnotation.inReplyTo = firstComment.name
                        self.comments.append(newAnnotation)
                        self.pdfDocument.add([newAnnotation], options: [:])
                    }
                    
                }
                self.replyToolbar.clearText()
                self.tableView.reloadData()
            }
        }
        replyToolbar.translatesAutoresizingMaskIntoConstraints = false
        replyToolbarBottom = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: replyToolbar, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
        view.addConstraint(replyToolbarBottom!)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[replyToolbar]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["replyToolbar": replyToolbar]))
        
        navigationItem.title = NSLocalizedString("Comments", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(CanvadocsCommentsViewController.close(_:)))
        if rootComment?.isEditable ?? true {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(CanvadocsCommentsViewController.trash(_:)))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(CanvadocsCommentsViewController.showingKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CanvadocsCommentsViewController.hidingKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if rootComment?.contents == nil || rootComment?.contents == "" {
            replyToolbar.replyTextView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func trash(_ sender: UIBarButtonItem) {
        if let rootComment = rootComment {
            pdfDocument.remove([rootComment], options: [:])
        }
        dismiss(animated: true, completion: nil)
    }
}

extension CanvadocsCommentsViewController: UITableViewDataSource {
    func annotationForIndex(_ index: NSInteger) -> PSPDFAnnotation? {
        return comments[index]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentTableViewCell
        
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
    func showingKeyboard(_ notification: Notification) {
        let info = notification.userInfo as! [String: AnyObject]
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let animationCurve = UIViewAnimationOptions(rawValue: (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber) as UInt)
        let animationDuration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardHeight = keyboardFrame.height
        
        // We do this before the animation and again during the animation, which forces the tableView to first figure out how big it is (cuz esimatedRowHeight)
        // and then again to do the animation once it actually knows
        if self.tableView(self.tableView, numberOfRowsInSection: 0) > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: max(self.tableView(tableView, numberOfRowsInSection: 0)-1, 0), section: 0), at: UITableViewScrollPosition.bottom, animated: false)
        }
        
        self.replyToolbarBottom?.constant = keyboardHeight
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.view.layoutIfNeeded()
            if self.tableView(self.tableView, numberOfRowsInSection: 0) > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: self.tableView(self.tableView, numberOfRowsInSection: 0)-1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
            }
        }, completion: nil)
    }
    
    func hidingKeyboard(_ notification: Notification) {
        let info = notification.userInfo as! [String: AnyObject]
        let animationCurve = UIViewAnimationOptions(rawValue: (info[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber) as UInt)
        let animationDuration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        self.replyToolbarBottom?.constant = 0.0
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

