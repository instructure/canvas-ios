//
// Copyright (C) 2018-present Instructure, Inc.
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
import Core
import MobileCoreServices

enum FilePickerSource: CaseIterable {
    case camera
    case library
    case files
}

protocol FilePickerViewProtocol: ErrorViewController {
    func update(files: [FileViewModel], sources: [FilePickerSource])
    func presentDocumentPicker(documentTypes: [String])
    func presentCamera()
    func presentLibrary()
    func updateTransferProgress(_ progress: Float, sent: Int64, expectedToSend: Int64)
    func updateToolbar(items: [UIBarButtonItem])
    func updateNavigationItems(left: [UIBarButtonItem], right: [UIBarButtonItem])
    func dismiss()
}

class FilePickerViewController: UIViewController, FilePickerViewProtocol {
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var libraryView: UIView!
    @IBOutlet weak var filesView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var progressView: FilePickerProgressView!
    @IBOutlet weak var sourcesView: UIView!
    @IBOutlet weak var dividerView: UIView!
    var submitButton: UIBarButtonItem?
    var files = [FileViewModel]()

    var presenter: FilePickerPresenterProtocol?

    static func create(env: AppEnvironment = .shared, presenter: FilePickerPresenterProtocol) -> FilePickerViewController {
        let controller = Bundle.loadController(self)
        controller.presenter = presenter
        presenter.view = controller
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Submission", comment: "")
        tableView.tableFooterView = UIView(frame: .zero)
        presenter?.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
    }

    func update(files: [FileViewModel], sources: [FilePickerSource]) {
        DispatchQueue.main.async {
            self.emptyView.isHidden = !files.isEmpty
            self.cameraView.isHidden = !sources.contains(.camera)
            self.libraryView.isHidden = !sources.contains(.library)

            self.files = files
            self.tableView.reloadData()
        }
    }

    func updateNavigationItems(left: [UIBarButtonItem], right: [UIBarButtonItem]) {
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItems = right
            self.navigationItem.leftBarButtonItems = left
        }
    }

    @IBAction
    func addFromCamera(_ sender: UIButton) {
        presenter?.add(fromSource: .camera)
    }

    @IBAction
    func addFromLibrary(_ sender: UIButton) {
        presenter?.add(fromSource: .library)
    }

    @IBAction
    func addFromFiles(_ sender: UIButton) {
        presenter?.add(fromSource: .files)
    }

    func presentDocumentPicker(documentTypes: [String]) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        documentPicker.delegate = self
        DispatchQueue.main.async {
            self.present(documentPicker, animated: true, completion: nil)
        }
    }

    func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = .camera
            cameraController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            cameraController.cameraCaptureMode = .photo
            DispatchQueue.main.async {
                self.present(cameraController, animated: true, completion: nil)
            }
        }
    }

    func presentLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let libraryController = UIImagePickerController()
            libraryController.delegate = self
            libraryController.sourceType = .photoLibrary
            libraryController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            DispatchQueue.main.async {
                self.present(libraryController, animated: true, completion: nil)
            }
        }
    }

    func updateTransferProgress(_ progress: Float, sent: Int64, expectedToSend: Int64) {
        DispatchQueue.main.async {
            let format = NSLocalizedString("Uploading %@ of %@", comment: "")
            self.progressView.text = String.localizedStringWithFormat(format, sent.humanReadableFileSize, expectedToSend.humanReadableFileSize)
            self.progressView.progress = progress
            self.toggleProgressBar(show: progress > 0 && progress < 1)
        }
    }

    private func toggleProgressBar(show: Bool) {
        show ? showProgressBar() : hideProgressBar()
    }

    private func showProgressBar() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4) {
            self.progressView?.isHidden = false
            self.view.layoutIfNeeded()
        }
    }

    private func hideProgressBar() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4) {
            self.progressView?.isHidden = true
            self.view.layoutIfNeeded()
        }
    }

    func updateToolbar(items: [UIBarButtonItem]) {
        DispatchQueue.main.async {
            self.setToolbarItems(items, animated: true)
            self.navigationController?.setToolbarHidden(items.isEmpty, animated: true)
            self.view.setNeedsLayout()
            self.showSources(items.isEmpty)
        }
    }

    func dismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func showSources(_ shown: Bool) {
        sourcesView.isHidden = !shown
        dividerView.isHidden = !shown
    }
}

extension FilePickerViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            presenter?.add(fromURL: url)
        }
    }
}

extension FilePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        presenter?.add(withCameraResult: info)
    }
}

extension FilePickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(FilePickerCell.self, for: indexPath)
        cell.file = files[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectFile(files[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
