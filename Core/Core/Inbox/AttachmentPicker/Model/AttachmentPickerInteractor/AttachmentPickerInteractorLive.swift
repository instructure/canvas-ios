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
    public var isCancelConfirmationNeeded: Bool {
        return !fileStore.all.isAllUploaded || alreadySelectedFiles.value.contains(where: { $0.isUploading == true })
    }

    private let env: AppEnvironment
    private var uploadManager: UploadManager
    private let batchId: String
    private let uploadFolderPath: String?
    private let restrictForFolderPath: Bool

    private var uploadFolder: Folder?
    private var uploadFolderPathStore: Store<GetFolderByPath>?
    private var subscriptions = Set<AnyCancellable>()
    private let publisherProvider: URLSessionDataTaskPublisherProvider

    private lazy var fileStore = uploadManager.subscribe(batchID: batchId) { [weak self] in
        self?.update()
    }

    init(
        env: AppEnvironment = .shared,
        batchId: String,
        folderPath: String? = nil,
        restrictForFolderPath: Bool = false,
        uploadManager: UploadManager,
        alreadyUploadedFiles: CurrentValueSubject<[File], Never>,
        publisherProvider: URLSessionDataTaskPublisherProvider = URLSessionDataTaskPublisherProviderLive()
    ) {
        self.env = env
        self.uploadManager = uploadManager
        self.batchId = batchId
        self.uploadFolderPath = folderPath
        self.restrictForFolderPath = restrictForFolderPath
        self.alreadySelectedFiles = alreadyUploadedFiles
        self.publisherProvider = publisherProvider

        getFolderByPath()
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
        file.taskID = "localProcess"
        var newValues = alreadySelectedFiles.value
        newValues.append(file)
        alreadySelectedFiles.send(newValues)
        if restrictForFolderPath && file.folderID != uploadFolder?.id {
            duplicateFileToUploadFolder(file: file)
        } else {
            file.taskID = nil
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
        var filteredFiles: [File] = alreadySelectedFiles.value.filter { $0.isUploading == false}
        alreadySelectedFiles.send(filteredFiles)
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

    private func duplicateFileToUploadFolder(file: File) {
        if let fileId = file.id {
            getOnlineFileURL(fileId: fileId)
                .map { [weak self] url in
                    if let self, let url {
                        _ = try? self.uploadManager.add(url: url, batchID: self.batchId)
                        let newValues = alreadySelectedFiles.value.filter { $0 != file }
                        alreadySelectedFiles.send(newValues)
                    }
                }
                .sink()
                .store(in: &subscriptions)
        }
    }

    private func getOnlineFileURL(fileId: String) -> AnyPublisher<URL?, Error> {
        ReactiveStore(useCase: GetFile(context: .currentUser, fileID: fileId))
            .getEntities()
            .map { files in
                return files.first?.url
            }
            .flatMap { [weak self] url in
                if let url,
                   let self,
                   let session = self.env.currentSession,
                   let request = try? url.urlRequest(relativeTo: session.baseURL, accessToken: session.accessToken, actAsUserID: session.actAsUserID) {
                    return self.publisherProvider.getPublisher(for: request)
                } else {
                    return Fail(error: NSError.instructureError(String(localized: "Failed to duplicate file", bundle: .core))).eraseToAnyPublisher()
                }
            }
            .map { (localURL: URL, fileName: String) in
                var modifiedURL = localURL
                modifiedURL.deleteLastPathComponent()
                modifiedURL = modifiedURL.appendingPathComponent(fileName)
                try? FileManager.default.moveItem(atPath: localURL.path, toPath: modifiedURL.path)
                return modifiedURL
            }
            .eraseToAnyPublisher()
    }

    private func getFolderByPath() {
        uploadFolderPathStore = env.subscribe(GetFolderByPath(context: .currentUser, path: "conversation attachments"))

        uploadFolderPathStore?
            .allObjects
            .map { [weak self] folders in
                self?.uploadFolder = folders.first
            }
            .sink()
            .store(in: &subscriptions)

        uploadFolderPathStore?.exhaust()
    }
}
