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
import SoPretty
import ReactiveSwift
import Result
import TooLegit
import SoPersistent

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

open class FileUploadsViewController: FileUpload.TableViewController, UIDocumentMenuDelegate, UIDocumentPickerDelegate, FileUploadActionDelegate, FileUploadTableViewCellDelegate {
    fileprivate let viewModel: FileUploadsViewModelType = FileUploadsViewModel()
    public weak var delegate: FileUploadsViewControllerDelegate?

    open lazy var doneButton: UIBarButtonItem = {
        let title = NSLocalizedString("Done", tableName: "Localizable", bundle: .fileKit, value: "", comment: "")
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

    open func add(uploadable: Uploadable) {
        self.viewModel.inputs.add(uploadable: uploadable)
    }

    open func cancel() {
        self.viewModel.inputs.tappedCancel()
    }

    open func done() {
        self.viewModel.inputs.tappedDone()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("File Uploads", tableName: "Localizable", bundle: .fileKit, value: "", comment: "File uploads screen title")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48.0
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        tableView.preservesSuperviewLayoutMargins = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFile))

        bindViewModel()
        viewModel.inputs.viewDidLoad()
    }

    private func bindViewModel() {
        self.viewModel.outputs.showDocumentMenu
            .observe(on: UIScheduler())
            .observeValues { [weak self] allowedUTIs, fileUploadActions in
                self?.showDocumentMenu(allowedUTIs: allowedUTIs, fileUploadActions: fileUploadActions)
            }

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
    }

    private func showDocumentMenu(allowedUTIs: [String], fileUploadActions: [FileUploadAction]) {
        let docsMenu = UIDocumentMenuViewController(documentTypes: allowedUTIs, in: .import)
        docsMenu.delegate = self
        docsMenu.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem

        for var action in fileUploadActions {
            action.delegate = self
            docsMenu.addOption(withTitle: action.title, image: action.icon, order: .first, handler: action.initiate)
        }

        self.present(docsMenu, animated: true, completion: nil)
    }

    fileprivate func showDataError() {
        let errorMessage = NSLocalizedString("Something went wrong. Check the file format and try again.", tableName: "Localizable", bundle: .fileKit, value: "", comment: "Error message displayed when the file is unrecognized.")
        self.show(error: errorMessage)
    }

    fileprivate func show(error message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", tableName: "Localizable", bundle: .fileKit, value: "", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Need this for delete edit action.
    }

    override open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", tableName: "Localizable", bundle: .fileKit, value: "", comment: "Delete button for file upload")) { action, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: FileUploadTableViewCellViewModel.identifier) as! FileUploadTableViewCell
            cell.deleteUpload()
        }]
    }

    // MARK: - UIDocumentMenuDelegate

    open func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }


    // MARK: - UIDocumentPickerDelegate

    open func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            self.showDataError()
            return
        }

        viewModel.inputs.add(uploadable: NewFileUpload(kind: .fileURL(url), data: data))
    }

    // MARK: - FileUploadActionDelegate

    func fileUploadActionDidCancel(_ fileUploadAction: FileUploadAction) {}

    func fileUploadActionFailedToConvertData(_ fileUploadAction: FileUploadAction) {
        self.showDataError()
    }

    func fileUploadAction(_ fileUploadAction: FileUploadAction, finishedWith uploadable: Uploadable) {
        self.add(uploadable: uploadable)
    }

    func fileUploadAction(_ fileUploadAction: FileUploadAction, wantsToPresent viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }

    // MARK: - FileUploadTableViewCellDelegate

    func fileUploadTableViewCell(_ cell: FileUploadTableViewCell, needsToDisplay errorMessage: String) {
        self.show(error: errorMessage)
    }
}
