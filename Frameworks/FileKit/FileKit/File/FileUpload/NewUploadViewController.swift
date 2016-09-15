//
//  NewUploadViewController.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 7/23/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import WhizzyWig
import SoLazy


protocol NewUploadViewControllerDelegate: class {
    func newUploadCancelled()
    func turnInUpload()
    func addFileToNewUpload()
    func newUploadModified(upload: NewUpload)
}

class NewUploadViewController: UITableViewController {
    
    var newUpload: NewUpload = .None {
        didSet {
            if isViewLoaded() {
                tableView.reloadData()
            }
        }
    }
    
    private var textCellHeight: CGFloat = 100.0
    
    weak var delegate: NewUploadViewControllerDelegate?
    
    
    class func presentFromViewController(viewController: UIViewController) -> NewUploadViewController {
        let bundle = NSBundle(forClass: self.classForCoder())
        let storyboard = UIStoryboard(name: "NewUpload", bundle: bundle)
        
        let nav = storyboard.instantiateInitialViewController() as! UINavigationController
        let me = nav.viewControllers[0] as! NewUploadViewController
        
        viewController.presentViewController(nav, animated: true, completion: nil)
        
        return me
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            tableView.backgroundColor = UIColor.clearColor()
            let blurEffect = UIBlurEffect(style: .ExtraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            tableView.backgroundView = blurEffectView
            
            //if inside a popover
            if let popover = navigationController?.popoverPresentationController {
                popover.backgroundColor = UIColor.clearColor()
            }
            
            //if you want translucent vibrant table view separator lines
            tableView.separatorEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
            tableView.separatorInset = UIEdgeInsetsZero
        }
        
        tableView.registerClass(NewUploadTextCell.classForCoder(), forCellReuseIdentifier: "TextCell")
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func submit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
            self.delegate?.turnInUpload()
        }

        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? NewUploadTextCell {
            cell.textView.resignFirstResponder()
        }
    }
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {
            self.delegate?.newUploadCancelled()
        }
        
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? NewUploadTextCell {
            cell.textView.resignFirstResponder()
        }
    }
}

extension NewUpload {
    var numberOfRows: Int {
        switch self {
        case .None: return 0
        case .FileUpload(let urls): return urls.count + 1
        case .MediaComment(_): return 2
        default: return 1
        }
    }
    
    func cellHeightInController(controller: NewUploadViewController, atIndex index: Int) -> CGFloat {
        switch self {
        case .Text:
            return controller.textCellHeight
        default:
            return 44.0;
        }
    }
    
    func isRowEditable(row: Int) -> Bool {
        switch self {
        case .FileUpload(let urls):
            return row < urls.count
        default:
            return false
        }
    }
}


// MARK: tableView data source/delegate

extension NewUploadViewController {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return newUpload.cellHeightInController(self, atIndex: indexPath.row)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newUpload.numberOfRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        func cellForNewFileUploads(newUploadFiles: [NewUploadFile]) -> UITableViewCell {
            if indexPath.row >= newUploadFiles.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("AddAFileCell") as! AddAFileNewUploadCell
                cell.addFileTapped = { [weak self] in
                    if let me = self, delegate = me.delegate {
                        me.dismissViewControllerAnimated(true) {
                            delegate.addFileToNewUpload()
                        }
                    }
                }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCellWithIdentifier("FileCell") else { ❨╯°□°❩╯⌢"No FileCell registered" }
                let uploadFile = newUploadFiles[indexPath.row]
                cell.textLabel?.text = uploadFile.name
                cell.imageView?.image = uploadFile.image
                return cell
            }
        }
        switch newUpload {
        case .None: ❨╯°□°❩╯⌢"There are 0 rows for .None"
        case .FileUpload(let newUploadFiles):
            return cellForNewFileUploads(newUploadFiles)
        case .MediaComment(let newUploadFile):
            return cellForNewFileUploads([newUploadFile])
        case .Text(let text):
            let cell = tableView.dequeueReusableCellWithIdentifier("TextCell") as! NewUploadTextCell
            cell.placeholder.text = NSLocalizedString("Enter your upload...", comment: "Prompt for text upload")
            cell.textView.text = text
            cell.heightDidChange = { [weak self] height in
                self?.textCellHeight = height
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            cell.textDidChange = { [weak self] text in
                if let me = self {
                    me.newUpload = .Text(text)
                    me.delegate?.newUploadModified(me.newUpload)
                }
            }
            return cell
        default:
            guard let add = tableView.dequeueReusableCellWithIdentifier("AddAFileCell") else { ❨╯°□°❩╯⌢"No AddAFileCell registered" }
            return add
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let textCell = cell as? NewUploadTextCell {
            textCell.textView.becomeFirstResponder()
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return newUpload.isRowEditable(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // Ignore this... but don't delete it
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if newUpload.isRowEditable(indexPath.row) {
            return [UITableViewRowAction(style: .Default, title: NSLocalizedString("Delete", comment: "Delete button for file upload")) { [weak self] action, indexPath in
                
                if let me = self {
                    me.newUpload = me.newUpload.uploadByDeletingFileAtIndex(indexPath.row)
                    me.delegate?.newUploadModified(me.newUpload)
                }
            }]
        }
        return []
    }
}



// MARK: Cells

class NewUploadClearCell: UITableViewCell {
    override func awakeFromNib() {
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        selectedBackgroundView = selectedView
    }
}

class AddAFileNewUploadCell: NewUploadClearCell {
    var addFileTapped: ()->() = {}
    
    @IBAction func addFileButtonTapped(sender: AnyObject) {
        addFileTapped()
    }
}

class NewUploadTextCell: WhizzyTextInputCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        textView.backgroundColor = UIColor.clearColor()
        
        separatorInset = UIEdgeInsets(top: 0, left: 2000, bottom: 0, right: 0)
    }
    
    required init(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"Registered by class... so don't do this"
    }
}