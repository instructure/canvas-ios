//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

@testable import Core
import Combine
import Foundation

public final class ComposeMessageInteractorMock: ComposeMessageInteractor {

    // MARK: - Outputs
    public var attachments = CurrentValueSubject<[File], Never>([])
    public var didUploadFiles = PassthroughSubject<Result<Void, Error>, Never>()

    // MARK: - Tracking
    public var createConversationCallCount = 0
    public var addConversationMessageCallCount = 0
    public var addFileCallCount = 0
    public var addFileObjectCallCount = 0
    public var retryCallCount = 0
    public var cancelCallCount = 0
    public var removeFileCallCount = 0

    public var lastCreateConversationParameters: MessageParameters?
    public var lastAddConversationMessageParameters: MessageParameters?
    public var lastAddedFileURL: URL?
    public var lastAddedFile: File?
    public var lastRemovedFile: File?

    // MARK: - Response Configuration
    public var addFileResult: File?
    public var createConversationResult: Result<URLResponse?, Error> = .success(nil)
    public var addConversationMessageResult: Result<URLResponse?, Error> = .success(nil)

    // MARK: - Inputs
    public func createConversation(parameters: MessageParameters) -> Future<URLResponse?, Error> {
        createConversationCallCount += 1
        lastCreateConversationParameters = parameters
        return Future { promise in
            promise(self.createConversationResult)
        }
    }

    public func addConversationMessage(parameters: MessageParameters) -> Future<URLResponse?, Error> {
        addConversationMessageCallCount += 1
        lastAddConversationMessageParameters = parameters
        return Future { promise in
            promise(self.addConversationMessageResult)
        }
    }

    @discardableResult
    public func addFile(url: URL) -> File? {
        addFileCallCount += 1
        lastAddedFileURL = url
        return addFileResult
    }

    public func addFile(file: File) {
        addFileObjectCallCount += 1
        lastAddedFile = file
    }

    public func retry() {
        retryCallCount += 1
    }

    public func cancel() {
        cancelCallCount += 1
    }

    public func removeFile(file: File) {
        removeFileCallCount += 1
        lastRemovedFile = file

        // Simulate actual removal from attachments
        var current = attachments.value
        if let index = current.firstIndex(where: { $0.id == file.id }) {
            current.remove(at: index)
            attachments.send(current)
        }
    }

    // MARK: - Helper Methods
    public func simulateAttachments(_ files: [File]) {
        attachments.send(files)
    }

    public func simulateUploadSuccess() {
        didUploadFiles.send(.success(()))
    }

    public func simulateUploadFailure(_ error: Error) {
        didUploadFiles.send(.failure(error))
    }
}
