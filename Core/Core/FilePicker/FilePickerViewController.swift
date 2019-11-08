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

public enum FilePickerSource: Int, CaseIterable {
    case camera, library, files
}

public protocol FilePickerControllerDelegate: class {
    func cancel(_ controller: FilePickerViewController)
    func submit(_ controller: FilePickerViewController)
    func retry(_ controller: FilePickerViewController)
    func canSubmit(_ controller: FilePickerViewController) -> Bool
}

open class FilePickerViewController: UIViewController, ErrorViewController, FilePickerViewProtocol {
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
    public var mediaTypes: [String] = [kUTTypeMovie as String, kUTTypeImage as String]
    public var batchID: String!
    public var files: Store<LocalUseCase<File>>? {
        return presenter?.files
    }
    private var presenter: FilePickerPresenter?

    public static func create(environment: AppEnvironment = .shared, batchID: String = UUID.string) -> FilePickerViewController {
        let presenter = FilePickerPresenter(environment: environment, batchID: batchID)
        let controller = loadFromStoryboard()
        controller.batchID = batchID
        controller.presenter = presenter
        presenter.view = controller
        return controller
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        sourcesTabBar?.barTintColor = .named(.backgroundLightest)
        tableView.tableFooterView = UIView(frame: .zero)

        var tabBarItems: [UITabBarItem] = []
        if sources.contains(.camera) {
            let item = UITabBarItem(
                title: NSLocalizedString("Camera", bundle: .core, comment: ""),
                image: .icon(.addCameraLine),
                tag: FilePickerSource.camera.rawValue
            )
            item.accessibilityIdentifier = "FilePicker.cameraButton"
            tabBarItems.append(item)
        }
        if sources.contains(.library) {
            let item = UITabBarItem(
                title: NSLocalizedString("Library", bundle: .core, comment: ""),
                image: .icon(.addImageLine),
                tag: FilePickerSource.library.rawValue
            )
            item.accessibilityIdentifier = "FilePicker.libraryButton"
            tabBarItems.append(item)
        }
        if sources.contains(.files) {
            let item = UITabBarItem(
                title: NSLocalizedString("Files", bundle: .core, comment: ""),
                image: .icon(.addDocumentLine),
                tag: FilePickerSource.files.rawValue
            )
            item.accessibilityIdentifier = "FilePicker.filesButton"
            tabBarItems.append(item)
        }
        sourcesTabBar?.items = tabBarItems
        let linkColor = Brand.shared.linkColor.ensureContrast(against: .named(.backgroundLightest))
        sourcesTabBar?.tintColor = linkColor
        sourcesTabBar?.unselectedItemTintColor = linkColor
        update()
        presenter?.viewIsReady()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.useModalStyle()
    }

    func update() {
        guard viewIfLoaded != nil else { return }
        emptyView.isHidden = files?.isEmpty == false
        updateProgressBar()
        updateBarButtons()
        updateSourceButtons()
        tableView.reloadData()
    }

    func updateProgressBar() {
        guard let files = files else {
            hideProgressBar()
            return
        }
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
        guard let files = files else { return }
        let inProgress = files.first { $0.isUploading } != nil
        let failed = files.first { $0.uploadError != nil } != nil
        if inProgress {
            navigationController?.setToolbarHidden(false, animated: true)
            navigationItem.leftBarButtonItems = []
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(close))
            navigationItem.rightBarButtonItem?.accessibilityIdentifier = "FilePicker.closeButton"
            let cancelButton = UIBarButtonItem(title: cancelButtonTitle, style: .plain, target: self, action: #selector(cancel(sender:)))
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
            let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(cancel(sender:)))
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
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .plain, target: self, action: #selector(cancel(sender:)))
            navigationItem.leftBarButtonItem?.accessibilityIdentifier = "FilePicker.cancelButton"
            let submitButton = UIBarButtonItem(title: submitButtonTitle, style: .plain, target: self, action: #selector(submit))
            submitButton.isEnabled = delegate?.canSubmit(self) == true
            submitButton.accessibilityIdentifier = "FilePicker.submitButton"
            navigationItem.rightBarButtonItem = submitButton
        }
    }

    func updateSourceButtons() {
        let inProgress = files?.first { $0.isUploading } != nil
        let failed = files?.first { $0.uploadError != nil } != nil
        let hideSourceButtons = inProgress || failed
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
            cameraController.mediaTypes = mediaTypes
            present(cameraController, animated: true, completion: nil)
        case .library:
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
            let libraryController = UIImagePickerController()
            libraryController.delegate = self
            libraryController.sourceType = .photoLibrary
            libraryController.mediaTypes = mediaTypes
            libraryController.modalPresentationStyle = .overCurrentContext
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
            presenter?.add(url: url)
        }
    }
}

extension FilePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        do {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                presenter?.add(url: try image.write())
            } else if let videoURL = info[.mediaURL] as? URL {
                let destination = URL
                    .temporaryDirectory
                    .appendingPathComponent("videos", isDirectory: true)
                    .appendingPathComponent(String(Clock.now.timeIntervalSince1970), isDirectory: true)
                    .appendingPathExtension(videoURL.pathExtension)
                try videoURL.copy(to: destination)
                presenter?.add(url: destination)
            }
        } catch {
            showError(error)
        }
    }
}

extension FilePickerViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(FilePickerCell.self, for: indexPath)
        cell.file = files?[indexPath.row]
        cell.accessibilityIdentifier = "FilePickerListItem.\(indexPath.row)"

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let error = files?[indexPath.row]?.uploadError {
            showError(message: error)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
