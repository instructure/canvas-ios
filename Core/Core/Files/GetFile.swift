//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class GetFile: APIUseCase {
    typealias Model = File

    let context: Context?
    let fileID: String
    let include: [GetFileRequest.Include]

    init(context: Context?, fileID: String, include: [GetFileRequest.Include] = []) {
        self.context = context
        self.fileID = fileID
        self.include = include
    }

    var cacheKey: String? {
        return "get-file-\(fileID)"
    }

    var scope: Scope {
        return .where(#keyPath(File.id), equals: fileID)
    }

    var request: GetFileRequest {
        return GetFileRequest(context: context, fileID: fileID, include: include)
    }
}

public class GetFolderFiles: CollectionUseCase {
    public typealias Model = File

    let context: Context

    public init(folderID: String) {
        context = Context(.folder, id: folderID)
    }

    public var cacheKey: String? {
        "\(context.pathComponent)/files"
    }

    public var request: GetFilesRequest {
        GetFilesRequest(context: context)
    }

    public var scope: Scope {
        .where(#keyPath(File.folderID), equals: context.id, orderBy: #keyPath(File.displayName), naturally: true)
    }
}
