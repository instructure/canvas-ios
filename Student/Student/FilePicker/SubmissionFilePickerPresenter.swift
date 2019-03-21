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

import Foundation
import Core
import CoreData

class SubmissionFilePresenter {
    let env: AppEnvironment
    let courseID: String
    let assignmentID: String
    let userID: String
    let context: Context
    let uploader: FileUploader

    private lazy var assignments: Store<GetAssignment> = {
        let useCase = GetAssignment(courseID: courseID, assignmentID: assignmentID)
        return env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var files: Store<LocalUseCase<File>> = {
        let scope = Scope.where(#keyPath(File.assignmentID), equals: assignmentID)
        return env.subscribe(scope: scope) { [weak self] in
            self?.update()
        }
    }()

    weak var view: FilePickerViewProtocol?

    var assignment: Assignment? {
        return assignments.first
    }

    var inProgress: Bool = false

    var failed: Bool {
        return files.first { $0.uploadError != nil } != nil
    }

    private var documentTypes: [UTI] {
        return assignment?.allowedUTIs ?? []
    }

    var sources: [FilePickerSource] {
        let allowed = documentTypes
        if allowed.contains(.any) {
            return FilePickerSource.allCases
        }
        if allowed.contains(where: { $0.isImage || $0.isVideo }) {
            return FilePickerSource.allCases
        }
        return [.files]
    }

    private lazy var cancelButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(cancelSubmission))
        btn.accessibilityIdentifier = "FilePickerPage.cancelButton"
        return btn
    }()

    private lazy var cancelToolbarButton: UIBarButtonItem = {
        return UIBarButtonItem(title: NSLocalizedString("Cancel Submission", comment: ""), style: .plain, target: self, action: #selector(cancelSubmission))
    }()

    private lazy var doneButton: UIBarButtonItem = {
        return UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(dismiss))
    }()

    private lazy var submitButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: NSLocalizedString("Submit", comment: ""), style: .plain, target: self, action: #selector(submit))
        btn.accessibilityIdentifier = "FilePickerPage.submitButton"
        return btn
    }()

    private lazy var retryButton: UIBarButtonItem = {
        return UIBarButtonItem(title: NSLocalizedString("Retry", comment: ""), style: .plain, target: self, action: #selector(retry))
    }()

    private var toolbarItems: [UIBarButtonItem] {
        if inProgress {
            let spacerL = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let spacerR = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            return [spacerL, cancelToolbarButton, spacerR]
        } else if failed {
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            return [cancelToolbarButton, spacer, retryButton]
        }
        return []
    }

    private var navigationItems: (left: [UIBarButtonItem], right: [UIBarButtonItem]) {
        if inProgress || failed {
            return (left: [], right: [doneButton])
        }

        submitButton.isEnabled = !files.isEmpty
        return (left: [cancelButton], right: [submitButton])
    }

    init(env: AppEnvironment = .shared, fileUploader: FileUploader = .shared, courseID: String, assignmentID: String, userID: String) {
        self.env = env
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.userID = userID
        context = ContextModel(.course, id: courseID)
        uploader = fileUploader
    }

    func update() {
        // Dismiss once all files have uploaded
        let inProgress = files.first { $0.isUploading } != nil
        if self.inProgress && !inProgress {
            dismiss()
            return
        }

        self.inProgress = inProgress
        updateBarItems()
        updateFiles()
    }

    private func updateBarItems() {
        view?.updateToolbar(items: toolbarItems)
        let nav = navigationItems
        view?.updateNavigationItems(left: nav.left, right: nav.right)
    }

    private func updateFiles() {
        view?.update()

        let totalToTransfer: Int = files.reduce(0, {$0 + $1.size})
        let bytesSent = files.reduce(0, {$0 + $1.bytesSent})
        var progress = Float(bytesSent) / Float(totalToTransfer)
        if inProgress {
            progress = min(0.98, progress)
            progress = max(0.02, progress)
        } else if failed {
            progress = 0
        }
        view?.updateTransferProgress(progress, sent: bytesSent, expectedToSend: totalToTransfer)
    }

    @objc
    private func submit() {
        for file in files {
            uploader.upload(file, context: .submission(courseID: courseID, assignmentID: assignmentID)) { [weak self] error in
                if let error = error {
                    self?.view?.showError(error)
                } else {
                    self?.view?.dismiss()
                }
            }
        }
    }

    @objc
    private func dismiss() {
        view?.dismiss()
    }

    @objc
    private func cancelSubmission() {
        let context = env.database.viewContext
        context.performAndWait {
            for file in self.files {
                self.uploader.cancel(file)
                context.delete(file)
            }
            do {
                try context.save()
                self.dismiss()
            } catch {
                self.view?.showError(error)
            }
        }
    }

    @objc
    private func retry() {
        // TODO: retry
    }
}

extension SubmissionFilePresenter: FilePickerPresenterProtocol {
    func viewIsReady() {
        assignments.refresh()
    }

    func add(withInfo info: FileInfo) {
        let context = env.database.viewContext
        context.performAndWait {
            do {
                let file: File = context.insert()
                file.localFileURL = info.url
                file.size = info.size
                file.prepareForSubmission(courseID: self.courseID, assignmentID: self.assignmentID)
                try context.save()
            } catch {
                self.view?.showError(error)
            }
        }
    }

    func add(fromSource source: FilePickerSource) {
        switch source {
        case .files:
            let documentTypes = self.documentTypes.map { $0.rawValue }
            view?.presentDocumentPicker(documentTypes: documentTypes)
        case .camera:
            view?.presentCamera()
        case .library:
            view?.presentLibrary()
        }
    }

    func add(withCameraResult result: CameraCaptureResult) {
        if let image = result[.originalImage] as? UIImage {
            do {
                let url = try image.write()
                add(fromURL: url)
            } catch {
                view?.showError(error)
            }
        } else if let videoURL = result[.mediaURL] as? URL {
            do {
                // This file name stinks so try to rename it
                let name = String(Clock.now.timeIntervalSince1970)
                let dir = URL.temporaryDirectory.appendingPathComponent("videos")
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
                let url = dir
                    .appendingPathComponent(name, isDirectory: false)
                    .appendingPathExtension(videoURL.pathExtension)
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
                try FileManager.default.moveItem(at: videoURL, to: url)
                add(fromURL: url)
            } catch {
                add(fromURL: videoURL)
            }
        } else {
            let error = NSError.instructureError(NSLocalizedString("Failed to locate camera result", comment: ""))
            view?.showError(error)
        }
    }

    func didSelectFile(_ file: File) {
        if let error = file.uploadError {
            view?.showError(message: error)
        }
    }
}
