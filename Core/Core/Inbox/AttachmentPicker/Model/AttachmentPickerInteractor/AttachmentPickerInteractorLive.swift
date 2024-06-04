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
import Combine

class AttachmentPickerInteractorLive: AttachmentPickerInteractor {
    public let files = PassthroughSubject<[File], Error>()
    public let alreadySelectedFiles: CurrentValueSubject<[File], Never>

    private var uploadManager: UploadManager
    private let batchId: String

    private var subscriptions = Set<AnyCancellable>()

    private lazy var fileStore = uploadManager.subscribe(batchID: batchId) { [weak self] in
        self?.update()
    }

    init(batchId: String, uploadManager: UploadManager, alreadyUploadedFiles: CurrentValueSubject<[File], Never>) {
        self.uploadManager = uploadManager
        self.batchId = batchId
        self.alreadySelectedFiles = alreadyUploadedFiles

        fileStore.refresh()
    }

    private func update() {
        files.send(fileStore.all)
    }

    func uploadFiles() {
        fileStore.all.forEach { file in
            if !file.isUploaded {
                uploadManager.upload(file: file, to: .myFiles, folderPath: "conversation attachments")
            }
        }
    }

    func addFile(url: URL) {
        do {
            try uploadManager.add(url: url, batchID: batchId)
            fileStore.refresh()
        } catch {
            files.send(completion: .failure(NSError.instructureError("Failed to add file")))
        }
    }

    func addFile(file: File) {
        var newValues = alreadySelectedFiles.value
        newValues.append(file)
        alreadySelectedFiles.send(newValues)
    }

    func retry() {
        uploadFiles()
    }

    func cancel() {
        fileStore.all.forEach {file in
            if !file.isUploaded {
                removeFile(file: file)
                uploadManager.cancel(file: file)
            }
        }
    }

    func removeFile(file: File) {
        if alreadySelectedFiles.value.contains(file) {
            let newValues = alreadySelectedFiles.value.filter { $0 != file }
            alreadySelectedFiles.send(newValues)
        } else {
            uploadManager.viewContext.delete(file)
            fileStore.refresh()
        }
    }

    func deleteFile(file: File) -> AnyPublisher<Void, Never> {
        uploadManager.viewContext.delete(file)
        fileStore.refresh()

        if let fileId = file.id {
            return ReactiveStore(useCase: DeleteFile(fileID: fileId))
                .getEntities()
                .mapToVoid()
                .replaceError(with: ())
                .eraseToAnyPublisher()
        } else {
            return Just(()).eraseToAnyPublisher()
        }
    }
}
