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
import MobileCoreServices

public enum FilePickerSource: Int, CaseIterable {
    case camera, audio, video, library, files
}

public protocol FilePickerControllerDelegate: class {
    func cancel(_ controller: FilePickerViewController)
    func submit(_ controller: FilePickerViewController)
    func retry(_ controller: FilePickerViewController)
    func add(_ controller: FilePickerViewController, url: URL)
    func canSubmit(_ controller: FilePickerViewController) -> Bool
}

open class FilePickerViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var emptyView: EmptyView!
    @IBOutlet weak var sourcesTabBar: UITabBar?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var progressView: FilePickerProgressView!
    @IBOutlet weak var dividerView: UIView!

    public var submitButtonTitle = NSLocalizedString("Submit", bundle: .core, comment: "")
    /// The cancel button that shows while the files are being uploaded
    public var cancelButtonTitle = NSLocalizedString("Cancel", bundle: .core, comment: "")

    public weak var delegate: FilePickerControllerDelegate?
    public var sources = FilePickerSource.allCases
    public var utis: [UTI] = [.any]
    public var maxFiles: Int = .max
    public var files: [File] = []

    public static func create() -> FilePickerViewController {
        return loadFromStoryboard()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)

        var tabBarItems: [UITabBarItem] = []
        if sources.contains(.camera) {
            tabBarItems.append(UITabBarItem(
                title: NSLocalizedString("Camera", bundle: .core, comment: ""),
                image: .icon(.addCameraLine),
                tag: FilePickerSource.camera.rawValue
            ))
        }
        if sources.contains(.audio) {
            tabBarItems.append(UITabBarItem(
                title: NSLocalizedString("Audio", bundle: .core, comment: ""),
                image: .icon(.addAudioLine),
                tag: FilePickerSource.audio.rawValue
            ))
        }
        if sources.contains(.video) {
            tabBarItems.append(UITabBarItem(
                title: NSLocalizedString("Video", bundle: .core, comment: ""),
                image: .icon(.addVideoCameraLine),
                tag: FilePickerSource.video.rawValue
            ))
        }
        if sources.contains(.library) {
            tabBarItems.append(UITabBarItem(
                title: NSLocalizedString("Library", bundle: .core, comment: ""),
                image: .icon(.addImageLine),
                tag: FilePickerSource.library.rawValue
            ))
        }
        if sources.contains(.files) {
            tabBarItems.append(UITabBarItem(
                title: NSLocalizedString("Files", bundle: .core, comment: ""),
                image: .icon(.addDocumentLine),
                tag: FilePickerSource.files.rawValue
            ))
        }
        sourcesTabBar?.items = tabBarItems
        let linkColor = Brand.shared.linkColor.ensureContrast(against: .named(.backgroundLightest))
        sourcesTabBar?.tintColor = linkColor
        sourcesTabBar?.unselectedItemTintColor = linkColor
        reload()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
    }

    public func reload() {
        guard viewIfLoaded != nil else { return }
        emptyView.isHidden = !files.isEmpty
        updateProgressBar()
        updateBarButtons()
        updateSourceButtons()
        tableView.reloadData()
    }

    public func showPending() {
        let spinner = UIActivityIndicatorView(style: .white)
        spinner.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
    }

    public func hidePending() {
        updateBarButtons()
    }

    func updateProgressBar() {
        let total: Int = files.reduce(0, { $0 + $1.size })
        let sent = files.reduce(0, { $0 + $1.bytesSent })
        let failed = files.first { $0.uploadError != nil } != nil
        guard total > 0 && sent > 0 && !failed else {
            hideProgressBar()
            return
        }
        showProgressBar()
        let progress = Float(sent) / Float(total)
        let format = NSLocalizedString("Uploading %@ of %@", bundle: .core, comment: "")
        progressView.text = String.localizedStringWithFormat(format, sent.humanReadableFileSize, total.humanReadableFileSize)
        progressView.progress = progress
    }

    func updateBarButtons() {
        let inProgress = files.first { $0.isUploading } != nil
        let failed = files.first { $0.uploadError != nil } != nil
        if inProgress {
            navigationController?.setToolbarHidden(false, animated: true)
            navigationItem.leftBarButtonItems = []
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(close))
            toolbarItems = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: cancelButtonTitle, style: .plain, target: self, action: #selector(cancel(sender:))),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            ]
        } else if failed {
            navigationController?.setToolbarHidden(false, animated: true)
            navigationItem.leftBarButtonItems = []
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(close))
            toolbarItems = [
                UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(cancel(sender:))),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: NSLocalizedString("Retry", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(retry)),
            ]
        } else {
            navigationController?.setToolbarHidden(true, animated: true)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(cancel(sender:)))
            let submitButton = UIBarButtonItem(title: submitButtonTitle, style: .plain, target: self, action: #selector(submit))
            submitButton.isEnabled = delegate?.canSubmit(self) == true
            navigationItem.rightBarButtonItem = submitButton
        }
    }

    func updateSourceButtons() {
        let inProgress = files.first { $0.isUploading } != nil
        let failed = files.first { $0.uploadError != nil } != nil
        let hideSourceButtons = files.count >= maxFiles || inProgress || failed
        sourcesTabBar?.isHidden = hideSourceButtons
        dividerView.isHidden = hideSourceButtons
    }

    @objc
    func close() {
        dismiss(animated: true, completion: nil)
    }

    @objc
    func cancel(sender: Any) {
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
}

extension FilePickerViewController: UITabBarDelegate {
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        tabBar.selectedItem = nil
        guard let source = FilePickerSource(rawValue: item.tag) else { return }
        switch source {
        case .camera:
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            let cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = .camera
            cameraController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            cameraController.cameraCaptureMode = .photo
            present(cameraController, animated: true, completion: nil)
        case .audio:
            AudioRecorderViewController.requestPermission { allowed in
                if allowed {
                    let controller = AudioRecorderViewController.create()
                    controller.delegate = self
                    controller.view.backgroundColor = UIColor.named(.backgroundLightest)
                    self.present(controller, animated: true, completion: nil)
                } else if let controller = self as? ApplicationViewController {
                    controller.showPermissionError(.microphone)
                }
            }
        case .video:
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
            let cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = .camera
            cameraController.mediaTypes = [kUTTypeMovie as String]
            cameraController.cameraCaptureMode = .video
            present(cameraController, animated: true, completion: nil)
        case .library:
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
            let libraryController = UIImagePickerController()
            libraryController.delegate = self
            libraryController.sourceType = .photoLibrary
            libraryController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            present(libraryController, animated: true, completion: nil)
        case .files:
            let documentTypes = utis.map { $0.rawValue }
            let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
            documentPicker.delegate = self
            present(documentPicker, animated: true, completion: nil)
        }
    }
}

extension FilePickerViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            delegate?.add(self, url: url)
        }
    }
}

extension FilePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        do {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
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
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(FilePickerCell.self, for: indexPath)
        cell.file = files[indexPath.row]
        cell.accessibilityIdentifier = "FilePickerListItem.\(indexPath.row)"

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let error = files[indexPath.row].uploadError {
            showError(message: error)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension FilePickerViewController: AudioRecorderDelegate {
    public func send(_ controller: AudioRecorderViewController, url: URL) {
        delegate?.add(self, url: url)
        controller.dismiss(animated: true, completion: nil)
    }

    public func cancel(_ controller: AudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
