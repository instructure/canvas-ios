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
    
    

import Foundation
import WhizzyWig
import SoLazy


protocol NewUploadViewControllerDelegate: class {
    func newUploadCancelled()
    func turnInUpload()
    func addFileToNewUpload()
    func newUploadModified(_ upload: NewUpload)
}

class NewUploadViewController: UITableViewController {
    
    var newUpload: NewUpload = .none {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    fileprivate var textCellHeight: CGFloat = 100.0
    
    weak var delegate: NewUploadViewControllerDelegate?
    
    
    class func presentFromViewController(_ viewController: UIViewController) -> NewUploadViewController {
        let bundle = Bundle(for: self.classForCoder())
        let storyboard = UIStoryboard(name: "NewUpload", bundle: bundle)
        
        let nav = storyboard.instantiateInitialViewController() as! UINavigationController
        let me = nav.viewControllers[0] as! NewUploadViewController
        
        viewController.present(nav, animated: true, completion: nil)
        
        return me
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            tableView.backgroundColor = UIColor.clear
            let blurEffect = UIBlurEffect(style: .extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            tableView.backgroundView = blurEffectView
            
            //if inside a popover
            if let popover = navigationController?.popoverPresentationController {
                popover.backgroundColor = UIColor.clear
            }
            
            //if you want translucent vibrant table view separator lines
            tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
            tableView.separatorInset = UIEdgeInsets.zero
        }
        
        tableView.register(NewUploadTextCell.classForCoder(), forCellReuseIdentifier: "TextCell")
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func submit(_ sender: AnyObject) {
        self.dismiss(animated: true) {
            self.delegate?.turnInUpload()
        }

        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NewUploadTextCell {
            cell.textView.resignFirstResponder()
        }
    }
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true) {
            self.delegate?.newUploadCancelled()
        }
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? NewUploadTextCell {
            cell.textView.resignFirstResponder()
        }
    }
}

extension NewUpload {
    var numberOfRows: Int {
        switch self {
        case .none: return 0
        case .fileUpload(let urls): return urls.count + 1
        case .mediaComment(_): return 2
        default: return 1
        }
    }
    
    func cellHeightInController(_ controller: NewUploadViewController, atIndex index: Int) -> CGFloat {
        switch self {
        case .text:
            return controller.textCellHeight
        default:
            return 44.0;
        }
    }
    
    func isRowEditable(_ row: Int) -> Bool {
        switch self {
        case .fileUpload(let urls):
            return row < urls.count
        default:
            return false
        }
    }
}


// MARK: tableView data source/delegate

extension NewUploadViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return newUpload.cellHeightInController(self, atIndex: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newUpload.numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        func cellForNewFileUploads(_ newUploadFiles: [NewUploadFile]) -> UITableViewCell {
            if indexPath.row >= newUploadFiles.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddAFileCell") as! AddAFileNewUploadCell
                cell.addFileTapped = { [weak self] in
                    if let me = self, let delegate = me.delegate {
                        me.dismiss(animated: true) {
                            delegate.addFileToNewUpload()
                        }
                    }
                }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell") else { ❨╯°□°❩╯⌢"No FileCell registered" }
                let uploadFile = newUploadFiles[indexPath.row]
                cell.textLabel?.text = uploadFile.name
                cell.imageView?.image = uploadFile.image
                return cell
            }
        }
        switch newUpload {
        case .none: ❨╯°□°❩╯⌢"There are 0 rows for .None"
        case .fileUpload(let newUploadFiles):
            return cellForNewFileUploads(newUploadFiles)
        case .mediaComment(let newUploadFile):
            return cellForNewFileUploads([newUploadFile])
        case .text(let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell") as! NewUploadTextCell
            cell.placeholder.text = NSLocalizedString("Enter your upload...", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.FileKit")!, value: "", comment: "Prompt for text upload")
            cell.textView.text = text
            cell.heightDidChange = { [weak self] height in
                self?.textCellHeight = height
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            cell.textDidChange = { [weak self] text in
                if let me = self {
                    me.newUpload = .text(text)
                    me.delegate?.newUploadModified(me.newUpload)
                }
            }
            return cell
        default:
            guard let add = tableView.dequeueReusableCell(withIdentifier: "AddAFileCell") else { ❨╯°□°❩╯⌢"No AddAFileCell registered" }
            return add
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let textCell = cell as? NewUploadTextCell {
            textCell.textView.becomeFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return newUpload.isRowEditable(indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Ignore this... but don't delete it
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if newUpload.isRowEditable(indexPath.row) {
            return [UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.FileKit")!, value: "", comment: "Delete button for file upload")) { [weak self] action, indexPath in
                
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
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
        selectedBackgroundView = selectedView
    }
}

class AddAFileNewUploadCell: NewUploadClearCell {
    var addFileTapped: ()->() = {}
    
    @IBAction func addFileButtonTapped(_ sender: AnyObject) {
        addFileTapped()
    }
}

class NewUploadTextCell: WhizzyTextInputCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        textView.backgroundColor = UIColor.clear
        
        separatorInset = UIEdgeInsets(top: 0, left: 2000, bottom: 0, right: 0)
    }
    
    required init(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"Registered by class... so don't do this"
    }
}
