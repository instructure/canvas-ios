//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Foundation
import Core
import Combine

protocol HUploadFileManager {
    func addFile(url: URL)
    func cancelFile(_ file: File)
    func cancelAllFiles()
    func uploadFiles()
    var attachments: CurrentValueSubject<[File], Never> { get }
    var didUploadFiles: PassthroughSubject<Result<Void, Error>, Never> { get }
}

final class HUploadFileManagerLive: HUploadFileManager {
    // MARK: - Outputs

    public let attachments = CurrentValueSubject<[File], Never>([])
    public let didUploadFiles = PassthroughSubject<Result<Void, Error>, Never>()

    // MARK: - Properties

    private lazy var fileStore = uploadManager.subscribe(batchID: batchId, eventHandler: {})
    private var subscriptions = Set<AnyCancellable>()
    private var batchId: String {
        "assignment-\(assignmentID)"
    }

    // MARK: - Dependancies

    private let courseID: String
    private let uploadManager: UploadManager
    private let assignmentID: String

    // MARK: - Init
    init(
        uploadManager: UploadManager,
        assignmentID: String,
        courseID: String
    ) {
        self.uploadManager = uploadManager
        self.assignmentID = assignmentID
        self.courseID = courseID

        fileStore
            .allObjects
            .removeDuplicates()
            .replaceError(with: [])
            .sink { [weak self] files in
                self?.attachments.send(files)
            }
            .store(in: &subscriptions)

        uploadManager
            .didUploadFile
            .subscribe(didUploadFiles)
            .store(in: &subscriptions)
    }

    func addFile(url: URL) {
        do {
            try uploadManager.add(url: url, batchID: batchId)
            fileStore.refresh()
        } catch { debugPrint(error) }
    }

    func cancelFile(_ file: File) {
        uploadManager.cancel(file: file)
    }

    func uploadFiles() {
        let context = FileUploadContext.submission(courseID: courseID, assignmentID: assignmentID, comment: nil)
        UploadManager.shared.upload(batch: batchId, to: context)
    }

    func cancelAllFiles() {
        uploadManager.cancel(batchID: batchId)
    }
}
