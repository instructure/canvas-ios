//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import HorizonUI

struct AttachmentFileModel: Identifiable, Equatable {
    let file: File
    var filename: String { file.filename }
    var isUploading: Bool

    private(set) var uploadState: HorizonUI.UploadedFile.ActionType = .delete
    private(set) var downloadState: HorizonUI.UploadedFile.ActionType = .download

    var id: String { file.id.defaultToEmpty }

    init(file: File) {
        self.file = file
        self.isUploading = file.isUploading
        self.downloadState = isUploading ? .loading : .download
        self.uploadState = file.isUploading ? .loading : .delete
    }

    mutating func startDownloading() {
        downloadState = .loading
    }

    mutating func finishDownloading() {
        downloadState = .download
    }

    mutating func startUploading() {
        uploadState = .loading
    }
}
