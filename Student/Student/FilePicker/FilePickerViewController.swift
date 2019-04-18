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
    case audio
}

protocol FilePickerControllerDelegate: class {
    func cancel(_ controller: FilePickerViewController)
    func submit(_ controller: FilePickerViewController)
    func retry(_ controller: FilePickerViewController)
    func add(_ controller: FilePickerViewController, url: URL)
    func canSubmit(_ controller: FilePickerViewController) -> Bool
}

class FilePickerViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var libraryView: UIView!
    @IBOutlet weak var filesView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var progressView: FilePickerProgressView!
    @IBOutlet weak var sourcesView: UIView!
    @IBOutlet weak var dividerView: UIView!

    var submitButtonTitle = NSLocalizedString("Submit", bundle: .student, comment: "")
    /// The cancel button that shows while the files are being uploaded
    var cancelButtonTitle = NSLocalizedString("Cancel", bundle: .student, comment: "")

    weak var delegate: FilePickerControllerDelegate?
    var sources = FilePickerSource.allCases
    var utis: [UTI] = [.any]
    var maxFiles: Int = .max
    var files: [File] = []

    static func create() -> FilePickerViewController {
        return loadFromStoryboard()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)

        cameraView.isHidden = !sources.contains(.camera)
        libraryView.isHidden = !sources.contains(.library)
        reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
    }

    func reload() {
        guard viewIfLoaded != nil else { return }
        emptyView.isHidden = !files.isEmpty
        updateProgressBar()
        updateBarButtons()
        updateSourceButtons()
        tableView.reloadData()
    }

    func updateProgressBar() {
        let total: Int = files.reduce(0, { $0 + $1.size })
        let sent = files.reduce(0, { $0 + $1.bytesSent })
        guard total > 0 && sent > 0 else {
            hideProgressBar()
            return
        }
        let progress = Float(sent) / Float(total)
        let format = NSLocalizedString("Uploading %@ of %@", bundle: .student, comment: "")
        progressView.text = String.localizedStringWithFormat(format, sent.humanReadableFileSize, total.humanReadableFileSize)
        progressView.progress = progress
    }

    func updateBarButtons() {
        let inProgress = files.first { $0.isUploading } != nil
        let failed = files.first { $0.uploadError != nil } != nil
        if inProgress {
            navigationController?.setToolbarHidden(false, animated: true)
            navigationItem.leftBarButtonItems = []
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", bundle: .student, comment: ""), style: .plain, target: self, action: #selector(close))
            toolbarItems = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: cancelButtonTitle, style: .plain, target: self, action: #selector(cancel)),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            ]
        } else if failed {
            navigationController?.setToolbarHidden(false, animated: true)
            navigationItem.leftBarButtonItems = []
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", bundle: .student, comment: ""), style: .plain, target: self, action: #selector(close))
            toolbarItems = [
                UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: .student, comment: ""), style: .plain, target: self, action: #selector(cancel)),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: NSLocalizedString("Retry", bundle: .student, comment: ""), style: .plain, target: self, action: #selector(retry)),
            ]
        } else {
            navigationController?.setToolbarHidden(true, animated: true)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: .student, comment: ""), style: .plain, target: self, action: #selector(cancel))
            let submitButton = UIBarButtonItem(title: submitButtonTitle, style: .plain, target: self, action: #selector(submit))
            submitButton.isEnabled = delegate?.canSubmit(self) == true
            navigationItem.rightBarButtonItem = submitButton
        }
    }

    func updateSourceButtons() {
        let inProgress = files.first { $0.isUploading } != nil
        let failed = files.first { $0.uploadError != nil } != nil
        let hideSourceButtons = files.count >= maxFiles || inProgress || failed
        sourcesView.isHidden = hideSourceButtons
        dividerView.isHidden = hideSourceButtons
    }

    @objc
    func close() {
        dismiss(animated: true, completion: nil)
    }

    @objc
    func cancel() {
        delegate?.cancel(self)
    }

    @objc
    func submit() {
        delegate?.submit(self)
    }

    @objc
    func retry() {
        delegate?.retry(self)
    }

    @IBAction
    func addFromCamera(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = .camera
            cameraController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            cameraController.cameraCaptureMode = .photo
            present(cameraController, animated: true, completion: nil)
        }
    }

    @IBAction
    func addFromLibrary(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let libraryController = UIImagePickerController()
            libraryController.delegate = self
            libraryController.sourceType = .photoLibrary
            libraryController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            present(libraryController, animated: true, completion: nil)
        }
    }

    @IBAction
    func addFromFiles(_ sender: UIButton) {
        let documentTypes = utis.map { $0.rawValue }
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }

    @IBAction
    func addFromAudioRecorder(_ sender: UIButton) {
        AudioRecorderViewController.requestPermission { allowed in
            if allowed {
                let controller = AudioRecorderViewController.create()
                // controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                self.present(nav, animated: true, completion: nil)
            } else {
                self.showPermissionError(.microphone)
            }
        }
    }

    func showProgressBar() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4) {
            self.progressView?.isHidden = false
            self.view.layoutIfNeeded()
        }
    }

    func hideProgressBar() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4) {
            self.progressView?.isHidden = true
            self.view.layoutIfNeeded()
        }
    }

    func hideMediaRecorder() {
    }
}

extension FilePickerViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            delegate?.add(self, url: url)
        }
    }
}

extension FilePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        do {
            if let image = info[.originalImage] as? UIImage {
                delegate?.add(self, url: try image.write())
            } else if let videoURL = info[.mediaURL] as? URL {
                let destination = URL
                    .temporaryDirectory
                    .appendingPathComponent("videos", isDirectory: true)
                    .appendingPathComponent(String(Clock.now.timeIntervalSince1970))
                    .appendingPathExtension(videoURL.pathExtension)
                try videoURL.move(to: destination)
                delegate?.add(self, url: destination)
            }
        } catch {
            showError(error)
        }
    }
}

extension FilePickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(FilePickerCell.self, for: indexPath)
        cell.file = files[indexPath.row]
        cell.accessibilityIdentifier = "FilePickerListItem.\(indexPath.row)"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let error = files[indexPath.row].uploadError {
            showError(message: error)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
