//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import FileProvider
import Core

extension File: NSFileProviderItem {
    public var itemIdentifier: NSFileProviderItemIdentifier {
        NSFileProviderItemIdentifier("files/\(id!)")
    }
    public var parentItemIdentifier: NSFileProviderItemIdentifier {
        folderID.map { NSFileProviderItemIdentifier("folders/\($0)") } ?? .rootContainer
    }

    public var capabilities: NSFileProviderItemCapabilities { [
        .allowsDeleting,
        .allowsReading,
        .allowsRenaming,
        .allowsReparenting
    ] }

    public var typeIdentifier: String {
        let uti = contentType.flatMap { UTI(mime: $0) }
            ?? UTI(extension: (filename as NSString).pathExtension)
            ?? UTI.any
        return uti.rawValue
    }

    public var contentModificationDate: Date? { updatedAt }
    public var creationDate: Date? { createdAt }
    public var documentSize: NSNumber? { NSNumber(value: size) }
    public var isDownloaded: Bool { localFileURL != nil }
}

extension Folder: NSFileProviderItem {
    public var itemIdentifier: NSFileProviderItemIdentifier {
        NSFileProviderItemIdentifier("folders/\(id)")
    }
    public var parentItemIdentifier: NSFileProviderItemIdentifier {
        parentFolderID.map { NSFileProviderItemIdentifier("folders/\($0)") } ?? .rootContainer
    }

    public var capabilities: NSFileProviderItemCapabilities { [
        .allowsAddingSubItems,
        .allowsContentEnumerating,
        .allowsDeleting,
        .allowsReading,
        .allowsRenaming,
        .allowsReparenting
    ] }

    public var childItemCount: NSNumber? { NSNumber(value: foldersCount + filesCount) }
    public var contentModificationDate: Date? { updatedAt }
    public var creationDate: Date? { createdAt }
    public var documentSize: NSNumber? { nil }
    public var filename: String { name }
    public var typeIdentifier: String { UTI.folder.rawValue }
}
