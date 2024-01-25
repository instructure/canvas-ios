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

    private var uploadManager: UploadManager
    private let batchId: String

    let files = PassthroughSubject<[File], Error>()

    private lazy var fileStore = uploadManager.subscribe(batchID: batchId) { [weak self] in
        self?.update()
    }

    private func update() {
        files.send(fileStore.all)
    }

    init(batchId: String, uploadManager: UploadManager) {
        self.uploadManager = uploadManager
        self.batchId = batchId
        fileStore.refresh()
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
            files.send(completion: .failure(NSError()))
        }
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
        uploadManager.viewContext.delete(file)
        fileStore.refresh()
    }
}
