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

import Foundation
import CoreData

public class GetFolders: CollectionUseCase {
    public typealias Model = Folder

    let context: Context

    public init(context: Context) {
        self.context = context
    }

    public var cacheKey: String? {
        "\(context.pathComponent)/folders"
    }

    public var request: GetFoldersRequest {
        GetFoldersRequest(context: context)
    }

    public var scope: Scope {
        if context.contextType == .folder {
            return .where(#keyPath(Folder.parentFolderID), equals: context.id, orderBy: #keyPath(Folder.name), naturally: true)
        }
        return .where(#keyPath(Folder.canvasContextID), equals: context.canvasContextID, orderBy: #keyPath(Folder.name), naturally: true)
    }
}
