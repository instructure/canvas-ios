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

class SubmissionFilePresenter: FilePickerPresenterProtocol, FetchedResultsControllerDelegate {
    /// Used to represent fileSubmission error on file row
    private struct FileRow: FileViewModel {
        let url: URL
        let size: Int64
        let bytesSent: Int64
        let error: String?
    }

    let env: AppEnvironment
    let courseID: String
    let assignmentID: String
    let userID: String
    private let assignmentController: FetchedResultsController<Assignment>
    private let fileSubmissionController: FetchedResultsController<FileSubmission>
    private let useCase: () -> AsyncOperation
    private let frc: FetchedResultsController<FileUpload>
    let context: Context

    weak var view: FilePickerViewProtocol?

    private var files: [FileViewModel] {
        let files: [FileViewModel] = frc.fetchedObjects ?? [] as [FileViewModel]
        if let error = fileSubmission?.error, let file = files.first {
            // Stick the fileSubmission's error on the first file so the ui shows it.
            let errorFile = FileRow(url: file.url, size: file.size, bytesSent: file.bytesSent, error: file.error ?? error)
            return [errorFile] + Array(files[1..<files.count])
        }
        return files
    }

    private var fileSubmission: FileSubmission? {
        return fileSubmissionController.fetchedObjects?.first
    }

    private var assignment: Assignment? {
        return assignmentController.fetchedObjects?.first
    }

    private var inProgress: Bool {
        return fileSubmission?.inProgress == true
    }

    private var failed: Bool {
        return fileSubmission?.failed == true
    }

    private var submitted: Bool {
        return fileSubmission?.submitted == true
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

        submitButton.isEnabled = !files.isEmpty
        return (left: [cancelButton], right: [submitButton])
    }

    init(env: AppEnvironment = .shared, courseID: String, assignmentID: String, userID: String, useCase: (() -> AsyncOperation)? = nil) {
        self.env = env
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.userID = userID
        self.assignmentController = env.subscribe(Assignment.self, .details(assignmentID))
        self.fileSubmissionController = env.subscribe(FileSubmission.self, .assignment(assignmentID))
        self.useCase = useCase ?? { GetAssignment(courseID: courseID, assignmentID: assignmentID) }
        context = ContextModel(.course, id: courseID)
        frc = env.subscribe(FileUpload.self, .assignment(assignmentID))
        frc.delegate = self

        assignmentController.delegate = self
        fileSubmissionController.delegate = self
    }

    func viewIsReady() {
        assignmentController.performFetch()
        frc.performFetch()
        fileSubmissionController.performFetch()
        refreshBarItems()
        refreshFiles()
        loadData()
    }

    func add(withInfo info: FileInfo) {
        let op = QueueFileUpload(fileInfo: info, context: context, assignmentID: assignmentID, userID: userID, env: env)
        env.queue.addOperation(op)
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

    private func loadData() {
        let operation = useCase()
        env.queue.addOperation(operation, errorHandler: { [weak self] error in
            if let error = error {
                self?.view?.showError(error)
            }
        })
    }

    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        if (controller == fileSubmissionController && submitted) {
            view?.dismiss()
            return
        }

        refreshFiles()
        refreshBarItems()
    }

    func didSelectFile(_ file: FileViewModel) {
        // The fileSubmission.error is represented by one of the file cells
        if let error = file.error ?? fileSubmission?.error {
            view?.showError(message: error)
        }
    }

    private func refreshBarItems() {
        view?.updateToolbar(items: toolbarItems)
        let nav = navigationItems
        view?.updateNavigationItems(left: nav.left, right: nav.right)
    }

    private func refreshFiles() {
        view?.update(files: files, sources: sources)

        let totalToTransfer: Int64 = files.reduce(0, {$0 + $1.size})
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
        let submit = SubmitFileSubmission(env: env, assignmentID: assignmentID)
        env.queue.addOperation(submit) { [weak self] error in
            if let error = error {
                self?.view?.showError(error)
            } else {
                self?.view?.dismiss()
            }
        }
    }

    @objc
    private func dismiss() {
        view?.dismiss()
    }

    @objc
    private func cancelSubmission() {
        let cancel = CancelFileSubmission(database: env.database, assignmentID: assignmentID)
        env.queue.addOperation(cancel) { [weak self] error in
            if let error = error {
                self?.view?.showError(error)
            } else {
                self?.view?.dismiss()
            }
        }
    }

    @objc
    private func retry() {
        // TODO: retry
    }
}

extension FileUpload: FileViewModel {}
