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

public class FileProgressViewModel: ObservableObject {
    public var fileName: String { file.localFileURL?.lastPathComponent ?? "" }
    public let size: String
    public let icon: Image
    public var showErrorIcon: Bool { file.uploadError != nil }
    public var isCompleted: Bool { file.bytesSent == file.size }
    public var progress: CGFloat { CGFloat(file.bytesSent) / CGFloat(file.size) }
    public var isUploading: Bool { file.isUploading }
    let file: File
    private var fileChangeObserver: AnyCancellable?

    init(file: File) {
        self.file = file
        self.icon = Image(uiImage: file.icon)
        self.size = file.size.humanReadableFileSize
        self.fileChangeObserver = file.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
}

extension FileProgressViewModel: Identifiable {
    public var id: String { file.objectID.uriRepresentation().lastPathComponent }
}
