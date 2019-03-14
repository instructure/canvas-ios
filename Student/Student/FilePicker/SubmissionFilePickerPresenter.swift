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

class SubmissionFilePresenter {
    private struct File: FileViewModel {
        let url: URL
        let size: Int
        let bytesSent: Int
        let error: String?
    }

    let env: AppEnvironment
    let courseID: String
    let assignmentID: String
    let userID: String
    let context: Context

    private lazy var assignments: Store<GetAssignment> = {
        let useCase = GetAssignment(courseID: courseID, assignmentID: assignmentID)
        return env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    private lazy var fileUploads: Store<GetFileUploads> = {
        let useCase = GetFileUploads(context: .submission(courseID: courseID, assignmentID: assignmentID))
        return FileUploader.shared.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    weak var view: FilePickerViewProtocol?

    var assignment: Assignment? {
        return assignments.first
    }

    var urls: [URL] {
        return assignment?.submissionFiles(appGroup: .student) ?? []
    }

    var inProgress: Bool {
        return fileUploads.first { $0.inProgress } != nil
    }

    var failed: Bool {
        return fileUploads.first { $0.error != nil } != nil
    }

    private var documentTypes: [UTI] {
        return assignment?.allowedUTIs ?? []
    }

    private var sources: [FilePickerSource] {
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

        submitButton.isEnabled = !urls.isEmpty
        return (left: [cancelButton], right: [submitButton])
    }

    init(env: AppEnvironment = .shared, courseID: String, assignmentID: String, userID: String) {
        self.env = env
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.userID = userID
        context = ContextModel(.course, id: courseID)
    }

    func update() {
        updateBarItems()
        updateFiles()

        // Dismiss once all files have been uploaded
        let allDone = urls.allSatisfy { url in
            return fileUploads.first { $0.url == url }?.completed == true
        }
        if !urls.isEmpty && allDone {
            dismiss()
        }
    }

    private func updateBarItems() {
        view?.updateToolbar(items: toolbarItems)
        let nav = navigationItems
        view?.updateNavigationItems(left: nav.left, right: nav.right)
    }

    private func updateFiles() {
        let files: [File] = urls.map { url in
            let fileUpload = self.fileUploads.first { $0.url == url }
            return File(
                url: url,
                size: url.lookupFileSize(),
                bytesSent: fileUpload?.bytesSent ?? 0,
                error: fileUpload?.error
            )
        }
        view?.update(files: files, sources: sources)

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
        for url in urls {
            FileUploader.shared.upload(url, for: .submission(courseID: courseID, assignmentID: assignmentID))
        }
    }

    @objc
    private func dismiss() {
        view?.dismiss()
    }

    @objc
    private func cancelSubmission() {
        // TODO: delete files and dismiss
    }

    @objc
    private func retry() {
        // TODO: retry
    }
}

extension SubmissionFilePresenter: FilePickerPresenterProtocol {
    func viewIsReady() {
        fileUploads.refresh()
        assignments.refresh()
    }

    func add(withInfo info: FileInfo) {
        guard let assignment = assignment else {
            let error = NSError.instructureError(NSLocalizedString("Could not add file because the assignment does not exist.", comment: ""))
            self.view?.showError(error)
            return
        }
        do {
            // move file to assignment submission directory
            let dir = assignment.fileSubmissionURL(appGroup: .student)
            let destination = dir.appendingPathComponent(info.url.lastPathComponent, isDirectory: false)
            try FileManager.default.moveItem(at: info.url, to: destination)
            update()
        } catch {
            self.view?.showError(error)
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
                let url = URL.temporaryDirectory
                    .appendingPathComponent("videos", isDirectory: true)
                    .appendingPathComponent(name, isDirectory: false)
                    .appendingPathExtension(videoURL.pathExtension)
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

    func didSelectFile(_ file: FileViewModel) {
        // The fileSubmission.error is represented by one of the file cells
        if let error = file.error {
            view?.showError(message: error)
        }
    }
}
