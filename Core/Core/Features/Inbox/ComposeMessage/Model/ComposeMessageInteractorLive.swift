//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
import CombineSchedulers
import Foundation

public class ComposeMessageInteractorLive: ComposeMessageInteractor {
    // MARK: - Outputs
    public let attachments = CurrentValueSubject<[File], Never>([])

    // MARK: - Private
    private let context: Context = .currentUser
    private var subscriptions = Set<AnyCancellable>()

    private let env: AppEnvironment
    private var uploadManager: UploadManager
    private let batchId: String
    private let uploadFolderPath: String?
    private let restrictForFolderPath: Bool

    private let publisherProvider: URLSessionDataTaskPublisherProvider
    private let scheduler: AnySchedulerOf<DispatchQueue>

    private let alreadyUploadedFiles = CurrentValueSubject<[File], Never>([])
    private lazy var fileStore = uploadManager.subscribe(batchID: batchId, eventHandler: {})

    init(
        env: AppEnvironment = .shared,
        batchId: String,
        uploadFolderPath: String? = nil,
        restrictForFolderPath: Bool = false,
        uploadManager: UploadManager,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        publisherProvider: URLSessionDataTaskPublisherProvider = URLSessionDataTaskPublisherProviderLive()
    ) {
        self.env = env
        self.uploadManager = uploadManager
        self.batchId = batchId
        self.uploadFolderPath = uploadFolderPath
        self.restrictForFolderPath = restrictForFolderPath
        self.scheduler = scheduler
        self.publisherProvider = publisherProvider

        fileStore.refresh()

        setupAttachmentListBinding()
    }

    public func addFile(url: URL) {
        do {
            try uploadManager.add(url: url, batchID: batchId)
            fileStore.refresh()
            uploadFiles()
        } catch {
            // On any error, the file object will contaion the error message.
            // Use retry() function to retry.
        }
    }

    public func addFile(file: File) {
        getFolderByPath()
            .sink(receiveCompletion: { _ in}, receiveValue: { [weak self] uploadFolder in
                guard let self else { return }
                file.taskID = "localProcess"
                var newValues = alreadyUploadedFiles.value
                newValues.append(file)
                alreadyUploadedFiles.send(newValues)
                if restrictForFolderPath && file.folderID != uploadFolder.id {
                    duplicateFileToUploadFolder(file: file)
                } else {
                    file.taskID = nil
                }
            })
            .store(in: &subscriptions)
    }

    public func retry() {
        uploadFiles()
    }

    public func cancel() {
        attachments.value.forEach { file in
            removeFile(file: file)
            if !file.isUploaded {
                uploadManager.cancel(file: file)
            }
        }
    }

    public func removeFile(file: File) {
        if alreadyUploadedFiles.value.contains(file) {
            let newValues = alreadyUploadedFiles.value.filter { $0 != file }
            alreadyUploadedFiles.send(newValues)
        } else {
            file.taskID = "localProcess"
            deleteFile(file: file)
                .sink { [weak self] in
                    guard let self else { return }

                    uploadManager.viewContext.delete(file)
                    fileStore.refresh()
                }
                .store(in: &subscriptions)
        }
    }

    // MARK: - Inputs

    public func createConversation(parameters: MessageParameters) -> Future<URLResponse?, Error> {
        CreateConversation(
            subject: parameters.subject,
            body: parameters.body,
            recipientIDs: parameters.recipientIDs,
            canvasContextID: parameters.context.canvasContextID,
            attachmentIDs: parameters.attachmentIDs,
            bulkMessage: parameters.bulkMessage
        )
        .fetchWithFuture(environment: env)
    }

    public func addConversationMessage(parameters: MessageParameters) -> Future<URLResponse?, Error> {
        if let conversationID = parameters.conversationID {
            return AddMessage(
                conversationID: conversationID,
                attachmentIDs: parameters.attachmentIDs,
                body: parameters.body,
                recipientIDs: parameters.recipientIDs,
                includedMessages: parameters.includedMessages
            )
            .fetchWithFuture(environment: env)
        } else {
            return Future<URLResponse?, Error> { promise in
                promise(.failure(NSError.instructureError(String(localized: "Invalid conversation ID", bundle: .core))))
            }
        }
    }

    // MARK: Private helpers

    private func setupAttachmentListBinding() {
        alreadyUploadedFiles.setFailureType(to: Error.self)
        .combineLatest(with: fileStore.allObjects.setFailureType(to: Error.self))
        .receive(on: scheduler)
        .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] combinedFiles in
            self?.attachments.send(combinedFiles[0] + combinedFiles[1])
        })
        .store(in: &subscriptions)
    }

    private func uploadFiles() {
        fileStore.all.forEach { file in
            if !file.isUploaded {
                uploadManager.upload(file: file, to: .myFiles, folderPath: uploadFolderPath)
            }
        }
    }

    private func deleteFile(file: File) -> AnyPublisher<Void, Never> {
        guard let fileId = file.id else { return Just(()).eraseToAnyPublisher() }

        return ReactiveStore(useCase: DeleteFile(fileID: fileId))
            .getEntities()
            .mapToVoid()
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }

    private func duplicateFileToUploadFolder(file: File) {
        guard let fileId = file.id else { return }

        getOnlineFileURL(fileId: fileId)
            .map { [weak self] url in
                guard let self, let url else { return }
                _ = try? self.uploadManager.add(url: url, batchID: self.batchId)
                let newValues = alreadyUploadedFiles.value.filter { $0 != file }
                alreadyUploadedFiles.send(newValues)
                uploadFiles()
            }
            .sink()
            .store(in: &subscriptions)
    }

    private func getOnlineFileURL(fileId: String) -> AnyPublisher<URL?, Error> {
        ReactiveStore(useCase: GetFile(context: .currentUser, fileID: fileId))
            .getEntities()
            .map { files in
                return files.first?.url
            }
            .receive(on: DispatchQueue.global())
            .flatMap { [weak self] url in
                if let url,
                   let self,
                   let session = self.env.currentSession,
                   let request = try? url.urlRequest(relativeTo: session.baseURL, accessToken: session.accessToken, actAsUserID: session.actAsUserID) {
                    return self.publisherProvider.getPublisher(for: request)
                } else {
                    return Fail(error: NSError.instructureError("Failed to duplicate file")).eraseToAnyPublisher()
                }
            }
            .map { (localURL: URL, fileName: String) in
                var modifiedURL = localURL
                modifiedURL.deleteLastPathComponent()
                modifiedURL = modifiedURL.appendingPathComponent(fileName)
                try? FileManager.default.moveItem(atPath: localURL.path, toPath: modifiedURL.path)
                return modifiedURL
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    private func getFolderByPath() -> AnyPublisher<Folder, Error> {
        return ReactiveStore(useCase: GetFolderByPath(context: .currentUser, path: uploadFolderPath ?? ""))
            .getEntities()
            .compactMap { folders in
                return folders.first
            }
            .eraseToAnyPublisher()
    }
}
