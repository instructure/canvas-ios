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

import ReactiveSwift
import Result



public protocol FileUploadsViewControllerDelegate: class {
    func fileUploadsViewController(_ viewController: FileUploadsViewController, uploaded files: [File])
    func fileUploadsViewControllerDidCancel(_ viewController: FileUploadsViewController)
}

struct FileUploadTableViewCellViewModel: TableViewCellViewModel {
    static let identifier = "FileUploadCell"

    let session: Session
    let fileUpload: FileUpload
    let delegate: FileUploadTableViewCellDelegate?

    static func tableViewDidLoad(_ tableView: UITableView) {
        tableView.register(FileUploadTableViewCell.self, forCellReuseIdentifier: identifier)
    }

    func cellForTableView(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FileUploadTableViewCellViewModel.identifier) as! FileUploadTableViewCell
        cell.configureWith(fileUpload: fileUpload, session: session)
        cell.delegate = delegate
        return cell
    }
}

open class FileUploadsViewController: FetchedTableViewController<FileUpload>, UIDocumentMenuDelegate, UIDocumentPickerDelegate, DocumentMenuController, FileUploadTableViewCellDelegate {
    fileprivate let viewModel: FileUploadsViewModelType = FileUploadsViewModel()
    public let documentMenuViewModel: DocumentMenuViewModelType = DocumentMenuViewModel()
    public weak var delegate: FileUploadsViewControllerDelegate?

    public lazy var showDocumentMenu: Signal<[String], NoError> = {
        return self.viewModel.outputs.showDocumentMenu
    }()

    open lazy var doneButton: UIBarButtonItem = {
        let title = NSLocalizedString("Done", tableName: "Localizable", bundle: .core, value: "", comment: "")
        let btn = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(done))
        return btn
    }()

    open lazy var cancelButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        return btn
    }()

    public static func configuredWith(session: Session, batch: FileUploadBatch) -> FileUploadsViewController {
        let  me = FileUploadsViewController(style: .plain)
        me.viewModel.outputs.fileUploads
            .observe(on: UIScheduler())
            .observeValues { [weak me] collection in
                me?.prepare(collection) { fileUpload -> FileUploadTableViewCellViewModel in
                    return FileUploadTableViewCellViewModel(session: session, fileUpload: fileUpload, delegate: me)
                }
            }

        me.viewModel.inputs.configureWith(session: session, batch: batch)

        return me
    }
    
    open func addFile() {
        self.viewModel.inputs.tappedAddFile()
    }

    open func cancel() {
        self.viewModel.inputs.tappedCancel()
    }

    open func done() {
        self.viewModel.inputs.tappedDone()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("File Uploads", tableName: "Localizable", bundle: .core, value: "", comment: "File uploads screen title")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48.0
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        tableView.preservesSuperviewLayoutMargins = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFile))

        bindViewModel()
        bindDocumentMenuViewModel()
        viewModel.inputs.viewDidLoad()
    }

    private func bindViewModel() {
        self.viewModel.outputs.dismissButtonType
            .observe(on: UIScheduler())
            .observeValues { [weak self] dismissButtonType in
                switch dismissButtonType {
                case .done:
                    self?.navigationItem.rightBarButtonItem = self?.doneButton
                case .cancel:
                    self?.navigationItem.rightBarButtonItem = self?.cancelButton
                }
            }

        self.viewModel.outputs.cancelled
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                if let me = self {
                    me.delegate?.fileUploadsViewControllerDidCancel(me)
                }
            }

        self.viewModel.outputs.files
            .observe(on: UIScheduler())
            .observeValues { [weak self] files in
                if let me = self {
                    me.delegate?.fileUploadsViewController(me, uploaded: files)
                }
            }

        self.bindDocumentMenuViewModel()
    }

    fileprivate func showDataError() {
        let errorMessage = NSLocalizedString("Something went wrong. Check the file format and try again.", tableName: "Localizable", bundle: .core, value: "", comment: "Error message displayed when the file is unrecognized.")
        self.show(error: errorMessage)
    }

    fileprivate func show(error message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", tableName: "Localizable", bundle: .core, value: "", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Need this for delete edit action.
    }

    override open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", tableName: "Localizable", bundle: .core, value: "", comment: "Delete button for file upload")) { action, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: FileUploadTableViewCellViewModel.identifier) as! FileUploadTableViewCell
            cell.deleteUpload()
        }]
    }

    // MARK: - DocumentMenuController

    public func documentMenuFinished(error: NSError) {
        self.show(error: error.localizedDescription)
    }

    public func documentMenuFinished(uploadable: Uploadable) {
        self.viewModel.inputs.add(uploadable: uploadable)
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        controller.dismiss(animated: true) {
            self.documentMenuViewModel.inputs.pickedDocument(at: url)
        }
    }

    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        self.documentMenuViewModel.inputs.tappedDocumentPicker(documentPicker)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            self.documentMenuViewModel.inputs.pickedMedia(with: info)
        }
    }

    // MARK: - FileUploadTableViewCellDelegate

    func fileUploadTableViewCell(_ cell: FileUploadTableViewCell, needsToDisplay errorMessage: String) {
        self.show(error: errorMessage)
    }
}
