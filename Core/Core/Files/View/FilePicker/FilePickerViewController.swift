//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import MobileCoreServices
import VisionKit
import UniformTypeIdentifiers

public enum FilePickerSource: Int, CaseIterable {
    case camera, library, files, audio, documentScan

    static var defaults: [FilePickerSource] = [.camera, .library, .files, .documentScan]
}

public protocol FilePickerControllerDelegate: AnyObject {
    func cancel(_ controller: FilePickerViewController)
    func submit(_ controller: FilePickerViewController)
    func retry(_ controller: FilePickerViewController)
    func canSubmit(_ controller: FilePickerViewController) -> Bool
}

open class FilePickerViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var sourcesTabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var progressView: FilePickerProgressView!
    @IBOutlet weak var dividerView: UIView!

    public var submitButtonTitle = NSLocalizedString("Submit", bundle: .core, comment: "")
    /// The cancel button that shows while the files are being uploaded
    public var cancelButtonTitle = NSLocalizedString("Cancel", bundle: .core, comment: "")

    let env = AppEnvironment.shared
    public weak var delegate: FilePickerControllerDelegate?
    public var sources = FilePickerSource.defaults
    public var utis: [UTI] = [.any]
    public var mediaTypes: [String] = [UTType.movie.identifier, UTType.image.identifier]
    public var batchID = ""
    public var maxFileCount = Int.max
    public lazy var files = UploadManager.shared.subscribe(batchID: batchID) { [weak self] in
        self?.update()
    }

    public static func create(batchID: String = UUID.string) -> FilePickerViewController {
        let controller = loadFromStoryboard()
        controller.batchID = batchID
        return controller
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        sourcesTabBar.barTintColor = .backgroundLightest
        tableView.tableFooterView = UIView(frame: .zero)
        emptyView.titleText = NSLocalizedString("Choose a File", comment: "")
        emptyView.bodyText = NSLocalizedString("Attach files to your submission by tapping an option below.", comment: "")

        var tabBarItems: [UITabBarItem] = []
        if sources.contains(.audio) {
            let item = UITabBarItem(
                title: NSLocalizedString("Audio", bundle: .core, comment: ""),
                image: .addAudioLine,
                tag: FilePickerSource.audio.rawValue
            )
            item.accessibilityIdentifier = "FilePicker.audioButton"
            tabBarItems.append(item)
        }
        if sources.contains(.camera) {
            let item = UITabBarItem(
                title: NSLocalizedString("Camera", bundle: .core, comment: ""),
                image: .addCameraLine,
                tag: FilePickerSource.camera.rawValue
            )
            item.accessibilityIdentifier = "FilePicker.cameraButton"
            tabBarItems.append(item)
        }
        if sources.contains(.library) {
            let item = UITabBarItem(
                title: NSLocalizedString("Library", bundle: .core, comment: ""),
                image: .addImageLine,
                tag: FilePickerSource.library.rawValue
            )
            item.accessibilityIdentifier = "FilePicker.libraryButton"
            tabBarItems.append(item)
        }
        if sources.contains(.files) {
            let item = UITabBarItem(
                title: NSLocalizedString("Files", bundle: .core, comment: ""),
                image: .addDocumentLine,
                tag: FilePickerSource.files.rawValue
            )
            item.accessibilityIdentifier = "FilePicker.filesButton"
            tabBarItems.append(item)
        }
        if sources.contains(.documentScan) {
            let item = UITabBarItem(
                title: NSLocalizedString("Scanner", bundle: .core, comment: ""),
                image: UIImage(systemName: "doc.text.viewfinder")?.imageWithoutBaseline(),
                tag: FilePickerSource.documentScan.rawValue
            )
            item.accessibilityIdentifier = "FilePicker.scannerButton"
            tabBarItems.append(item)
        }
        sourcesTabBar.items = tabBarItems
        let linkColor = Brand.shared.linkColor
        sourcesTabBar.tintColor = linkColor
        sourcesTabBar.unselectedItemTintColor = linkColor
        update()
        files.refresh()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
    }

    func update() {
        emptyView.isHidden = files.isEmpty == false
        updateProgressBar()
        updateBarButtons()
        updateSourceButtons()
        tableView.reloadData()
    }

    func updateProgressBar() {
        let total: Int = files.reduce(0, { $0 + $1.size })
        let sent: Int = files.reduce(0, { $0 + $1.bytesSent })
        let failed: Bool = files.first { $0.uploadError != nil } != nil
        guard total > 0 && sent > 0 && !failed else {
            hideProgressBar()
            return
        }
        showProgressBar()
        let progress: Float = Float(sent) / Float(total)
        let format: String = NSLocalizedString("Uploading %@ of %@", bundle: .core, comment: "")
        progressView.text = String.localizedStringWithFormat(format, sent.humanReadableFileSize, total.humanReadableFileSize)
        progressView.progress = progress
    }

    func updateBarButtons() {
        let inProgress = files.first { $0.isUploading } != nil
        let failed = files.first { $0.uploadError != nil } != nil
        if inProgress {
            navigationController?.setToolbarHidden(false, animated: true)
            navigationItem.leftBarButtonItems = []
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Dismiss", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(close))
            navigationItem.rightBarButtonItem?.accessibilityIdentifier = "FilePicker.closeButton"
            let cancelButton = UIBarButtonItem(title: cancelButtonTitle, style: .plain, target: self, action: #selector(cancelClicked))
            cancelButton.accessibilityIdentifier = "FilePicker.cancelButton"
            toolbarItems = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                cancelButton,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            ]
        } else if failed {
            navigationController?.setToolbarHidden(false, animated: true)
            navigationItem.leftBarButtonItems = []
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(close))
            navigationItem.rightBarButtonItem?.accessibilityIdentifier = "FilePicker.closeButton"
            let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(cancelClicked))
            cancelButton.accessibilityIdentifier = "FilePicker.cancelButton"
            let retryButton = UIBarButtonItem(title: NSLocalizedString("Retry", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(retry))
            retryButton.accessibilityIdentifier = "FilePicker.retryButton"
            toolbarItems = [
                cancelButton,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                retryButton,
            ]
        } else {
            navigationController?.setToolbarHidden(true, animated: true)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(cancelClicked))
            navigationItem.leftBarButtonItem?.accessibilityIdentifier = "FilePicker.cancelButton"
            let submitButton = UIBarButtonItem(title: submitButtonTitle, style: .done, target: self, action: #selector(submit))
            submitButton.isEnabled = delegate?.canSubmit(self) == true
            submitButton.accessibilityIdentifier = "FilePicker.submitButton"
            navigationItem.rightBarButtonItem = submitButton
        }
    }

    func updateSourceButtons() {
        let inProgress = files.first { $0.isUploading } != nil
        let failed = files.first { $0.uploadError != nil } != nil
        let hideSourceButtons = inProgress || failed
        sourcesTabBar.isHidden = hideSourceButtons
        dividerView.isHidden = hideSourceButtons
    }

    @objc
    func close() {
        dismiss(animated: true, completion: nil)
    }

    @objc
    func cancelClicked() {
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

    func showProgressBar() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4) {
            self.progressView.isHidden = false
            self.view.layoutIfNeeded()
        }
    }

    func hideProgressBar() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4) {
            self.progressView.isHidden = true
            self.view.layoutIfNeeded()
        }
    }

    func didReachMaxFileCount() {
        submit()
    }
}

extension FilePickerViewController: UITabBarDelegate {
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        tabBar.selectedItem = nil
        guard let source = FilePickerSource(rawValue: item.tag) else { return }
        switch source {
        case .camera:
            VideoRecorder.requestPermission { [weak self] allowed in
                guard let self = self else { return }
                guard allowed else {
                    self.showPermissionError(.camera)
                    return
                }
                AudioRecorder.requestPermission { allowed in
                    guard allowed else {
                        self.showPermissionError(.microphone)
                        return
                    }
                    guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
                    let cameraController = UIImagePickerController()
                    cameraController.delegate = self
                    cameraController.sourceType = .camera
                    cameraController.mediaTypes = self.mediaTypes
                    self.env.router.show(cameraController, from: self, options: .modal())
                }
            }
        case .library:
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
            let libraryController = UIImagePickerController()
            libraryController.delegate = self
            libraryController.sourceType = .photoLibrary
            libraryController.mediaTypes = mediaTypes
            env.router.show(libraryController, from: self, options: .modal())
        case .files:
            let documentTypes = utis.compactMap { $0.uttype }
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: documentTypes, asCopy: true)
            documentPicker.delegate = self
            env.router.show(documentPicker, from: self, options: .modal())
        case .audio:
            AudioRecorder.requestPermission { [weak self] allowed in
                guard let self = self else { return }
                guard allowed else {
                    self.showPermissionError(.microphone)
                    return
                }
                let audioRecorder = AudioRecorderViewController.create()
                audioRecorder.delegate = self
                audioRecorder.view.backgroundColor = .backgroundLightest
                audioRecorder.modalPresentationStyle = .formSheet
                self.env.router.show(audioRecorder, from: self, options: .modal())
            }
        case .documentScan:
            if VNDocumentCameraViewController.isSupported {
                let scanner = VNDocumentCameraViewController()
                scanner.delegate = self
                env.router.show(scanner, from: self, options: .modal())
            } else {
                break
            }
        }
    }
}

extension FilePickerViewController: AudioRecorderDelegate {
    public func cancel(_ controller: AudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    public func send(_ controller: AudioRecorderViewController, url: URL) {
        controller.dismiss(animated: true, completion: { [weak self] in self?.add(url) })
    }
}

extension FilePickerViewController: UIDocumentPickerDelegate {
    func add(_ url: URL) {
        UploadManager.shared.viewContext.performAndWait {
            do {
                try UploadManager.shared.add(url: url, batchID: self.batchID)
                if self.files.count == self.maxFileCount { self.didReachMaxFileCount() }
            } catch {
                self.showError(error)
            }
        }
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls { add(url) }
    }
}

extension FilePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        do {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                add(try image.normalize().write())
            } else if let videoURL = info[.mediaURL] as? URL {
                let destination = URL
                    .Directories
                    .temporary
                    .appendingPathComponent("videos", isDirectory: true)
                    .appendingPathComponent(String(Clock.now.timeIntervalSince1970), isDirectory: true)
                    .appendingPathExtension(videoURL.pathExtension)
                try videoURL.copy(to: destination)
                add(destination)
            }
        } catch {
            showError(error)
        }
    }
}

extension FilePickerViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FilePickerCell = tableView.dequeue(for: indexPath)
        cell.backgroundColor = .backgroundLightest
        cell.file = files[indexPath.row]
        cell.accessibilityIdentifier = "FilePickerListItem.\(indexPath.row)"
        cell.delegate = self
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let error = files[indexPath.row]?.uploadError {
            showError(message: error)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension FilePickerViewController: VNDocumentCameraViewControllerDelegate {
    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)
        for i in 0..<scan.pageCount {
            do {
                let image = scan.imageOfPage(at: i)
                add(try image.write())
            } catch {
                showError(error)
            }
        }
    }
}

extension FilePickerViewController: FilePickerCellDelegate {
    func removeFile(_ file: File) {
        let title = NSLocalizedString("Remove File", bundle: .core, comment: "")
        let message = NSLocalizedString("Are you sure you want to remove this file?", bundle: .core, comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        alert.addAction(AlertAction(NSLocalizedString("Remove", bundle: .core, comment: ""), style: .default, handler: {_ in
            UploadManager.shared.cancel(file: file)
        }))
        env.router.show(alert, from: self, options: .modal())
    }
}
