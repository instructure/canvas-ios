//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import SwiftUI

public class FileProgressItemViewModel: ObservableObject {
    public enum State: Equatable {
        case waiting
        case uploading(progress: CGFloat)
        case completed
        case error
    }
    public var fileName: String { file.localFileURL?.lastPathComponent ?? "" }
    public let size: String
    public let icon: Image
    public var state: State {
        if file.uploadError != nil {
            return .error
        } else if file.isUploaded {
            return .completed
        } else if file.isUploading {
            return .uploading(progress: CGFloat(file.bytesSent) / CGFloat(file.size))
        } else {
            return .waiting
        }
    }
    private let onRemove: () -> Void
    private let file: File
    private var fileChangeObserver: AnyCancellable?

    init(file: File, onRemove: @escaping () -> Void) {
        self.file = file
        self.icon = Image(uiImage: file.icon)
        self.size = file.size.humanReadableFileSize
        self.onRemove = onRemove
        self.fileChangeObserver = file.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }

    public func remove() {
        onRemove()
    }
}

extension FileProgressItemViewModel: Identifiable {
    public var id: String { file.objectID.uriRepresentation().lastPathComponent }
}
