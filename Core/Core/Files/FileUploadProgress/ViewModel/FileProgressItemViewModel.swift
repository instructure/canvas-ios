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

import CoreData
import Combine
import SwiftUI

public class FileProgressItemViewModel: ObservableObject {
    @Published public var state: FileUploadItem.State
    public var fileName: String { file.localFileURL.lastPathComponent }
    public let size: String
    public let icon: Image
    public var accessibilityLabel: String {
        let fileInfo = NSLocalizedString("File \(fileName) size \(size).", comment: "")
        let status: String = {
            switch file.state {
            case .waiting, .readyForUpload: return ""
            case .uploading(progress: let progress): return NSLocalizedString("Upload in progress \(Int(100 * progress))%", comment: "")
            case .uploaded: return NSLocalizedString("Upload completed.", comment: "")
            case .error: return NSLocalizedString("Upload failed.", comment: "")
            }
        }()

        return [fileInfo, status].joined(separator: " ")
    }
    private let onRemove: (_ item: NSManagedObjectID) -> Void
    private let file: FileUploadItem
    private var fileChangeObserver: AnyCancellable?

    public init(file: FileUploadItem, onRemove: @escaping (_ item: NSManagedObjectID) -> Void) {
        self.state = file.state
        self.file = file
        self.icon = file.mimeClass.image
        self.size = file.fileSize.humanReadableFileSize
        self.onRemove = onRemove
        self.fileChangeObserver = file.stateChangePublisher.sink { [weak self] in
            self?.state = file.state
        }
    }

    public func remove() {
        onRemove(file.objectID)
    }
}

extension FileProgressItemViewModel: Identifiable {
    public var id: String { file.objectID.uriRepresentation().lastPathComponent }
}
