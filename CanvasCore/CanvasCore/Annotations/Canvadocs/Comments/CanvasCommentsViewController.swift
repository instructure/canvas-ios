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
import PSPDFKit

class CanvadocsCommentsViewController: UIViewController {
    
    @objc var annotation: PSPDFAnnotation!
    @objc var comments = [CanvadocsCommentReplyAnnotation]()
    @objc var pdfDocument: PSPDFDocument!
    var metadata: CanvadocsAnnotationMetadata!
    
    @objc var tableView: UITableView!
    @objc var replyToolbar: CommentReplyView!
    @objc var replyToolbarBottom: NSLayoutConstraint?
    
    static func new(_ annotation: PSPDFAnnotation, pdfDocument: PSPDFDocument, metadata: CanvadocsAnnotationMetadata) -> CanvadocsCommentsViewController {
        let vc = CanvadocsCommentsViewController(nibName: nil, bundle: nil)
        vc.annotation = annotation
        vc.pdfDocument = pdfDocument
        vc.metadata = metadata
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
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["tableView": tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]-0-[replyToolbar]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["tableView": tableView, "replyToolbar": replyToolbar]))
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 48.0
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: Bundle(for: self.classForCoder)), forCellReuseIdentifier: "CommentCell")
        tableView.contentInset = UIEdgeInsets(top: tableView.contentInset.top + 10, left: tableView.contentInset.left, bottom: tableView.contentInset.bottom + 10, right: tableView.contentInset.right)
        tableView.dataSource = self
        
        comments = comments.sorted(by: { (comment1, comment2) in
            return comment1.creationDate ?? Date() < comment2.creationDate ?? Date()
        })
        
        let permissions = metadata.permissions ?? .None
        if permissions == .ReadWrite || permissions == .ReadWriteManage {
            replyToolbar.isHidden = false
            replyToolbar.sendAction = { [unowned self] in
                if !self.replyToolbar.replyTextView.text.isEmpty { // make sure they actually entered something
                    let newAnnotation = CanvadocsCommentReplyAnnotation(contents: self.replyToolbar.replyTextView.text)
                    newAnnotation.pageIndex = self.annotation.pageIndex
                    newAnnotation.inReplyToName = self.annotation.name
                    newAnnotation.user = self.metadata.userID
                    newAnnotation.userName = self.metadata.userName
                    self.comments.append(newAnnotation)
                    self.pdfDocument.add([newAnnotation], options: [:])
                    self.replyToolbar.clearText()
                    self.tableView.reloadData()
                }
            }
            replyToolbar.translatesAutoresizingMaskIntoConstraints = false
            replyToolbarBottom = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: replyToolbar, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0)
            view.addConstraint(replyToolbarBottom!)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[replyToolbar]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["replyToolbar": replyToolbar]))
        } else {
            replyToolbar.isHidden = true
        }
        
        navigationItem.title = NSLocalizedString("Comments", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CanvadocsCommentsViewController.close(_:)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(CanvadocsCommentsViewController.showingKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CanvadocsCommentsViewController.hidingKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        replyToolbar.replyTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func close(_ sender: UIBarButtonItem) {
        let deleted = comments.filter({ $0.isDeleted })
        if deleted.count > 0 {
            pdfDocument.remove(deleted, options: nil)
        }
        dismiss(animated: true, completion: nil)
    }

    override var prefersStatusBarHidden: Bool { return true }
}

extension CanvadocsCommentsViewController: CommentTableViewCellDelegate {
    @objc func didTapDelete(_ sender: UIButton, reply: CanvadocsCommentReplyAnnotation) {
        let alert = UIAlertController(title: NSLocalizedString("Delete Comment", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: ""), message: NSLocalizedString("Are you sure you would like to delete this comment?", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", tableName: "Localizable", bundle: Bundle(for: type(of: self)), value: "", comment: ""), style: .destructive, handler: { _ in
            guard let index = self.comments.index(of: reply) else { return }
            self.pdfDocument.remove([reply], options: [:])
            self.comments.remove(at: index)
            self.tableView.reloadData()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension CanvadocsCommentsViewController: UITableViewDataSource {
    @objc func annotationForIndex(_ index: NSInteger) -> CanvadocsCommentReplyAnnotation? {
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
            cell.set(annotation: annotation, delegate: self, metadata: metadata)
        }
        
        return cell
    }
}

// ---------------------------------------------
// MARK: - Keyboard Handling
// ---------------------------------------------
extension CanvadocsCommentsViewController {
    @objc func showingKeyboard(_ notification: Notification) {
        let info = notification.userInfo as! [String: AnyObject]
        let keyboardFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let animationCurve = UIView.AnimationOptions(rawValue: (info[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue)
        let animationDuration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardHeight = keyboardFrame.height
        
        // We do this before the animation and again during the animation, which forces the tableView to first figure out how big it is (cuz esimatedRowHeight)
        // and then again to do the animation once it actually knows
        if self.tableView(self.tableView, numberOfRowsInSection: 0) > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: max(self.tableView(tableView, numberOfRowsInSection: 0)-1, 0), section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
        }
        
        self.replyToolbarBottom?.constant = keyboardHeight
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.view.layoutIfNeeded()
            if self.tableView(self.tableView, numberOfRowsInSection: 0) > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: self.tableView(self.tableView, numberOfRowsInSection: 0)-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
            }
        }, completion: nil)
    }
    
    @objc func hidingKeyboard(_ notification: Notification) {
        let info = notification.userInfo as! [String: AnyObject]
        let animationCurve = UIView.AnimationOptions(rawValue: (info[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue)
        let animationDuration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        self.replyToolbarBottom?.constant = 0.0
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

