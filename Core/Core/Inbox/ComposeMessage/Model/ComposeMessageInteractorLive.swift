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
import CombineExt

public class ComposeMessageInteractorLive: ComposeMessageInteractor {

    // MARK: - Outputs
    public var conversationAttachmentsFolder = CurrentValueSubject<[Folder], Never>([]) // The only folder that files can be attached from

    // MARK: - Private
    private let env: AppEnvironment
    private let context: Context = .currentUser
    private var subscriptions = Set<AnyCancellable>()
    private var conversationAttachmentsFolderStore: Store<GetFolderByPath>?

    public init(env: AppEnvironment = .shared) {
        self.env = env
        self.getConversationFolderId()
    }

    public func createConversation(parameters: MessageParameters) -> Future<URLResponse?, Error> {
        CreateConversation(
            subject: parameters.subject,
            body: parameters.body,
            recipientIDs: parameters.recipientIDs,
            canvasContextID: parameters.context.canvasContextID,
            attachmentIDs: parameters.attachmentIDs,
            groupConversation: parameters.groupConversation
        )
        .fetchWithFuture()
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
            .fetchWithFuture()
        } else {
            return Future<URLResponse?, Error> { promise in
                promise(.failure(NSError.instructureError(String(localized: "Invalid conversation ID", bundle: .core))))
            }
        }
    }

    public func deleteFile(file: File) -> AnyPublisher<Void, Never> {
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

    public func getOnlineFileURL(fileId: String) -> AnyPublisher<URL?, Error> {
        ReactiveStore(useCase: GetFile(context: context, fileID: fileId))
            .getEntities()
            .map { files in
                return files.first?.url
            }
            .flatMap { [weak self] url in
                if let url,
                   let self,
                   let session = self.env.currentSession,
                   let request = try? url.urlRequest(relativeTo: session.baseURL, accessToken: session.accessToken, actAsUserID: session.actAsUserID) {
                    return URLSessionDataTaskPublisherProviderLive().getPublisher(for: request)
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

    private func getConversationFolderId() {
        conversationAttachmentsFolderStore = env.subscribe(GetFolderByPath(context: context, path: "conversation attachments"))

        conversationAttachmentsFolderStore?
            .allObjects
            .subscribe(conversationAttachmentsFolder)
            .store(in: &subscriptions)

        conversationAttachmentsFolderStore?.exhaust()
    }
}
