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

#if DEBUG
class AttachmentPickerInteractorPreview: AttachmentPickerInteractor {
    var alreadyUploadedFiles = CurrentValueSubject<[File], Never>([])
    var files: PassthroughSubject<[File], Error> = PassthroughSubject<[File], Error>()
    var isCancelConfirmationNeeded = false

    public private(set) var uploadFilesCalled: Bool = false
    public private(set) var addFileCalled: Bool = false
    public private(set) var retryCalled: Bool = false
    public private(set) var cancelCalled: Bool = false
    public private(set) var removeFileCalled: Bool = false
    public private(set) var deleteFileCalled: Bool = false

    func uploadFiles() {
        uploadFilesCalled = true
    }

    func addFile(url: URL) {
        addFileCalled = true
    }

    func addFile(file: File) {
        addFileCalled = true
    }

    func retry() {
        retryCalled = true
    }

    func cancel() {
        cancelCalled = true
    }

    func removeFile(file: File) {
        removeFileCalled = true
    }

    func deleteFile(file: File) -> AnyPublisher<Void, Never> {
        deleteFileCalled = true
        return Just(()).eraseToAnyPublisher()
    }

    func throwError() {
        files.send(completion: .failure(NSError.instructureError("Failed to add file")))
    }
}

#endif
