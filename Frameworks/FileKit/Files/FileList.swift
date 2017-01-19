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
    
    

import FileKit
import SoPersistent
import TooLegit
import CoreData
import MobileCoreServices
import ReactiveSwift

struct FileViewModel: TableViewCellViewModel {
    static let fileReuseIdentifier = "FileCell"
    static let fileNibName = "FileCell"
    static let folderReuseIdentifier = "FolderCell"
    static let folderNibName = "FolderCell"
    
    let name: String
    
    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: FileViewModel.fileReuseIdentifier)
    }
    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FileViewModel.fileReuseIdentifier, for: indexPath as IndexPath)
        cell.textLabel!.text = name
        return cell
    }
    
    init(fileNode: FileNode) {
        name = fileNode.name
    }
}

class FileList: FileNode.TableViewController {
    var contextID: ContextID
    let session: Session
    let folderID: String?
    let observer: ManagedObjectObserver<FileUpload>
    let fileUploadCollection: FetchedCollection<FileUpload>
    var backgroundSession: Session
    
    fileprivate var uploadBuilder: UploadBuilder?
    
    @IBOutlet var newWordField: UITextField?
    
    init(session: Session, contextID: ContextID, hiddenForUser: Bool, folderID: String?) throws {
        self.session = session
        self.contextID = contextID
        self.folderID = folderID
//        let uploadIdentifier = File.uploadIdentifier(self.folderID)
//        self.backgroundSession = session.copyToBackgroundSessionWithIdentifier(uploadIdentifier, sharedContainerIdentifier: nil)
        self.backgroundSession = session
        self.observer = try File.observer(session, backgroundSessionID: self.backgroundSession.sessionID)
        self.fileUploadCollection = try FileUpload.fetchCollection(session, contextID: contextID, folderID: folderID)
        super.init()
        observer.signal.observeValues { _, object in
            guard let upload = object else { return }
            if let error = upload.errorMessage {
                print(error)
                return
            }
            if upload.hasCompleted {
                print("completed")
            }
        }
        fileUploadCollection.collectionUpdates.observe(on: UIScheduler()).observeValues { updates in
            self.processCollectionUpdates(updates)
        }
        let collection = try FileNode.fetchCollection(session, contextID: contextID, hiddenForUser: hiddenForUser, folderID: folderID)
        let refresher = try FileNode.refresher(session, contextID: contextID, hiddenForUser: hiddenForUser, folderID: folderID)
        prepare(collection, refresher: refresher, viewModelFactory: FileViewModel.init, didDeleteItemAtIndexPath: deleteFileNode)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        self.navigationItem.title = NSLocalizedString("Files", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.FileKit")!, value: "", comment: "Title of files list")
    }
    
    func processCollectionUpdates(_ updates: [CollectionUpdate<FileUpload>]) {
        var sentSum = 0
        var totalSum = 0
        for update in updates {
            switch update {
            case .updated(_, let upload, _):
                let sent = upload.sent
                let total = upload.total
                if total > 0 {
                    print(upload.name + " (" + String(describing: upload.objectID) + ") upload status: " + String(Int(Double(100*sent/total))) + "%")
                }
                sentSum += Int(sent)
                totalSum += Int(total)
            default: break
            }
        }
//        if totalSum > 0 {
//            let percentage = String(Int(Double(100*sentSum/totalSum)))
//            print("total upload status: " + percentage + "%")
//        }
    }
    
    func addTapped() {
        let uploadTypeAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        uploadTypeAlert.addAction(UIAlertAction(title: "Add Folder", style: .default, handler: { (action: UIAlertAction!) in
            self.requestFolderName()
        }))
        uploadTypeAlert.addAction(UIAlertAction(title: "Upload File", style: .default, handler: { (action: UIAlertAction!) in
            self.uploadFile()
        }))
        uploadTypeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(uploadTypeAlert, animated: true, completion: nil)
    }
    
    fileprivate func requestFolderName() {
        var textField: UITextField?
        let folderNameAlert = UIAlertController(title: "New Folder", message: "Choose a name for the new folder", preferredStyle: .alert)
        folderNameAlert.addTextField { (field) in
            textField = field
        }
        folderNameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        folderNameAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction!) in
            if let textField = textField, let text = textField.text, !text.isEmpty {
                Folder.newFolder(self.session, contextID: self.contextID, folderID: self.folderID, name: text).startWithFailed { [weak self] error in
                    self?.handleError(error)
                }
            } else {
                Folder.newFolder(self.session, contextID: self.contextID, folderID: self.folderID, name: "New Folder").startWithFailed { [weak self] error in
                    self?.handleError(error)
                }
            }
        }))
        present(folderNameAlert, animated: true, completion: nil)
    }
    
    fileprivate func uploadFile() {
        let images = [kUTTypeImage as String]
        let video = [kUTTypeMovie as String]
        let allowedImagePickerControllerMediaTypes: [String] = images + video
        let allowedSubmissionUTIs = [kUTTypeItem as String]
        let builder = UploadBuilder(viewController: self, barButtonItem: nil, submissionTypes: nil, allowsAudio: false, allowsPhotos: true, allowsVideo: true, allowedUploadUTIs: allowedSubmissionUTIs, allowedImagePickerControllerMediaTypes: allowedImagePickerControllerMediaTypes)
        builder.uploadSelected = { newUpload in
            switch newUpload {
            case .fileUpload(let newUploadFiles):
                do {
                    try File.uploadFile(inSession: self.session, newUploadFiles: newUploadFiles, folderID: self.folderID, contextID: self.contextID, backgroundSession: self.backgroundSession)
                } catch let error as NSError {
                    self.handleError(error)
                }
                
            default: break // we only care about FileUploads
            }
        }
        uploadBuilder = builder
        builder.beginUpload()
    }
    
    fileprivate func deleteFileNode(_ indexPath: IndexPath) {
        let fileNode: FileNode = collection[indexPath]
        if fileNode.isFolder {
            let folder: Folder = fileNode as! Folder
            if folder.filesCount + folder.foldersCount > 0 {
                deleteConfirmationAlert(folder)
            } else {
                deleteFolder(folder, shouldForce: false)
            }
        } else {
            let file: File = fileNode as! File
            do {
                try file.deleteFileNode(session, shouldForce: false).startWithFailed { error in
                    self.handleError(error)
                }
            } catch let error as NSError {
               self.handleError(error)
            }
        }
    }
    
    fileprivate func deleteFolder(_ folder: Folder, shouldForce: Bool) {
        do {
            try folder.deleteFileNode(session, shouldForce: shouldForce).startWithFailed { error in
                self.handleError(error)
            }
        } catch let error as NSError {
            self.handleError(error)
        }
        
    }
    
    fileprivate func deleteConfirmationAlert(_ folder: Folder) {
        let alert = UIAlertController(title: "Warning", message: "Some selected folders are not empty. Are you sure you want to delete them?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Don't delete", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteFolder(folder, shouldForce: true)
        }))
        present(alert, animated: true, completion: { () in
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileNode: FileNode = collection[indexPath]
        if !fileNode.isFolder {
            let file: File = fileNode as! File
            do {
                let deets = File.DetailViewController(session: session, file: file)
                navigationController?.pushViewController(deets, animated: true)
            }
        } else {
            let folder: Folder = fileNode as! Folder
            do {
                let vc = try! FileList(session: session, contextID: contextID, hiddenForUser: folder.hiddenForUser, folderID: folder.id)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
